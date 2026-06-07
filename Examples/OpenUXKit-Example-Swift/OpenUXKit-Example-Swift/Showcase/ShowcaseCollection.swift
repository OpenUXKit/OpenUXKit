//
//  ShowcaseCollection.swift
//  OpenUXKit-Example-Swift
//
//  Exercises the entire UXCollectionView surface: layout, layout attributes,
//  flow layout, flow layout invalidation context, data source, delegate,
//  delegate flow layout, cell + reusable view registration, and selection.
//

import Cocoa
import OpenUXKit

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
        // Sub-pixel jitter defeats UXCollectionViewFlowLayout's "all items same
        // size" shortcut, which empties section.items and trips an out-of-bounds
        // access in _UXFlowLayoutInfo.frameForItemAtIndexPath:. The +0.0001 px
        // delta is invisible but keeps each item on the variable-size path.
        let jitter = CGFloat(indexPath.item & 1) * 0.0001
        return NSSize(width: width + jitter, height: width)
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
        // Sub-pixel jitter keeps the flow layout off the broken "all items same
        // size" fast path (see UXCollectionViewShowcaseViewController).
        let jitter = CGFloat(indexPath.item & 1) * 0.0001
        return NSSize(width: collectionView.bounds.width + jitter, height: 44)
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
