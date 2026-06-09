import XCTest
@testable import OpenUXKit

// UpdateGap merging algorithm tests (Phase P8).
//
// The _computeGaps algorithm merges contiguous delete and insert spans into
// UXCollectionViewUpdateGap objects, which is what allows UXKit to drive fewer
// animations during performBatchUpdates. P0 IDA notes confirm the OpenUXKit
// algorithm is structurally aligned; these tests pin down the behavior.
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/_computeGaps.md
//      Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L1)

final class UpdateGapAlgorithmTests: XCTestCase {

    func test_pureDeleteThenInsert_mergesIntoSingleGap() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P8 — verify delete-based gap absorbs trailing inserts")
    }

    func test_mixedDeleteInsertDelete_emitsTwoGaps() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P8 — non-contiguous operations break the gap")
    }

    func test_sectionBasedOperations_groupSeparatelyFromItemOperations() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P8 — section-level updates form distinct gaps")
    }
}
