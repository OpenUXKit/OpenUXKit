//
//  ShowcaseCollection.swift
//  OpenUXKit-Example-Swift
//
//  Exercises the entire UXCollectionView surface: layout, layout attributes,
//  flow layout, flow layout invalidation context, data source, delegate,
//  delegate flow layout, cell + reusable view registration, and selection.
//

import Cocoa
#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#else
#error("")
#endif

private let demoCellIdentifier = "DemoCell"
private let demoHeaderIdentifier = "DemoHeader"
// UXKit's flow layout tags section headers with this kind internally — the
// same constant Apple's private UXKit uses — so registration and dequeue must
// match exactly. The kind is not exposed as a public symbol from OpenUXKit, so
// we declare it ourselves.
private let demoHeaderKind = "UXCollectionViewElementKindSectionHeader"

// MARK: - UXCollectionView (standalone)

final class UXCollectionViewShowcaseViewController: UXViewController, UXCollectionViewDataSource, UXCollectionViewDelegate, UXCollectionViewDelegateFlowLayout {
    private let sections: [(title: String, colors: [NSColor])] = [
        ("Cool blues", [.systemBlue, .systemTeal, .systemCyan, .systemIndigo, .systemMint]),
        ("Warm reds", [.systemRed, .systemOrange, .systemYellow, .systemPink]),
        ("Pastel greens", [.systemGreen, .systemMint, .systemTeal]),
    ]

    private lazy var layout: UXCollectionViewFlowLayout = {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = NSEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        layout.itemSize = NSSize(width: 96, height: 96)
        layout.headerReferenceSize = NSSize(width: 0, height: 36)
        return layout
    }()

    private lazy var collectionView: UXCollectionView = {
        let collectionView = UXCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        collectionView.allowsEmptySelection = true
        collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
        collectionView.register(SwatchHeader.self, forSupplementaryViewOfKind: demoHeaderKind, withReuseIdentifier: demoHeaderIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXCollectionView"
        navigationItem?.rightBarButtonItem = UXBarButtonItem(title: "Reload", style: .bordered, target: self, action: #selector(reload))
        uxView.backgroundColor = ShowcasePalette.surface

        pinFillingUXView(collectionView, in: self)
    }

    @objc private func reload() {
        let context = UXCollectionViewFlowLayoutInvalidationContext()
        context.invalidateFlowLayoutDelegateMetrics = true
        layout.invalidateLayout(with: context)
        collectionView.reloadData()
    }

    // MARK: UXCollectionViewDataSource
    func numberOfSections(in collectionView: UXCollectionView) -> Int { sections.count }
    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].colors.count
    }
    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! SwatchCell
        let color = sections[indexPath.section].colors[indexPath.item]
        cell.configure(color: color, label: String(format: "%d-%d", indexPath.section, indexPath.item))
        return cell
    }
    func collectionView(_ collectionView: UXCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UXCollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: demoHeaderIdentifier, for: indexPath) as! SwatchHeader
        view.titleLabel.text = sections[indexPath.section].title
        return view
    }

    // MARK: UXCollectionViewDelegate
    func collectionView(_ collectionView: UXCollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem?.prompt = "Selected → section \(indexPath.section), item \(indexPath.item)"
    }
    func collectionView(_ collectionView: UXCollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForSelectedItems()?.isEmpty ?? true {
            navigationItem?.prompt = nil
        }
    }

    // MARK: UXCollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let columns: CGFloat = 5
        let spacing = (self.layout.minimumInteritemSpacing) * (columns - 1)
        let inset = self.layout.sectionInset.left + self.layout.sectionInset.right
        let width = max(80, (collectionView.bounds.width - spacing - inset) / columns)
        return NSSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        NSSize(width: collectionView.bounds.width, height: 36)
    }
}

private final class SwatchCell: UXCollectionViewCell {
    private let badge = UXLabel()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 10
        contentView.layer?.borderColor = NSColor.controlAccentColor.cgColor

        badge.font = .systemFont(ofSize: 12, weight: .semibold)
        badge.textAlignment = .center
        badge.textColor = .white
        badge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(badge)
        NSLayoutConstraint.activate([
            badge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            badge.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(color: NSColor, label: String) {
        contentView.layer?.backgroundColor = color.cgColor
        badge.text = label
    }

    override var isSelected: Bool {
        didSet {
            contentView.layer?.borderWidth = isSelected ? 3 : 0
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }
}

private final class SwatchHeader: UXCollectionReusableView {
    let titleLabel = UXLabel()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = ShowcasePalette.onSurface
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UXCollectionViewController subclass

final class UXCollectionViewControllerShowcaseViewController: UXCollectionViewController {
    private let entries: [String] = (1...40).map { "Item #\($0)" }

    init() {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = .init()
        super.init(collectionViewLayout: layout)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXCollectionViewController"
        uxView.backgroundColor = ShowcasePalette.surface

        collectionView.allowsSelection = true
        collectionView.register(RowCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
    }

    override func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        entries.count
    }

    override func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! RowCell
        cell.configure(text: entries[indexPath.item])
        return cell
    }

    override func collectionView(_ collectionView: UXCollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationItem?.prompt = "Tapped \(entries[indexPath.item])"
    }
}

extension UXCollectionViewControllerShowcaseViewController: UXCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        NSSize(width: collectionView.bounds.width, height: 44)
    }
}

private final class RowCell: UXCollectionViewCell {
    private let label = UXLabel()
    private let separator = UXView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = ShowcasePalette.panel.cgColor

        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = ShowcasePalette.onSurface
        label.translatesAutoresizingMaskIntoConstraints = false

        separator.backgroundColor = NSColor.separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)
        contentView.addSubview(separator)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String) {
        label.text = text
    }

    override var isSelected: Bool {
        didSet {
            contentView.layer?.backgroundColor = isSelected
                ? ShowcasePalette.primary.withAlphaComponent(0.15).cgColor
                : ShowcasePalette.panel.cgColor
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isSelected = false
    }
}

// MARK: - Horizontal scroll

final class UXCollectionViewHorizontalShowcaseViewController: UXViewController, UXCollectionViewDataSource, UXCollectionViewDelegate, UXCollectionViewDelegateFlowLayout {
    private let palette: [NSColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemMint,
        .systemTeal, .systemCyan, .systemBlue, .systemIndigo, .systemPurple,
        .systemPink, .systemBrown, .systemGray, .systemRed, .systemOrange,
        .systemYellow, .systemGreen, .systemTeal, .systemBlue, .systemPurple,
    ]

    private lazy var layout: UXCollectionViewFlowLayout = {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = NSEdgeInsets(top: 16, left: 24, bottom: 16, right: 24)
        layout.headerReferenceSize = NSSize(width: 60, height: 0)
        layout.footerReferenceSize = NSSize(width: 60, height: 0)
        return layout
    }()

    private lazy var collectionView: UXCollectionView = {
        let collectionView = UXCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
        collectionView.register(EdgeBadge.self, forSupplementaryViewOfKind: "UXCollectionViewElementKindSectionHeader", withReuseIdentifier: "EdgeHeader")
        collectionView.register(EdgeBadge.self, forSupplementaryViewOfKind: "UXCollectionViewElementKindSectionFooter", withReuseIdentifier: "EdgeFooter")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Horizontal flow"
        navigationItem?.prompt = "Scroll horizontally — items stack vertically per column"
        uxView.backgroundColor = ShowcasePalette.surface
        pinFillingUXView(collectionView, in: self)
    }

    func numberOfSections(in collectionView: UXCollectionView) -> Int { 2 }
    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? 12 : 8
    }
    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! SwatchCell
        cell.configure(color: palette[(indexPath.section * 10 + indexPath.item) % palette.count],
                       label: String(format: "%d-%d", indexPath.section, indexPath.item))
        return cell
    }
    func collectionView(_ collectionView: UXCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UXCollectionReusableView {
        let identifier = kind.hasSuffix("Footer") ? "EdgeFooter" : "EdgeHeader"
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! EdgeBadge
        view.configure(text: identifier == "EdgeHeader" ? "S\(indexPath.section)\nHEAD" : "S\(indexPath.section)\nFOOT",
                       color: identifier == "EdgeHeader" ? ShowcasePalette.primary : ShowcasePalette.accent)
        return view
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let crossSpace = collectionView.bounds.height - self.layout.sectionInset.top - self.layout.sectionInset.bottom
        let rows: CGFloat = 3
        let gap = self.layout.minimumInteritemSpacing * (rows - 1)
        let side = max(60, (crossSpace - gap) / rows)
        return NSSize(width: side, height: side)
    }
}

// MARK: - Variable-size cells

final class UXCollectionViewMixedSizeShowcaseViewController: UXViewController, UXCollectionViewDataSource, UXCollectionViewDelegate, UXCollectionViewDelegateFlowLayout {
    private struct Tile { let color: NSColor; let weight: CGFloat }
    private let tiles: [Tile] = [
        Tile(color: .systemRed, weight: 2),
        Tile(color: .systemOrange, weight: 1),
        Tile(color: .systemYellow, weight: 1),
        Tile(color: .systemGreen, weight: 3),
        Tile(color: .systemTeal, weight: 1),
        Tile(color: .systemBlue, weight: 2),
        Tile(color: .systemIndigo, weight: 1),
        Tile(color: .systemPurple, weight: 2),
        Tile(color: .systemPink, weight: 1),
        Tile(color: .systemMint, weight: 3),
        Tile(color: .systemBrown, weight: 1),
        Tile(color: .systemCyan, weight: 2),
        Tile(color: .systemGray, weight: 1),
        Tile(color: .systemRed, weight: 1),
        Tile(color: .systemBlue, weight: 1),
    ]

    private lazy var layout: UXCollectionViewFlowLayout = {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return layout
    }()

    private lazy var collectionView: UXCollectionView = {
        let collectionView = UXCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Mixed sizes"
        navigationItem?.prompt = "Different widths share a row; height tracks tallest item"
        uxView.backgroundColor = ShowcasePalette.surface
        pinFillingUXView(collectionView, in: self)
    }

    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int { tiles.count }
    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let tile = tiles[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! SwatchCell
        cell.configure(color: tile.color, label: "w\(Int(tile.weight))")
        return cell
    }
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        let tile = tiles[indexPath.item]
        let unit: CGFloat = 80
        return NSSize(width: unit * tile.weight, height: unit + CGFloat((indexPath.item % 3) * 12))
    }
}

// MARK: - Per-section metrics + footer

final class UXCollectionViewMultiMetricsShowcaseViewController: UXViewController, UXCollectionViewDataSource, UXCollectionViewDelegate, UXCollectionViewDelegateFlowLayout {
    private let sectionPalettes: [(title: String, colors: [NSColor], interitem: CGFloat, line: CGFloat, inset: NSEdgeInsets)] = [
        ("Tight grid", Array(repeating: .systemBlue, count: 9), 4, 4, NSEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)),
        ("Wide gaps", Array(repeating: .systemOrange, count: 6), 24, 24, NSEdgeInsets(top: 24, left: 32, bottom: 24, right: 32)),
        ("Asymmetric", Array(repeating: .systemGreen, count: 7), 8, 20, NSEdgeInsets(top: 4, left: 48, bottom: 28, right: 8)),
    ]

    private lazy var layout: UXCollectionViewFlowLayout = {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = NSSize(width: 80, height: 80)
        return layout
    }()

    private lazy var collectionView: UXCollectionView = {
        let collectionView = UXCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
        collectionView.register(EdgeBadge.self, forSupplementaryViewOfKind: "UXCollectionViewElementKindSectionHeader", withReuseIdentifier: "MetricsHeader")
        collectionView.register(EdgeBadge.self, forSupplementaryViewOfKind: "UXCollectionViewElementKindSectionFooter", withReuseIdentifier: "MetricsFooter")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Per-section metrics"
        navigationItem?.prompt = "Each section uses its own insets, spacings, and a footer"
        uxView.backgroundColor = ShowcasePalette.surface
        pinFillingUXView(collectionView, in: self)
    }

    func numberOfSections(in collectionView: UXCollectionView) -> Int { sectionPalettes.count }
    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionPalettes[section].colors.count
    }
    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! SwatchCell
        cell.configure(color: sectionPalettes[indexPath.section].colors[indexPath.item],
                       label: "\(indexPath.section).\(indexPath.item)")
        return cell
    }
    func collectionView(_ collectionView: UXCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UXCollectionReusableView {
        let isFooter = kind.hasSuffix("Footer")
        let identifier = isFooter ? "MetricsFooter" : "MetricsHeader"
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier, for: indexPath) as! EdgeBadge
        let title = isFooter ? "\(sectionPalettes[indexPath.section].title) · footer" : sectionPalettes[indexPath.section].title
        view.configure(text: title, color: isFooter ? ShowcasePalette.muted : ShowcasePalette.primary)
        return view
    }

    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        sectionPalettes[section].inset
    }
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionPalettes[section].line
    }
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        sectionPalettes[section].interitem
    }
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        NSSize(width: collectionView.bounds.width, height: 32)
    }
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        NSSize(width: collectionView.bounds.width, height: section == 1 ? 0 : 20)
    }
}

// MARK: - Edge cases

final class UXCollectionViewEdgeCasesShowcaseViewController: UXViewController, UXCollectionViewDataSource, UXCollectionViewDelegate, UXCollectionViewDelegateFlowLayout {
    private var sectionCounts: [Int] = [3, 0, 5, 1, 0, 7]

    private lazy var layout: UXCollectionViewFlowLayout = {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = NSEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.itemSize = NSSize(width: 64, height: 64)
        layout.headerReferenceSize = NSSize(width: 0, height: 28)
        return layout
    }()

    private lazy var collectionView: UXCollectionView = {
        let collectionView = UXCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
        collectionView.register(EdgeBadge.self, forSupplementaryViewOfKind: "UXCollectionViewElementKindSectionHeader", withReuseIdentifier: "EdgeHeader")
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Edge cases"
        navigationItem?.prompt = "Empty sections, single-item sections, default itemSize (no delegate)"
        navigationItem?.rightBarButtonItem = UXBarButtonItem(title: "Shuffle", style: .bordered, target: self, action: #selector(shuffle))
        uxView.backgroundColor = ShowcasePalette.surface
        pinFillingUXView(collectionView, in: self)
    }

    @objc private func shuffle() {
        sectionCounts.shuffle()
        collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UXCollectionView) -> Int { sectionCounts.count }
    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionCounts[section]
    }
    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! SwatchCell
        let hues: [NSColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple]
        cell.configure(color: hues[(indexPath.section + indexPath.item) % hues.count],
                       label: "\(indexPath.section)·\(indexPath.item)")
        return cell
    }
    func collectionView(_ collectionView: UXCollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UXCollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EdgeHeader", for: indexPath) as! EdgeBadge
        view.configure(text: "Section \(indexPath.section) — \(sectionCounts[indexPath.section]) item(s)", color: ShowcasePalette.primary)
        return view
    }
}

// MARK: - Drag to rearrange

final class UXCollectionViewRearrangingShowcaseViewController: UXViewController, UXCollectionViewDataSource, UXCollectionViewDelegateFlowLayout {
    // Mutable model the rearranging coordinator reorders through the data source.
    private var items: [(color: NSColor, label: String)] = {
        let palette: [NSColor] = [
            .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemMint,
            .systemTeal, .systemCyan, .systemBlue, .systemIndigo, .systemPurple,
            .systemPink, .systemBrown,
        ]
        return palette.enumerated().map { ($0.element, "\($0.offset)") }
    }()

    private lazy var layout: UXCollectionViewFlowLayout = {
        let layout = UXCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.itemSize = NSSize(width: 96, height: 96)
        return layout
    }()

    private lazy var collectionView: UXCollectionView = {
        let collectionView = UXCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        // Drag the clicked item directly (the coordinator drags the selection
        // when selection is enabled, so disable it here for a clearer demo).
        collectionView.allowsSelection = false
        collectionView.register(SwatchCell.self, forCellWithReuseIdentifier: demoCellIdentifier)
        // Installs the internal _UXCollectionViewRearrangingCoordinator.
        collectionView.rearrangingEnabled_ = true
        collectionView.rearrangingAllowAutoscroll_ = true
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Drag to rearrange"
        navigationItem?.prompt = "Drag a cell to reorder; the data source moveItemsAtIndexPaths:toIndexPath: commits the new order"
        uxView.backgroundColor = ShowcasePalette.surface
        pinFillingUXView(collectionView, in: self)
    }

    // MARK: UXCollectionViewDataSource
    func collectionView(_ collectionView: UXCollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    func collectionView(_ collectionView: UXCollectionView, cellForItemAt indexPath: IndexPath) -> UXCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: demoCellIdentifier, for: indexPath) as! SwatchCell
        let item = items[indexPath.item]
        cell.configure(color: item.color, label: item.label)
        return cell
    }

    // MARK: Rearranging data source (informal UXCollectionViewDataSource_Rearranging)
    @objc(collectionView:canMoveItemsAtIndexPaths:)
    func collectionView(_ collectionView: UXCollectionView, canMoveItemsAtIndexPaths indexPaths: [IndexPath]) -> Bool {
        true
    }

    // The coordinator only commits a move when the allowed drop positions include
    // UXKit's "on" bit (0x4); return it so any drop target accepts the reorder.
    @objc(collectionView:allowedDropPositionsForItemsAtIndexPaths:movedToIndexPath:)
    func collectionView(_ collectionView: UXCollectionView, allowedDropPositionsForItemsAtIndexPaths indexPaths: [IndexPath], movedToIndexPath indexPath: IndexPath) -> Int {
        4
    }

    @objc(collectionView:moveItemsAtIndexPaths:toIndexPath:dropPosition:)
    func collectionView(_ collectionView: UXCollectionView, moveItemsAtIndexPaths indexPaths: [IndexPath], toIndexPath destinationIndexPath: IndexPath, dropPosition: Int) -> Bool {
        let sourceItemIndexes = indexPaths.map { $0.item }.sorted()
        guard !sourceItemIndexes.isEmpty else { return false }
        let movedItems = sourceItemIndexes.map { items[$0] }
        var reordered = items
        for sourceItemIndex in sourceItemIndexes.reversed() {
            reordered.remove(at: sourceItemIndex)
        }
        let removedBeforeDestination = sourceItemIndexes.filter { $0 < destinationIndexPath.item }.count
        let insertionIndex = min(max(0, destinationIndexPath.item - removedBeforeDestination), reordered.count)
        reordered.insert(contentsOf: movedItems, at: insertionIndex)
        items = reordered
        navigationItem?.prompt = "Moved \(indexPaths.count) item(s) → \(destinationIndexPath.item)"
        // The coordinator commits the model here; refresh the cells in the new
        // order (the live-drag gap layout proxy is not yet ported).
        collectionView.reloadData()
        return true
    }

    // MARK: UXCollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UXCollectionView, layout: UXCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        NSSize(width: 96, height: 96)
    }
}

// MARK: - Shared supplementary view

private final class EdgeBadge: UXCollectionReusableView {
    let label = UXLabel()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 6
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String, color: NSColor) {
        label.text = text
        layer?.backgroundColor = color.cgColor
    }
}
