import AppKit
import XCTest
@testable import OpenUXKit

// FlowLayout geometry snapshot tests (Phase P4 / P5).
//
// Each test feeds a UXCollectionViewFlowLayoutFixture into the layout and
// asserts the resulting layoutAttributesForElements(in:) frames. Acceptable
// tolerance is 0.5pt (backing-aligned scale rounding via _AdjustToScale).
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/00-Summary.md §3
//      Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L3)

final class FlowLayoutGeometryTests: XCTestCase {

    func test_verticalFlow_uniformItems_wrapsAccordingToContainerWidth() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P4 — corresponds to UXCollectionViewShowcase scene")
    }

    func test_horizontalFlow_uniformItems_wrapsAccordingToContainerHeight() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P4 — corresponds to UXCollectionViewHorizontalShowcase scene")
    }

    func test_mixedItemSizes_respectsPerItemSizeFromDelegate() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P4 — corresponds to UXCollectionViewMixedSizeShowcase scene")
    }

    func test_perSectionMetrics_respectsPerSectionInsetSpacingHeaderFooter() throws {
        throw XCTSkip("TODO(uxkit-align): implement at Phase P4 — corresponds to UXCollectionViewMultiMetricsShowcase scene")
    }
}
