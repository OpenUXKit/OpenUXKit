import AppKit
import XCTest
@testable import OpenUXKit

// performBatchUpdates integration tests (Phase P9).
//
// These exercise the UXKit 26.4 update pipeline as rebuilt in P9:
//   performBatchUpdates: → _beginUpdates (_setupCellAnimations) → update block
//   (_updateRows…/_updateSections… feed the four item families) → _endUpdates →
//   _endItemAnimations (reload decomposition, validation, UXCollectionViewUpdate)
//   → _updateWithItems: (selection remap, _computeSupplementaryUpdates,
//   animation group) → _viewAnimationsForCurrentUpdate → _updateAnimationDidStop:.
//
// The visible dictionary is rebuilt synchronously inside the animation group,
// so visibleCells/indexPathsForVisibleItems reflect the new model as soon as
// the mutation call returns; the completion handler fires asynchronously once
// every UXCollectionViewAnimation reports back.
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/P9-MainClass.md §2.1–2.3
//      Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L2)

@MainActor
final class PerformBatchUpdatesTests: XCTestCase {

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

    /// Builds the collection view, hosts it in a window (required so that
    /// `_visible` returns true) and performs the first layout pass.
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

    private func visibleItemIndexPaths() -> Set<IndexPath> {
        Set(collectionView.indexPathsForVisibleItems())
    }

    // MARK: - Tests

    func test_firstLayout_buildsVisibleCellsFromDataSource() {
        buildHostedCollectionView(sections: [5])

        XCTAssertEqual(collectionView.visibleCells().count, 5)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<5).map { IndexPath(item: $0, section: 0) }))
    }

    func test_insertItems_appendsToVisibleSet() {
        buildHostedCollectionView(sections: [5])

        fixture.sections = [6]
        collectionView.insertItems(at: [IndexPath(item: 2, section: 0)])

        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 6)
        XCTAssertEqual(collectionView.visibleCells().count, 6)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<6).map { IndexPath(item: $0, section: 0) }))
    }

    func test_deleteItems_removesFromVisibleSet() {
        buildHostedCollectionView(sections: [5])

        fixture.sections = [4]
        collectionView.deleteItems(at: [IndexPath(item: 2, section: 0)])

        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 4)
        XCTAssertEqual(collectionView.visibleCells().count, 4)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<4).map { IndexPath(item: $0, section: 0) }))
    }

    func test_reloadItems_keepsIndexPathsButUpdatesContents() {
        buildHostedCollectionView(sections: [5])
        let cellBeforeReload = collectionView.cellForItem(at: IndexPath(item: 2, section: 0))
        XCTAssertNotNil(cellBeforeReload)

        collectionView.reloadItems(at: [IndexPath(item: 2, section: 0)])

        XCTAssertEqual(collectionView.visibleCells().count, 5)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<5).map { IndexPath(item: $0, section: 0) }))
        let cellAfterReload = collectionView.cellForItem(at: IndexPath(item: 2, section: 0))
        XCTAssertNotNil(cellAfterReload)
        XCTAssertFalse(cellBeforeReload === cellAfterReload,
                       "reload decomposes into delete+insert, so the cell must be re-created")
    }

    func test_moveItem_shiftsIndexPathAndPreservesIdentity() {
        buildHostedCollectionView(sections: [5])
        let movedCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))
        XCTAssertNotNil(movedCell)

        collectionView.moveItem(at: IndexPath(item: 0, section: 0),
                                to: IndexPath(item: 4, section: 0))

        XCTAssertEqual(collectionView.visibleCells().count, 5)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<5).map { IndexPath(item: $0, section: 0) }))
        XCTAssertTrue(collectionView.cellForItem(at: IndexPath(item: 4, section: 0)) === movedCell,
                      "a moved cell keeps its identity at the destination index path")
    }

    func test_insertPlusDelete_inSingleBatch_runsCompletionHandler() {
        buildHostedCollectionView(sections: [10])

        let completionExpectation = expectation(description: "batch completion")
        collectionView.performBatchUpdates({
            self.fixture.sections = [10]
            self.collectionView.deleteItems(at: [IndexPath(item: 8, section: 0)])
            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }, completion: { finished in
            XCTAssertTrue(finished)
            completionExpectation.fulfill()
        })

        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 10)
        XCTAssertEqual(visibleItemIndexPaths(),
                       Set((0..<10).map { IndexPath(item: $0, section: 0) }))
        waitForExpectations(timeout: 5)
    }

    func test_insertSection_inBatch_updatesSectionCount() {
        buildHostedCollectionView(sections: [2, 2])

        let completionExpectation = expectation(description: "batch completion")
        collectionView.performBatchUpdates({
            self.fixture.sections = [2, 1, 2]
            self.collectionView.insertSections(IndexSet(integer: 1))
        }, completion: { _ in
            completionExpectation.fulfill()
        })

        XCTAssertEqual(collectionView.numberOfSections(), 3)
        XCTAssertEqual(collectionView.visibleCells().count, 5)
        waitForExpectations(timeout: 5)
    }

    func test_batchUpdates_whileNotVisible_fallsBackToReload() {
        fixture.sections = [3]
        let (builtCollectionView, _) = fixture.build()
        collectionView = builtCollectionView

        var completionFinished = false
        collectionView.performBatchUpdates({
            self.fixture.sections = [4]
            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }, completion: { finished in
            completionFinished = finished
        })

        XCTAssertTrue(completionFinished,
                      "the invisible fast path must call the completion synchronously with finished == YES")
    }
}
