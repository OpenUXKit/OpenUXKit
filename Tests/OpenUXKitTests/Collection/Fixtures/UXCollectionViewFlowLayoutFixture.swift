import AppKit
import XCTest
@testable import OpenUXKit

// Fixture builder for UXCollectionViewFlowLayout geometry tests.
//
// Usage:
//     let fixture = UXCollectionViewFlowLayoutFixture()
//     fixture.scrollDirection = .vertical
//     fixture.itemSize = NSSize(width: 80, height: 60)
//     fixture.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//     fixture.sections = [10, 20, 5]                          // section -> item count
//     let (collectionView, layout) = fixture.build()
//     let attrs = layout.layoutAttributesForElements(in: bounds)
//     XCTAssertEqual(attrs[0].frame, ...)
//
// See: Docs/Plans/UXCollectionView-UXKit-Alignment/Plan.md §8 (Tests strategy)
//      Docs/Plans/UXCollectionView-UXKit-Alignment/IDA-Notes/00-Summary.md §3 (_getSizingInfos)

final class UXCollectionViewFlowLayoutFixture: NSObject, UXCollectionViewDataSource, UXCollectionViewDelegateFlowLayout {

    // MARK: - Configuration

    var scrollDirection: UXCollectionView.ScrollDirection = .vertical
    var itemSize: NSSize = NSSize(width: 50, height: 50)
    var sectionInset: NSEdgeInsets = NSEdgeInsets()
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    var headerReferenceSize: NSSize = .zero
    var footerReferenceSize: NSSize = .zero

    /// Items per section (e.g. `[10, 20, 5]` = 3 sections with 10/20/5 items).
    var sections: [Int] = [1]

    /// Per-(section,item) size override; falls back to `itemSize` when nil.
    var itemSizeOverrides: [IndexPath: NSSize] = [:]

    /// Per-section inset override; falls back to `sectionInset` when nil.
    var sectionInsetOverrides: [Int: NSEdgeInsets] = [:]

    /// Frame applied to the fabricated collection view; controls dimension and wrapping.
    var collectionViewFrame: NSRect = NSRect(x: 0, y: 0, width: 320, height: 480)

    // MARK: - Build

    @MainActor
    func build() -> (collectionView: UXCollectionView, layout: UXCollectionViewFlowLayout) {
        let layout = UXCollectionViewFlowLayout()
        // TODO(uxkit-align): wire scrollDirection/itemSize/spacing once UXCollectionViewFlowLayout
        //                    exposes them via the Public API contract (see PublicAPIContract.md).
        let collectionView = UXCollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        return (collectionView, layout)
    }

    // MARK: - UXCollectionViewDataSource

    func numberOfSections(in collectionView: UXCollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section]
    }

    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        UXCollectionViewCell()
    }

    // MARK: - UXCollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        itemSizeOverrides[indexPath] ?? itemSize
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        sectionInsetOverrides[section] ?? sectionInset
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacing
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacing
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        headerReferenceSize
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        footerReferenceSize
    }
}
