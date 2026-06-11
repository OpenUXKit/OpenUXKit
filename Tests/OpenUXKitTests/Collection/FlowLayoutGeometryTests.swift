import AppKit
import XCTest
@testable import OpenUXKit

// FlowLayout geometry snapshot tests (Phase P4 / P5).
//
// Each test feeds a UXCollectionViewFlowLayoutFixture into the layout and
// asserts the resulting layoutAttributesForElements(in:) frames. All fixtures
// are chosen so every expected coordinate is integral, which makes the
// backing-aligned rounding (_AdjustToScale) a no-op on any screen scale.
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/00-Summary.md §3
//      Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/P5-Data.md
//      Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy, L3)

@MainActor
final class FlowLayoutGeometryTests: XCTestCase {

    private func cellFrames(in attributes: [UXCollectionViewLayoutAttributes]) -> [IndexPath: CGRect] {
        var frames: [IndexPath: CGRect] = [:]
        for attribute in attributes where attribute.representedElementCategory == .cell {
            frames[attribute.indexPath as IndexPath] = attribute.frame
        }
        return frames
    }

    /// UXCollectionViewShowcase scene: vertical flow, uniform 50x50 items in a
    /// 320pt wide container. Complete rows justify (alignment 3 -> 4pt gaps);
    /// the incomplete last row keeps the same grid (lastRow alignment 0 with
    /// the fixedItemSize grid-preserving gap).
    func test_verticalFlow_uniformItems_wrapsAccordingToContainerWidth() throws {
        let fixture = UXCollectionViewFlowLayoutFixture()
        fixture.scrollDirection = .vertical
        fixture.itemSize = NSSize(width: 50, height: 50)
        fixture.sections = [10]
        fixture.collectionViewFrame = NSRect(x: 0, y: 0, width: 320, height: 480)
        let (_, layout) = fixture.build()

        let attributes = try XCTUnwrap(layout.layoutAttributesForElements(in: NSRect(x: 0, y: 0, width: 320, height: 480)))
        let frames = cellFrames(in: attributes)
        XCTAssertEqual(frames.count, 10)

        // Row 0 (complete, justified): 6 items, 20pt leftover over 5 gaps.
        let expectedRowZeroX: [CGFloat] = [0, 54, 108, 162, 216, 270]
        for (itemIndex, expectedX) in expectedRowZeroX.enumerated() {
            let frame = try XCTUnwrap(frames[IndexPath(item: itemIndex, section: 0)])
            XCTAssertEqual(frame, CGRect(x: expectedX, y: 0, width: 50, height: 50), "item \(itemIndex)")
        }
        // Row 1 (incomplete): keeps the 54pt grid pitch of the complete rows.
        let expectedRowOneX: [CGFloat] = [0, 54, 108, 162]
        for (offset, expectedX) in expectedRowOneX.enumerated() {
            let itemIndex = 6 + offset
            let frame = try XCTUnwrap(frames[IndexPath(item: itemIndex, section: 0)])
            XCTAssertEqual(frame, CGRect(x: expectedX, y: 50, width: 50, height: 50), "item \(itemIndex)")
        }
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 100))
    }

    /// UXCollectionViewHorizontalShowcase scene: horizontal flow in a 450pt
    /// high container; 9 items fill one column exactly, the 10th starts the
    /// next column at the top.
    func test_horizontalFlow_uniformItems_wrapsAccordingToContainerHeight() throws {
        let fixture = UXCollectionViewFlowLayoutFixture()
        fixture.scrollDirection = .horizontal
        fixture.itemSize = NSSize(width: 50, height: 50)
        fixture.sections = [10]
        fixture.collectionViewFrame = NSRect(x: 0, y: 0, width: 320, height: 450)
        let (_, layout) = fixture.build()

        let attributes = try XCTUnwrap(layout.layoutAttributesForElements(in: NSRect(x: 0, y: 0, width: 1000, height: 450)))
        let frames = cellFrames(in: attributes)
        XCTAssertEqual(frames.count, 10)

        for itemIndex in 0..<9 {
            let frame = try XCTUnwrap(frames[IndexPath(item: itemIndex, section: 0)])
            XCTAssertEqual(frame, CGRect(x: 0, y: CGFloat(itemIndex) * 50, width: 50, height: 50), "item \(itemIndex)")
        }
        let lastFrame = try XCTUnwrap(frames[IndexPath(item: 9, section: 0)])
        XCTAssertEqual(lastFrame, CGRect(x: 50, y: 0, width: 50, height: 50))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 100, height: 450))
    }

    /// UXCollectionViewMixedSizeShowcase scene: per-item delegate sizes; the
    /// complete first row justifies its 30pt leftover into two 15pt gaps and
    /// centers items vertically inside the 60pt row.
    func test_mixedItemSizes_respectsPerItemSizeFromDelegate() throws {
        let fixture = UXCollectionViewFlowLayoutFixture()
        fixture.scrollDirection = .vertical
        fixture.sections = [4]
        fixture.itemSizeOverrides = [
            IndexPath(item: 0, section: 0): NSSize(width: 100, height: 40),
            IndexPath(item: 1, section: 0): NSSize(width: 80, height: 60),
            IndexPath(item: 2, section: 0): NSSize(width: 90, height: 50),
            IndexPath(item: 3, section: 0): NSSize(width: 50, height: 50),
        ]
        fixture.collectionViewFrame = NSRect(x: 0, y: 0, width: 300, height: 480)
        let (_, layout) = fixture.build()

        let attributes = try XCTUnwrap(layout.layoutAttributesForElements(in: NSRect(x: 0, y: 0, width: 300, height: 480)))
        let frames = cellFrames(in: attributes)
        XCTAssertEqual(frames.count, 4)

        // Row 0: 100 + 80 + 90 = 270 of 300 -> two justified 15pt gaps;
        // vertical alignment 1 centers each item in the 60pt-high row.
        XCTAssertEqual(frames[IndexPath(item: 0, section: 0)], CGRect(x: 0, y: 10, width: 100, height: 40))
        XCTAssertEqual(frames[IndexPath(item: 1, section: 0)], CGRect(x: 115, y: 0, width: 80, height: 60))
        XCTAssertEqual(frames[IndexPath(item: 2, section: 0)], CGRect(x: 210, y: 5, width: 90, height: 50))
        // Row 1: incomplete, lastRow alignment 0 -> leading edge.
        XCTAssertEqual(frames[IndexPath(item: 3, section: 0)], CGRect(x: 0, y: 60, width: 50, height: 50))
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 300, height: 110))
    }

    /// UXCollectionViewMultiMetricsShowcase scene: per-section insets plus
    /// headers and footers; sections stack along the scroll axis and each
    /// section places its row below `inset.top + headerDimension`.
    func test_perSectionMetrics_respectsPerSectionInsetSpacingHeaderFooter() throws {
        let fixture = UXCollectionViewFlowLayoutFixture()
        fixture.scrollDirection = .vertical
        fixture.sections = [3, 3]
        fixture.itemSizeOverrides = [
            IndexPath(item: 0, section: 0): NSSize(width: 75, height: 40),
            IndexPath(item: 1, section: 0): NSSize(width: 75, height: 40),
            IndexPath(item: 2, section: 0): NSSize(width: 75, height: 40),
            IndexPath(item: 0, section: 1): NSSize(width: 70, height: 40),
            IndexPath(item: 1, section: 1): NSSize(width: 70, height: 40),
            IndexPath(item: 2, section: 1): NSSize(width: 70, height: 40),
        ]
        fixture.sectionInsetOverrides = [
            0: NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
            1: NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
        ]
        fixture.headerReferenceSize = NSSize(width: 320, height: 30)
        fixture.footerReferenceSize = NSSize(width: 320, height: 20)
        fixture.collectionViewFrame = NSRect(x: 0, y: 0, width: 320, height: 480)
        let (_, layout) = fixture.build()

        let attributes = try XCTUnwrap(layout.layoutAttributesForElements(in: NSRect(x: 0, y: 0, width: 320, height: 480)))
        let frames = cellFrames(in: attributes)
        XCTAssertEqual(frames.count, 6)

        // Section 0: row sits below top inset (10) + header (30); the
        // fixedItemSize grid spreads three 75pt items at a 75pt pitch.
        XCTAssertEqual(frames[IndexPath(item: 0, section: 0)], CGRect(x: 10, y: 40, width: 75, height: 40))
        XCTAssertEqual(frames[IndexPath(item: 1, section: 0)], CGRect(x: 85, y: 40, width: 75, height: 40))
        XCTAssertEqual(frames[IndexPath(item: 2, section: 0)], CGRect(x: 160, y: 40, width: 75, height: 40))

        // Section 0 height: 10 + 30 + 40 + 10 + 20 (footer) = 110.
        // Section 1: origin 110, row below inset (20) + header (30).
        XCTAssertEqual(frames[IndexPath(item: 0, section: 1)], CGRect(x: 20, y: 160, width: 70, height: 40))
        XCTAssertEqual(frames[IndexPath(item: 1, section: 1)], CGRect(x: 90, y: 160, width: 70, height: 40))
        XCTAssertEqual(frames[IndexPath(item: 2, section: 1)], CGRect(x: 160, y: 160, width: 70, height: 40))

        // Headers and footers (kind + frame).
        let supplementary = attributes.filter { $0.representedElementCategory == .supplementaryView }
        XCTAssertEqual(supplementary.count, 4)
        let headerFrames = supplementary
            .filter { $0.representedElementKind == "UXCollectionViewElementKindSectionHeader" }
            .sorted { $0.indexPath.section < $1.indexPath.section }
            .map(\.frame)
        XCTAssertEqual(headerFrames, [
            CGRect(x: 0, y: 0, width: 320, height: 30),
            CGRect(x: 0, y: 110, width: 320, height: 30),
        ])
        let footerFrames = supplementary
            .filter { $0.representedElementKind == "UXCollectionViewElementKindSectionFooter" }
            .sorted { $0.indexPath.section < $1.indexPath.section }
            .map(\.frame)
        XCTAssertEqual(footerFrames, [
            CGRect(x: 0, y: 90, width: 320, height: 20),
            CGRect(x: 0, y: 220, width: 320, height: 20),
        ])
        XCTAssertEqual(layout.collectionViewContentSize(), CGSize(width: 320, height: 240))
    }
}
