import AppKit
import XCTest
@testable import OpenUXKit

// Selection algorithm tests (Phase P9).
//
// Covers:
//   - single selection (allowsMultipleSelection = false)
//   - multi selection (allowsMultipleSelection = true, extending via Shift/Cmd)
//   - lasso selection (allowsLassoSelection)
//   - keyboard range selection (Shift + Arrow)
//
// Selection state lives in UXCollectionViewMutableIndexPathsSet; algorithms
// are 4-way branched on (extending? × animated? × notifyDelegate?).
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §3 S8

final class SelectionAlgorithmTests: XCTestCase {

    func test_singleSelection_replacesPreviousSelection() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P9 — allowsMultipleSelection=false")
    }

    func test_multiSelection_extendingAddsToSelection() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P9 — selectItemsAtIndexPaths:byExtendingSelection:YES")
    }

    func test_lassoSelection_invertsWhenLassoInvertsSelectionIsTrue() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P9 — lassoInvertsSelection")
    }

    func test_keyboardRangeSelection_anchorsAtPreviousSelectionPivot() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P9 — Shift+Arrow vs _lastSelectionAnchorIndexPath")
    }
}
