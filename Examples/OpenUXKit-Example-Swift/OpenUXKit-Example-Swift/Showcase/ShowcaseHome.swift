//
//  ShowcaseHome.swift
//  OpenUXKit-Example-Swift
//
//  Root list that lets users jump into individual demos. The list itself is
//  a UXViewController with an NSScrollView + NSStackView, intentionally kept
//  simple so the UXCollectionView demo can focus on the collection API.
//

import Cocoa
import OpenUXKit

final class ShowcaseHomeViewController: UXViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem?.title = "OpenUXKit Showcase"
        navigationItem?.prompt = "Tap any row to push a demo"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)

        for (sectionIndex, section) in ShowcaseCatalog.sections.enumerated() {
            if sectionIndex > 0 {
                stack.setCustomSpacing(28, after: stack.arrangedSubviews.last!)
            }
            let header = UXLabel().then {
                $0.text = section.title
                $0.font = .preferredFont(forTextStyle: .title2)
                $0.textColor = ShowcasePalette.onSurface
            }
            stack.addArrangedSubview(header)

            for demo in section.demos {
                let row = ShowcaseDemoRow(demo: demo)
                row.onClick = { [weak self] in
                    guard let self else { return }
                    self.navigationController?.pushViewController(demo.make(), animated: true)
                }
                stack.addArrangedSubview(row)
                row.widthAnchor.constraint(equalTo: stack.widthAnchor, constant: -48).isActive = true
            }
        }
    }
}

/// A clickable card used as a list row. Subclasses UXControl so the demo
/// exercises UXControl's target/action plumbing directly.
final class ShowcaseDemoRow: UXControl {
    private let titleLabel = UXLabel()
    private let subtitleLabel = UXLabel()
    private let chevron = UXImageView()
    var onClick: (() -> Void)?

    init(demo: ShowcaseDemo) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor
        backgroundColor = ShowcasePalette.panel
        translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = demo.title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = ShowcasePalette.onSurface

        subtitleLabel.text = demo.subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = ShowcasePalette.muted
        subtitleLabel.numberOfLines = 2

        chevron.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
        chevron.tintColor = ShowcasePalette.muted

        let labelStack = NSStackView(views: [titleLabel, subtitleLabel])
        labelStack.orientation = .vertical
        labelStack.alignment = .leading
        labelStack.spacing = 4
        labelStack.setHuggingPriority(.defaultLow, for: .horizontal)
        let outer = NSStackView(views: [labelStack, chevron])
        outer.orientation = .horizontal
        outer.alignment = .centerY
        outer.spacing = 12
        outer.edgeInsets = NSEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: topAnchor),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),
        ])

        setTarget(self, action: #selector(handleClick))
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // UXControl.mouseDown runs a synchronous nextEventMatchingMask loop that
    // tracks the mouse until mouseUp and then sends the configured action.
    // Override mouseDown to flash the background while super is blocked, and
    // restore it once the loop exits.
    override func mouseDown(with event: NSEvent) {
        guard isEnabled else { super.mouseDown(with: event); return }
        let originalBackground = backgroundColor
        backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.12)
        super.mouseDown(with: event)
        backgroundColor = originalBackground
    }

    @objc private func handleClick() {
        onClick?()
    }
}
