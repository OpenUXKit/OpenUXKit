import XCTest
@testable import OpenUXKit

// IndexPathsSet pure-algorithm tests (Phase P7).
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L1)
//      Docs/Plans/UXCollectionView-UXKit-Alignment/AlignmentMatrix.md §S4

final class IndexPathsSetTests: XCTestCase {

    func test_emptySet_hasZeroCountAndNilFirstLast() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P7 — UXCollectionViewIndexPathsSet algorithm alignment")
    }

    func test_singleSection_addAndContains() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P7")
    }

    func test_multiSection_sectionsAndItemsInSection() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P7")
    }

    func test_intersect_byPerSectionThenItemIndexes() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P7 — verify intersect computes per-section first")
    }

    func test_adjustForDeletionInsertion_shiftsTrailingSections() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P7 — adjustForDeletionOfSection / adjustForInsertionOfSection")
    }
}
