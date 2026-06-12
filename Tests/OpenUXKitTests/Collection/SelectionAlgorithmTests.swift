import AppKit
import XCTest
@testable import OpenUXKit

// Selection algorithm tests (Phase P9b).
//
// Exercise the UXKit 26.4 selection core as rebuilt in P9b. The algorithm is a
// set-algebra pipeline driven by _selectItemsInIndexPathsSet:…: build the
// requested selection (gated by allowsSelection, the shouldSelect: delegate
// filter, byExtendingSelection and the single-selection collapse), diff it
// against the live selection, apply with the allowsEmptySelection guard, push
// the will/did delegate notifications, and update _setSelected:animated: on the
// visible cells only.
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/P9-MainClass.md §2.7
//      Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §3 S8

@MainActor
final class SelectionAlgorithmTests: XCTestCase {

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

    private func selectedItems() -> Set<IndexPath> {
        Set(collectionView.indexPathsForSelectedItems() ?? [])
    }

    private func indexPath(_ item: Int) -> IndexPath {
        IndexPath(item: item, section: 0)
    }

    // MARK: - Tests

    func test_singleSelection_replacesPreviousSelection() {
        buildHostedCollectionView(sections: [5])
        collectionView.allowsMultipleSelection = false

        collectionView.selectItem(at: indexPath(1), animated: false, scrollPosition: [])
        XCTAssertEqual(selectedItems(), [indexPath(1)])

        // A fresh non-extending selection must replace, not accumulate.
        collectionView.selectItem(at: indexPath(3), animated: false, scrollPosition: [])
        XCTAssertEqual(selectedItems(), [indexPath(3)])
        XCTAssertTrue(collectionView.cellForItem(at: indexPath(3))!.isSelected)
        XCTAssertFalse(collectionView.cellForItem(at: indexPath(1))!.isSelected)
    }

    func test_singleSelection_collapsesMultiRequestToOne() {
        buildHostedCollectionView(sections: [5])
        collectionView.allowsMultipleSelection = false

        // Requesting several items with multiple selection off keeps exactly one.
        collectionView.selectItems(at: [indexPath(1), indexPath(2), indexPath(3)],
                                   byExtendingSelection: false,
                                   animated: false)
        XCTAssertEqual(selectedItems().count, 1)
    }

    func test_multiSelection_extendingAddsToSelection() {
        buildHostedCollectionView(sections: [5])
        collectionView.allowsMultipleSelection = true

        collectionView.selectItems(at: [indexPath(1)], byExtendingSelection: false, animated: false)
        collectionView.selectItems(at: [indexPath(3)], byExtendingSelection: true, animated: false)

        XCTAssertEqual(selectedItems(), [indexPath(1), indexPath(3)])
        XCTAssertTrue(collectionView.cellForItem(at: indexPath(1))!.isSelected)
        XCTAssertTrue(collectionView.cellForItem(at: indexPath(3))!.isSelected)
    }

    func test_deselect_clearsVisibleCellAndSelection() {
        buildHostedCollectionView(sections: [5])
        collectionView.allowsMultipleSelection = true
        collectionView.allowsEmptySelection = true

        collectionView.selectItems(at: [indexPath(1), indexPath(2)], byExtendingSelection: false, animated: false)
        collectionView.deselectItem(at: indexPath(1), animated: false)

        XCTAssertEqual(selectedItems(), [indexPath(2)])
        XCTAssertFalse(collectionView.cellForItem(at: indexPath(1))!.isSelected)
        XCTAssertTrue(collectionView.cellForItem(at: indexPath(2))!.isSelected)
    }

    func test_emptySelectionDisallowed_keepsAtLeastOneItem() {
        buildHostedCollectionView(sections: [5])
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false

        collectionView.selectItem(at: indexPath(2), animated: false, scrollPosition: [])
        XCTAssertEqual(selectedItems(), [indexPath(2)])

        // Deselecting the only selected item must fall back to a selectable item
        // rather than leaving an empty selection.
        collectionView.deselectItem(at: indexPath(2), animated: false)
        XCTAssertEqual(selectedItems().count, 1)
    }

    func test_shouldSelectDelegate_vetoesSelection() {
        buildHostedCollectionView(sections: [5])
        collectionView.allowsMultipleSelection = true
        let selectionDelegate = VetoingSelectionDelegate(blockedItem: indexPath(2))
        collectionView.delegate = selectionDelegate

        collectionView.selectItems(at: [indexPath(1), indexPath(2), indexPath(3)],
                                   byExtendingSelection: false,
                                   animated: false)

        XCTAssertEqual(selectedItems(), [indexPath(1), indexPath(3)],
                       "the shouldSelect: veto must drop only the blocked index path")
    }
}

// MARK: - Test delegates

@MainActor
private final class VetoingSelectionDelegate: NSObject, UXCollectionViewDelegate {
    let blockedItem: IndexPath
    init(blockedItem: IndexPath) { self.blockedItem = blockedItem }

    @objc(collectionView:shouldSelectItemAtIndexPath:)
    func collectionView(_ collectionView: UXCollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        indexPath != blockedItem
    }
}
