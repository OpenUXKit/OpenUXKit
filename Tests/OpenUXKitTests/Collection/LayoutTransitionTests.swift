import AppKit
import XCTest
@testable import OpenUXKit

// Cross-layout transition integration tests (Phase P9d).
//
// These exercise the UXKit 26.4 animated/synchronous layout-swap pipeline rebuilt
// in P9d:
//   setCollectionViewLayout:animated:completion: → _setCollectionViewLayout:…:
//   → (visible && doneFirstLayout) _performLayoutTransitionToLayout:…:
//   → new UXCollectionViewData + _prepareToLoadData, _prepareForTransition*,
//     updatingLayout flag, anchor selection (selected ∩ onscreen → nearest-center),
//     target content offset, appearing/disappearing/persisting view diff driven by
//     -[UXCollectionViewLayout _animateView:withAction:…], _layoutTransitionAnimationCount
//     finalize-when-zero (swap _layout/_collectionViewData, didTransition, completion).
//
// The transition cannot be verified visually in a headless test, so these assert
// the end state: the layout is swapped, the content size matches the new layout,
// the visible cells are rebuilt, and the selection is preserved. UXKit invokes the
// completion handler with NO at the end of a (visible) transition, so the tests
// assert it fires rather than its boolean value.
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/P9-MainClass.md §7.3

@MainActor
final class LayoutTransitionTests: XCTestCase {

    private var window: NSWindow!
    private var fixture: UXCollectionViewFlowLayoutFixture!
    private var collectionView: UXCollectionView!

    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            fixture = UXCollectionViewFlowLayoutFixture()
            fixture.scrollDirection = .vertical
            fixture.itemSize = NSSize(width: 320, height: 50)
            fixture.collectionViewFrame = NSRect(x: 0, y: 0, width: 320, height: 480)
        }
    }

    override func tearDown() {
        MainActor.assumeIsolated {
            window?.contentView = nil
            window = nil
            collectionView = nil
            fixture = nil
        }
        super.tearDown()
    }

    /// Builds the collection view, hosts it in a window (so `_visible` is true and
    /// the first layout completes) and performs the initial layout pass.
    private func buildHostedCollectionView(sections: [Int]) {
        fixture.sections = sections
        let (builtCollectionView, _) = fixture.build()
        collectionView = builtCollectionView
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 320, height: 480),
                          styleMask: [.borderless],
                          backing: .buffered,
                          defer: false)
        window.contentView = collectionView
        collectionView.layout()
    }

    /// A fresh flow layout that produces a different (still fully-visible) geometry
    /// after `fixture.itemSize` is changed; the delegate drives the per-item size.
    private func makeReplacementLayout() -> UXCollectionViewFlowLayout {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = fixture.itemSize
        return layout
    }

    private func visibleItemIndexPaths() -> Set<IndexPath> {
        Set(collectionView.indexPathsForVisibleItems())
    }

    // MARK: - Synchronous (animated: false) transition

    func test_setLayout_animatedFalse_swapsSynchronouslyAndPreservesEndState() {
        buildHostedCollectionView(sections: [6])
        collectionView.selectItems(at: [IndexPath(item: 2, section: 0)], byExtendingSelection: false, animated: false)
        XCTAssertEqual(collectionView.collectionViewLayout.collectionViewContentSize().height, 300,
                       accuracy: 0.5)

        // Shrink the per-item height so the new layout reports a different content
        // size while keeping all six items on screen (6 * 70 = 420 < 480).
        fixture.itemSize = NSSize(width: 320, height: 70)
        let replacementLayout = makeReplacementLayout()

        var completionFired = false
        collectionView.setCollectionViewLayout(replacementLayout, animated: false) { _ in
            completionFired = true
        }

        XCTAssertTrue(completionFired,
                      "the synchronous (visible) transition invokes completion before returning")
        XCTAssertTrue(collectionView.collectionViewLayout === replacementLayout,
                      "the layout must be swapped once the transition finalizes")
        XCTAssertEqual(collectionView.contentSize.height, 420, accuracy: 0.5,
                       "content size must follow the new layout")

        // Re-run layout so the scheduled visible-cell update repositions the cells.
        collectionView.layout()
        XCTAssertEqual(collectionView.visibleCells().count, 6)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<6).map { IndexPath(item: $0, section: 0) }))
        XCTAssertEqual(Set(collectionView.indexPathsForSelectedItems() ?? []),
                       [IndexPath(item: 2, section: 0)],
                       "the selection survives a layout transition")
    }

    func test_setLayout_animatedFalse_repositionsCellsForNewLayout() {
        buildHostedCollectionView(sections: [6])
        let trackedCell = collectionView.cellForItem(at: IndexPath(item: 3, section: 0))
        XCTAssertNotNil(trackedCell)

        fixture.itemSize = NSSize(width: 320, height: 70)
        let replacementLayout = makeReplacementLayout()
        collectionView.setCollectionViewLayout(replacementLayout, animated: false, completion: nil)
        collectionView.layout()

        // Item 3 sits at y = 3 * 70 = 210 under the new single-column layout.
        let repositioned = collectionView.cellForItem(at: IndexPath(item: 3, section: 0))
        XCTAssertNotNil(repositioned)
        XCTAssertTrue(repositioned === trackedCell,
                      "a persisting cell keeps its identity across a layout transition")
        XCTAssertEqual(repositioned?.frame.origin.y ?? .nan, 210, accuracy: 0.5)
    }

    // MARK: - Animated transition

    func test_setLayout_animatedTrue_swapsViaCompletionAndPreservesEndState() {
        buildHostedCollectionView(sections: [6])
        collectionView.selectItems(at: [IndexPath(item: 1, section: 0)], byExtendingSelection: false, animated: false)
        let layoutBeforeTransition = collectionView.collectionViewLayout

        fixture.itemSize = NSSize(width: 320, height: 70)
        let replacementLayout = makeReplacementLayout()

        let completionExpectation = expectation(description: "layout transition completion")
        collectionView.setCollectionViewLayout(replacementLayout, animated: true) { _ in
            completionExpectation.fulfill()
        }

        // The swap is deferred to the animation-group completion; the old layout is
        // still installed synchronously after the call returns.
        XCTAssertTrue(collectionView.collectionViewLayout === layoutBeforeTransition,
                      "the animated transition defers the layout swap until completion")

        waitForExpectations(timeout: 5)

        XCTAssertTrue(collectionView.collectionViewLayout === replacementLayout,
                      "the layout is swapped once every in-flight animation resolves")
        XCTAssertEqual(collectionView.contentSize.height, 420, accuracy: 0.5)

        collectionView.layout()
        XCTAssertEqual(collectionView.visibleCells().count, 6)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<6).map { IndexPath(item: $0, section: 0) }))
        XCTAssertEqual(Set(collectionView.indexPathsForSelectedItems() ?? []),
                       [IndexPath(item: 1, section: 0)])
    }

    func test_setLayout_sameLayout_isNoOp() {
        buildHostedCollectionView(sections: [4])
        let currentLayout = collectionView.collectionViewLayout

        // UXKit returns early without invoking the completion handler when the
        // layout is unchanged.
        var completionFired = false
        collectionView.setCollectionViewLayout(currentLayout, animated: true) { _ in
            completionFired = true
        }

        XCTAssertFalse(completionFired,
                       "setting the same layout is a no-op and must not invoke completion")
        XCTAssertTrue(collectionView.collectionViewLayout === currentLayout)
    }

    func test_setLayout_whileNotVisible_takesSynchronousFastPath() {
        fixture.sections = [3]
        let (builtCollectionView, _) = fixture.build()
        collectionView = builtCollectionView

        fixture.itemSize = NSSize(width: 320, height: 70)
        let replacementLayout = makeReplacementLayout()

        var completionFinished: Bool?
        collectionView.setCollectionViewLayout(replacementLayout, animated: true) { finished in
            completionFinished = finished
        }

        XCTAssertEqual(completionFinished, true,
                       "the offscreen fast path swaps synchronously and reports finished == YES")
        XCTAssertTrue(collectionView.collectionViewLayout === replacementLayout)
    }
}
