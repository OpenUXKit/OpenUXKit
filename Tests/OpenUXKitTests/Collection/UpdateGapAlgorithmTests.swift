import AppKit
import XCTest
@testable import OpenUXKit

// UpdateGap merging algorithm tests (Phase P8).
//
// The _computeGaps algorithm merges contiguous delete and insert spans into
// UXCollectionViewUpdateGap objects, which is what allows UXKit to drive fewer
// animations during performBatchUpdates. Contiguity is geometric: two update
// items chain only when the bounding rect of the lower index path ends exactly
// where the rect of the higher one begins (CGRectGetMaxY == CGRectGetMinY,
// deletes evaluated against the old model, inserts against the new model).
// Every asserted grouping below was verified against the UXKit 26.4
// decompilation (_computeGaps 0x1DBC086B4 and its two inline blocks).
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/_computeGaps.md
//      Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/P8-UpdateAnimation.md
//      Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L1)

/// Typed mirror for the `_collectionViewData` internal accessor.
@objc private protocol CollectionViewInternalSPI: NSObjectProtocol {
    @objc(_collectionViewData) func collectionViewData() -> AnyObject
}

/// Typed mirror of the private UXCollectionViewUpdate initializer. The method
/// is deliberately not named `init…` on the Swift side so the compiler does
/// not apply init-family ownership conventions; the allocated instance is
/// bridged at +0 and the leak of one update object per test case is accepted.
@objc private protocol CollectionViewUpdateSPI: NSObjectProtocol {
    @objc(initWithCollectionView:updateItems:oldModel:newModel:oldVisibleBounds:newVisibleBounds:)
    func setup(collectionView: AnyObject?,
               updateItems: [UXCollectionViewUpdateItem],
               oldModel: AnyObject,
               newModel: AnyObject,
               oldVisibleBounds: NSRect,
               newVisibleBounds: NSRect) -> AnyObject
}

/// Typed mirror of the UXCollectionViewUpdateItem SPI surface used here.
@objc private protocol UpdateItemSPI: NSObjectProtocol {
    @objc(_gap) func gap() -> AnyObject?
}

/// Typed mirror of the UXCollectionViewUpdateGap interface.
@objc private protocol UpdateGapSPI: NSObjectProtocol {
    @objc(firstUpdateItem) var firstUpdateItem: UXCollectionViewUpdateItem? { get }
    @objc(lastUpdateItem) var lastUpdateItem: UXCollectionViewUpdateItem? { get }
    @objc(deleteItems) var deleteItems: [UXCollectionViewUpdateItem] { get }
    @objc(insertItems) var insertItems: [UXCollectionViewUpdateItem] { get }
    @objc(updateItems) var updateItems: [UXCollectionViewUpdateItem] { get }
    @objc(isDeleteBasedGap) var isDeleteBasedGap: Bool { get }
    @objc(isSectionBasedGap) var isSectionBasedGap: Bool { get }
    @objc(hasInserts) var hasInserts: Bool { get }
}

@MainActor
final class UpdateGapAlgorithmTests: XCTestCase {

    // MARK: - Helpers

    /// Builds a single-column fixture (item width == container width) so that
    /// consecutive index paths are exactly vertically adjacent: row N ends at
    /// y == 50 * (N + 1) where row N + 1 begins.
    private func makeSingleColumnFixture(sections: [Int]) -> (fixture: UXCollectionViewFlowLayoutFixture, collectionView: UXCollectionView) {
        let fixture = UXCollectionViewFlowLayoutFixture()
        fixture.scrollDirection = .vertical
        fixture.itemSize = NSSize(width: 320, height: 50)
        fixture.sections = sections
        fixture.collectionViewFrame = NSRect(x: 0, y: 0, width: 320, height: 480)
        let (collectionView, _) = fixture.build()
        return (fixture, collectionView)
    }

    private func collectionViewData(of collectionView: UXCollectionView) -> AnyObject {
        unsafeBitCast(collectionView, to: CollectionViewInternalSPI.self).collectionViewData()
    }

    /// Runs the full UXCollectionViewUpdate pipeline (which invokes
    /// _computeSectionUpdates → _computeItemUpdates → _computeGaps) and
    /// returns the gaps in first-assignment order, recovered through each
    /// update item's `_gap` back-pointer exactly as UXKit consumers do.
    private func computeGaps(oldSections: [Int],
                             newSections: [Int],
                             updateItems: [UXCollectionViewUpdateItem]) throws -> [UpdateGapSPI] {
        let (oldFixture, oldCollectionView) = makeSingleColumnFixture(sections: oldSections)
        let (newFixture, newCollectionView) = makeSingleColumnFixture(sections: newSections)
        withExtendedLifetime(oldFixture) {}
        withExtendedLifetime(newFixture) {}

        let updateClass = try XCTUnwrap(NSClassFromString("UXCollectionViewUpdate") as? NSObject.Type)
        let allocated = try XCTUnwrap((updateClass as AnyObject).perform(NSSelectorFromString("alloc"))?.takeUnretainedValue())
        let update = unsafeBitCast(allocated, to: CollectionViewUpdateSPI.self).setup(
            collectionView: newCollectionView,
            updateItems: updateItems,
            oldModel: collectionViewData(of: oldCollectionView),
            newModel: collectionViewData(of: newCollectionView),
            oldVisibleBounds: oldCollectionView.bounds,
            newVisibleBounds: newCollectionView.bounds
        )
        withExtendedLifetime(update) {}

        var gaps: [UpdateGapSPI] = []
        for updateItem in updateItems {
            let gap = try XCTUnwrap(unsafeBitCast(updateItem, to: UpdateItemSPI.self).gap(),
                                    "every update item must receive a _setGap: assignment")
            if !gaps.contains(where: { $0 === gap }) {
                gaps.append(unsafeBitCast(gap, to: UpdateGapSPI.self))
            }
        }
        return gaps
    }

    private func deleteItem(_ item: Int, section: Int = 0) -> UXCollectionViewUpdateItem {
        UXCollectionViewUpdateItem(initialIndexPath: IndexPath(item: item, section: section) as NSIndexPath as IndexPath,
                                   finalIndexPath: nil,
                                   updateAction: .delete)
    }

    private func insertItem(_ item: Int, section: Int = 0) -> UXCollectionViewUpdateItem {
        UXCollectionViewUpdateItem(initialIndexPath: nil,
                                   finalIndexPath: IndexPath(item: item, section: section) as NSIndexPath as IndexPath,
                                   updateAction: .insert)
    }

    private func deleteSection(_ section: Int) -> UXCollectionViewUpdateItem {
        UXCollectionViewUpdateItem(initialIndexPath: IndexPath(indexes: [section]),
                                   finalIndexPath: nil,
                                   updateAction: .delete)
    }

    // MARK: - Tests

    /// A descending run of geometrically adjacent deletes chains into one
    /// delete-based gap (each new delete becomes firstUpdateItem), and an
    /// insert whose gap-merge-adjusted index path falls inside the
    /// [first, last] span is absorbed into that same gap.
    func test_pureDeleteThenInsert_mergesIntoSingleGap() throws {
        let deleteFour = deleteItem(4)
        let deleteThree = deleteItem(3)
        let deleteTwo = deleteItem(2)
        let insertTwo = insertItem(2)

        let gaps = try computeGaps(oldSections: [10],
                                   newSections: [8],
                                   updateItems: [deleteFour, deleteThree, deleteTwo, insertTwo])

        XCTAssertEqual(gaps.count, 1)
        let gap = gaps[0]
        XCTAssertTrue(gap.isDeleteBasedGap)
        XCTAssertTrue(gap.hasInserts)
        XCTAssertFalse(gap.isSectionBasedGap)
        XCTAssertEqual(gap.deleteItems, [deleteFour, deleteThree, deleteTwo])
        XCTAssertEqual(gap.insertItems, [insertTwo])
        XCTAssertEqual(gap.updateItems, [deleteFour, deleteThree, deleteTwo, insertTwo])
        XCTAssertIdentical(gap.firstUpdateItem, deleteTwo)
        XCTAssertIdentical(gap.lastUpdateItem, deleteFour)
    }

    /// Non-adjacent deletes break the chain into separate gaps; an insert
    /// whose adjusted index path lies before every delete-based gap's span
    /// starts its own insert gap, and the following geometrically adjacent
    /// insert extends it through the fast path (lastUpdateItem advances).
    func test_nonContiguousOperations_formSeparateGaps() throws {
        let deleteEight = deleteItem(8)
        let deleteTwo = deleteItem(2)
        let insertZero = insertItem(0)
        let insertOne = insertItem(1)

        let gaps = try computeGaps(oldSections: [10],
                                   newSections: [10],
                                   updateItems: [deleteEight, deleteTwo, insertZero, insertOne])

        XCTAssertEqual(gaps.count, 3)

        XCTAssertEqual(gaps[0].deleteItems, [deleteEight])
        XCTAssertFalse(gaps[0].hasInserts)

        XCTAssertEqual(gaps[1].deleteItems, [deleteTwo])
        XCTAssertFalse(gaps[1].hasInserts)

        XCTAssertFalse(gaps[2].isDeleteBasedGap)
        XCTAssertTrue(gaps[2].hasInserts)
        XCTAssertEqual(gaps[2].insertItems, [insertZero, insertOne])
        XCTAssertIdentical(gaps[2].firstUpdateItem, insertZero)
        XCTAssertIdentical(gaps[2].lastUpdateItem, insertOne)
    }

    /// Section deletes whose union rects touch chain into one section-based
    /// gap, while an item-level delete never joins a section-based gap
    /// because their bounding rects are not adjacent.
    func test_sectionBasedOperations_groupSeparatelyFromItemOperations() throws {
        let deleteSectionTwo = deleteSection(2)
        let deleteSectionOne = deleteSection(1)
        let deleteItemOne = deleteItem(1, section: 0)

        let gaps = try computeGaps(oldSections: [3, 3, 3],
                                   newSections: [2],
                                   updateItems: [deleteSectionTwo, deleteSectionOne, deleteItemOne])

        XCTAssertEqual(gaps.count, 2)

        XCTAssertTrue(gaps[0].isSectionBasedGap)
        XCTAssertEqual(gaps[0].deleteItems, [deleteSectionTwo, deleteSectionOne])
        XCTAssertIdentical(gaps[0].firstUpdateItem, deleteSectionOne)
        XCTAssertIdentical(gaps[0].lastUpdateItem, deleteSectionTwo)

        XCTAssertFalse(gaps[1].isSectionBasedGap)
        XCTAssertEqual(gaps[1].deleteItems, [deleteItemOne])
        XCTAssertFalse(gaps[1].hasInserts)
    }
}
