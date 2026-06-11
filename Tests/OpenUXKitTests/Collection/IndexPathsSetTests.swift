import Foundation
import XCTest
@testable import OpenUXKit

// IndexPathsSet pure-algorithm tests (Phase P7).
//
// UXCollectionViewIndexPathsSet / UXCollectionViewMutableIndexPathsSet /
// _UXCollectionViewSectionItemIndexes are private (not part of the public
// module interface), so the tests reach them through the ObjC runtime via a
// typed @objc protocol mirror. Every asserted behavior below was verified
// against the UXKit 26.4 decompilation (UXKit.i64, IMPs 0x1DBBF87AC-0x1DBBFABE8).
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L1)
//      Docs/Plans/UXCollectionView-UXKit-Alignment/AlignmentMatrix.md §S4
//      Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/P7-IndexPathsSet.md

/// Typed mirror of the UXCollectionView(Mutable)IndexPathsSet ObjC interface.
/// Conformance is never declared by the real classes; instances are bridged
/// with `unsafeBitCast` and dispatched per selector through objc_msgSend.
@objc private protocol IndexPathsSetAPI: NSObjectProtocol {

    // UXCollectionViewIndexPathsSet (immutable interface)
    @objc(count) var count: Int { get }
    @objc(sections) func sections() -> IndexSet
    @objc(allIndexPaths) func allIndexPaths() -> [IndexPath]
    @objc(containsIndexPath:) func contains(indexPath: IndexPath?) -> Bool
    @objc(itemsInSection:) func items(inSection section: Int) -> IndexSet?
    @objc(firstIndexPath) func firstIndexPath() -> IndexPath?
    @objc(lastIndexPath) func lastIndexPath() -> IndexPath?
    @objc(indexPathsForSection:) func indexPaths(forSection section: Int) -> [IndexPath]?
    @objc(indexPathsForSections:) func indexPaths(forSections sections: IndexSet) -> [IndexPath]
    @objc(copy) func copyObject() -> AnyObject
    @objc(mutableCopy) func mutableCopyObject() -> AnyObject

    // UXCollectionViewMutableIndexPathsSet (mutable interface)
    @objc(addIndexPath:) func add(indexPath: IndexPath?)
    @objc(addIndexPaths:) func add(indexPaths: [IndexPath])
    @objc(addIndexPathsSet:) func add(indexPathsSet: IndexPathsSetAPI?)
    @objc(addSection:itemsInRange:) func addSection(_ section: Int, itemsInRange range: NSRange)
    @objc(removeIndexPath:) func remove(indexPath: IndexPath?)
    @objc(removeIndexPaths:) func remove(indexPaths: [IndexPath])
    @objc(removeIndexPathsSet:) func remove(indexPathsSet: IndexPathsSetAPI)
    @objc(removeAllIndexPaths) func removeAllIndexPaths()
    @objc(removeSection:) func removeSection(_ section: Int)
    @objc(removeSection:itemsInRange:) func removeSection(_ section: Int, itemsInRange range: NSRange)
    @objc(removeSections:) func removeSections(_ sections: IndexSet)
    @objc(intersectIndexPathsSet:) func intersect(indexPathsSet: IndexPathsSetAPI)
    @objc(adjustForDeletionOfIndexPath:) func adjustForDeletion(ofIndexPath indexPath: IndexPath?)
    @objc(adjustForDeletionOfItems:inSection:) func adjustForDeletion(ofItems items: IndexSet, inSection section: Int)
    @objc(adjustForDeletionOfSection:) func adjustForDeletion(ofSection section: Int)
    @objc(adjustForDeletionOfSections:) func adjustForDeletion(ofSections sections: IndexSet)
    @objc(adjustForInsertionOfIndexPath:) func adjustForInsertion(ofIndexPath indexPath: IndexPath?)
    @objc(adjustForInsertionOfItems:inSection:) func adjustForInsertion(ofItems items: IndexSet, inSection section: Int)
    @objc(adjustForInsertionOfSection:) func adjustForInsertion(ofSection section: Int)
    @objc(adjustForInsertionOfSections:) func adjustForInsertion(ofSections sections: IndexSet)
}

final class IndexPathsSetTests: XCTestCase {

    // MARK: - Helpers

    private static let immutableClassName = "UXCollectionViewIndexPathsSet"
    private static let mutableClassName = "UXCollectionViewMutableIndexPathsSet"

    private func makeMutableSet() -> IndexPathsSetAPI {
        guard let mutableSetClass = NSClassFromString(Self.mutableClassName) as? NSObject.Type else {
            preconditionFailure("\(Self.mutableClassName) is not linked into the test runner")
        }
        return unsafeBitCast(mutableSetClass.init(), to: IndexPathsSetAPI.self)
    }

    private func makeMutableSet(_ contents: [Int: [Int]]) -> IndexPathsSetAPI {
        let indexPathsSet = makeMutableSet()
        for (section, items) in contents {
            for item in items {
                indexPathsSet.add(indexPath: IndexPath(indexes: [section, item]))
            }
        }
        return indexPathsSet
    }

    /// Snapshot of section -> item indexes, read strictly through `sections()`
    /// so the assertion never observes dictionary keys that fell out of the
    /// section index set.
    private func snapshot(_ indexPathsSet: IndexPathsSetAPI) -> [Int: Set<Int>] {
        var result: [Int: Set<Int>] = [:]
        for section in indexPathsSet.sections() {
            result[section] = Set(indexPathsSet.items(inSection: section) ?? IndexSet())
        }
        return result
    }

    // MARK: - Empty set

    func test_emptySet_hasZeroCountAndNilFirstLast() {
        let indexPathsSet = makeMutableSet()

        XCTAssertEqual(indexPathsSet.count, 0)
        XCTAssertNil(indexPathsSet.firstIndexPath())
        XCTAssertNil(indexPathsSet.lastIndexPath())
        XCTAssertTrue(indexPathsSet.sections().isEmpty)
        XCTAssertTrue(indexPathsSet.allIndexPaths().isEmpty)

        // containsIndexPath: returns NO for nil and for never-added paths.
        XCTAssertFalse(indexPathsSet.contains(indexPath: nil))
        XCTAssertFalse(indexPathsSet.contains(indexPath: IndexPath(indexes: [0, 0])))

        // Per the decompilation, section queries return nil (not an empty
        // collection) when the section has no entry in the map.
        XCTAssertNil(indexPathsSet.items(inSection: 0))
        XCTAssertNil(indexPathsSet.indexPaths(forSection: 0))
        XCTAssertTrue(indexPathsSet.indexPaths(forSections: IndexSet([0, 1])).isEmpty)
    }

    // MARK: - Single section, add/remove, empty-section cleanup

    func test_singleSection_addAndContains() {
        let indexPathsSet = makeMutableSet()

        indexPathsSet.add(indexPath: IndexPath(indexes: [0, 1]))
        indexPathsSet.add(indexPath: IndexPath(indexes: [0, 3]))
        indexPathsSet.add(indexPath: IndexPath(indexes: [0, 3])) // duplicate add is a no-op
        indexPathsSet.add(indexPath: nil)                        // nil add is a no-op

        XCTAssertEqual(indexPathsSet.count, 2)
        XCTAssertTrue(indexPathsSet.contains(indexPath: IndexPath(indexes: [0, 1])))
        XCTAssertTrue(indexPathsSet.contains(indexPath: IndexPath(indexes: [0, 3])))
        XCTAssertFalse(indexPathsSet.contains(indexPath: IndexPath(indexes: [0, 2])))
        XCTAssertEqual(indexPathsSet.sections(), IndexSet([0]))
        XCTAssertEqual(indexPathsSet.items(inSection: 0), IndexSet([1, 3]))
        XCTAssertEqual(indexPathsSet.firstIndexPath(), IndexPath(indexes: [0, 1]))
        XCTAssertEqual(indexPathsSet.lastIndexPath(), IndexPath(indexes: [0, 3]))
        XCTAssertEqual(indexPathsSet.indexPaths(forSection: 0),
                       [IndexPath(indexes: [0, 1]), IndexPath(indexes: [0, 3])])

        indexPathsSet.remove(indexPath: IndexPath(indexes: [0, 1]))
        XCTAssertEqual(indexPathsSet.count, 1)
        XCTAssertEqual(indexPathsSet.sections(), IndexSet([0]))

        // _removeOneIndexPath: drops the per-section entry once its item set
        // becomes empty (empty-section cleanup, IMP 0x1DBBF958C).
        indexPathsSet.remove(indexPath: IndexPath(indexes: [0, 3]))
        XCTAssertEqual(indexPathsSet.count, 0)
        XCTAssertTrue(indexPathsSet.sections().isEmpty)
        XCTAssertNil(indexPathsSet.items(inSection: 0))
        XCTAssertNil(indexPathsSet.firstIndexPath())

        // Removing from a section that has no entry is a silent no-op.
        indexPathsSet.remove(indexPath: IndexPath(indexes: [4, 0]))
        XCTAssertEqual(indexPathsSet.count, 0)
    }

    // MARK: - Multi section + range mutations + copy semantics

    func test_multiSection_sectionsAndItemsInSection() {
        let indexPathsSet = makeMutableSet([0: [0, 1], 2: [5], 7: [3, 4]])

        XCTAssertEqual(indexPathsSet.count, 5)
        XCTAssertEqual(indexPathsSet.sections(), IndexSet([0, 2, 7]))
        XCTAssertEqual(snapshot(indexPathsSet), [0: [0, 1], 2: [5], 7: [3, 4]])
        XCTAssertEqual(indexPathsSet.firstIndexPath(), IndexPath(indexes: [0, 0]))
        XCTAssertEqual(indexPathsSet.lastIndexPath(), IndexPath(indexes: [7, 4]))
        XCTAssertEqual(Set(indexPathsSet.allIndexPaths()).count, 5)
        XCTAssertEqual(Set(indexPathsSet.indexPaths(forSections: IndexSet([0, 2]))),
                       Set([IndexPath(indexes: [0, 0]), IndexPath(indexes: [0, 1]), IndexPath(indexes: [2, 5])]))

        // addSection:itemsInRange: creates the section entry and adds the range.
        indexPathsSet.addSection(4, itemsInRange: NSRange(location: 2, length: 3))
        XCTAssertEqual(indexPathsSet.items(inSection: 4), IndexSet(2...4))
        XCTAssertEqual(indexPathsSet.count, 8)

        // removeSection:itemsInRange: removes the section entry once emptied.
        indexPathsSet.removeSection(4, itemsInRange: NSRange(location: 0, length: 10))
        XCTAssertEqual(indexPathsSet.sections(), IndexSet([0, 2, 7]))

        // removeSections: drops whole sections at once.
        indexPathsSet.removeSections(IndexSet([0, 7]))
        XCTAssertEqual(snapshot(indexPathsSet), [2: [5]])

        // Copy semantics (verified against the decompilation):
        //   * immutable copyWithZone: returns self (no new allocation)
        //   * mutable copyWithZone: returns an immutable deep snapshot
        //   * mutableCopyWithZone: rebuilds a mutable set from allIndexPaths
        let immutableCopy = indexPathsSet.copyObject()
        XCTAssertEqual(NSStringFromClass(type(of: immutableCopy)), Self.immutableClassName)
        XCTAssertSame(immutableCopy, (immutableCopy as AnyObject).copy() as AnyObject)
        XCTAssertTrue(immutableCopy.isEqual(indexPathsSet))
        XCTAssertTrue(indexPathsSet.isEqual(immutableCopy))

        let mutableCopy = unsafeBitCast(indexPathsSet.mutableCopyObject(), to: IndexPathsSetAPI.self)
        XCTAssertEqual(NSStringFromClass(type(of: mutableCopy as AnyObject)), Self.mutableClassName)
        XCTAssertTrue(mutableCopy.isEqual(indexPathsSet))
        mutableCopy.add(indexPath: IndexPath(indexes: [9, 9]))
        XCTAssertFalse(mutableCopy.isEqual(indexPathsSet)) // deep copy: original untouched
        XCTAssertEqual(snapshot(indexPathsSet), [2: [5]])

        indexPathsSet.removeAllIndexPaths()
        XCTAssertEqual(indexPathsSet.count, 0)
        XCTAssertTrue(indexPathsSet.sections().isEmpty)
    }

    // MARK: - Intersect

    // NOTE: the original plan hypothesis ("intersect sections first, then
    // per-section item indexes") is NOT how UXKit implements this. The real
    // algorithm (IMP 0x1DBBF9E1C) builds `complement = other.mutableCopy`,
    // adds self into it, removes every common index path, and finally calls
    // removeIndexPathsSet:complement — i.e. it subtracts the symmetric
    // difference. The observable result is plain set intersection.
    func test_intersect_keepsOnlyCommonIndexPaths() {
        let indexPathsSet = makeMutableSet([0: [0, 1, 2], 1: [5], 3: [7]])
        let other = makeMutableSet([0: [1, 2, 3], 2: [9]])

        indexPathsSet.intersect(indexPathsSet: other)

        XCTAssertEqual(snapshot(indexPathsSet), [0: [1, 2]])
        // Sections with no surviving items are cleaned up entirely
        // (removeIndexPathsSet: block calls _removeItemIndexesForSection:).
        XCTAssertEqual(indexPathsSet.sections(), IndexSet([0]))
        // The argument set is not mutated.
        XCTAssertEqual(snapshot(other), [0: [1, 2, 3], 2: [9]])

        // Intersect with a disjoint set empties the receiver.
        let disjoint = makeMutableSet([5: [0]])
        indexPathsSet.intersect(indexPathsSet: disjoint)
        XCTAssertEqual(indexPathsSet.count, 0)
        XCTAssertTrue(indexPathsSet.sections().isEmpty)

        // Intersect an empty receiver stays empty.
        indexPathsSet.intersect(indexPathsSet: other)
        XCTAssertEqual(indexPathsSet.count, 0)
    }

    // MARK: - adjustFor* series

    func test_adjustForDeletionInsertion_shiftsTrailingSections() {
        // --- Section deletion: trailing sections shift down by one. ---
        let deletionSet = makeMutableSet([0: [1], 2: [0, 9], 5: [3]])
        deletionSet.adjustForDeletion(ofSection: 1)
        XCTAssertEqual(snapshot(deletionSet), [0: [1], 1: [0, 9], 4: [3]])

        // Deleting a section that itself holds a selection drops that
        // selection; the immediately-following section takes its slot.
        let selectedSectionSet = makeMutableSet([0: [1], 1: [5], 2: [7]])
        selectedSectionSet.adjustForDeletion(ofSection: 1)
        XCTAssertEqual(snapshot(selectedSectionSet), [0: [1], 1: [7]])

        // adjustForDeletionOfSections: processes sections in descending order
        // so earlier shifts never disturb later ones.
        let multiDeletionSet = makeMutableSet([0: [1], 2: [2], 4: [3]])
        multiDeletionSet.adjustForDeletion(ofSections: IndexSet([1, 3]))
        XCTAssertEqual(snapshot(multiDeletionSet), [0: [1], 1: [2], 2: [3]])

        // NSNotFound guard: a deletion/insertion at NSNotFound is a no-op.
        multiDeletionSet.adjustForDeletion(ofSection: NSNotFound)
        multiDeletionSet.adjustForInsertion(ofSection: NSNotFound)
        XCTAssertEqual(snapshot(multiDeletionSet), [0: [1], 1: [2], 2: [3]])

        // --- Section insertion: sections at or after the slot shift up. ---
        let insertionSet = makeMutableSet([0: [1], 1: [5]])
        insertionSet.adjustForInsertion(ofSection: 0)
        XCTAssertEqual(snapshot(insertionSet), [1: [1], 2: [5]])

        // Insertion at an occupied slot shifts that slot too (>= comparison).
        insertionSet.adjustForInsertion(ofSection: 1)
        XCTAssertEqual(snapshot(insertionSet), [2: [1], 3: [5]])

        // Insertion past the last section is a no-op on existing entries.
        insertionSet.adjustForInsertion(ofSection: 9)
        XCTAssertEqual(snapshot(insertionSet), [2: [1], 3: [5]])

        // adjustForInsertionOfSections: processes ascending; each insertion is
        // applied in final (post-insertion) coordinates.
        let multiInsertionSet = makeMutableSet([0: [4], 1: [6]])
        multiInsertionSet.adjustForInsertion(ofSections: IndexSet([0, 2]))
        XCTAssertEqual(snapshot(multiInsertionSet), [1: [4], 3: [6]])

        // --- Item-level deletion: deleted item is removed, trailing shift. ---
        let itemDeletionSet = makeMutableSet([0: [0, 2, 5]])
        itemDeletionSet.adjustForDeletion(ofIndexPath: IndexPath(indexes: [0, 2]))
        XCTAssertEqual(itemDeletionSet.items(inSection: 0), IndexSet([0, 4]))

        // Multi-item deletion enumerates ranges in reverse; original items
        // {0,1,2,3,4,5} minus deleted {1,3} compact to {0,1,2,3}.
        let multiItemDeletionSet = makeMutableSet([0: [0, 1, 2, 3, 4, 5]])
        multiItemDeletionSet.adjustForDeletion(ofItems: IndexSet([1, 3]), inSection: 0)
        XCTAssertEqual(multiItemDeletionSet.items(inSection: 0), IndexSet(0...3))

        // Adjusting a section with no entry is a silent no-op
        // (_itemIndexesForSection:allowingCreation:NO).
        multiItemDeletionSet.adjustForDeletion(ofItems: IndexSet([0]), inSection: 8)
        multiItemDeletionSet.adjustForInsertion(ofItems: IndexSet([0]), inSection: 8)
        XCTAssertEqual(multiItemDeletionSet.sections(), IndexSet([0]))

        // Quirk pinned from the decompilation: unlike removeIndexPath:, the
        // adjust path performs NO empty-section cleanup — the section entry
        // survives with an empty item set.
        let cleanupQuirkSet = makeMutableSet([0: [3]])
        cleanupQuirkSet.adjustForDeletion(ofIndexPath: IndexPath(indexes: [0, 3]))
        XCTAssertEqual(cleanupQuirkSet.count, 0)
        XCTAssertEqual(cleanupQuirkSet.sections(), IndexSet([0]))
        XCTAssertEqual(cleanupQuirkSet.items(inSection: 0), IndexSet())

        // --- Item-level insertion: items at/after the slot shift up. ---
        let itemInsertionSet = makeMutableSet([0: [0, 1, 2]])
        itemInsertionSet.adjustForInsertion(ofIndexPath: IndexPath(indexes: [0, 1]))
        XCTAssertEqual(itemInsertionSet.items(inSection: 0), IndexSet([0, 2, 3]))

        // Multi-item insertion enumerates ranges ascending in final coordinates.
        let multiItemInsertionSet = makeMutableSet([0: [0, 1, 2]])
        multiItemInsertionSet.adjustForInsertion(ofItems: IndexSet([1, 3]), inSection: 0)
        XCTAssertEqual(multiItemInsertionSet.items(inSection: 0), IndexSet([0, 2, 4]))
    }
}

/// XCTAssert helper for object identity across `AnyObject` results.
private func XCTAssertSame(_ lhs: AnyObject, _ rhs: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(lhs === rhs, "expected identical objects", file: file, line: line)
}
