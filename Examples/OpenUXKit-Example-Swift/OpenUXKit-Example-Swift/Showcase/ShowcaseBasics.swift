//
//  ShowcaseBasics.swift
//  OpenUXKit-Example-Swift
//
//  Covers the foundational types: UXView, UXLabel, UXImageView, UXControl.
//

import Cocoa
#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#else
#error("")
#endif

// MARK: - UXView

final class UXViewShowcaseViewController: UXViewController {
    private let animatedTarget = UXView()
    private let blurTarget = UXView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXView"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)

        stack.addArrangedSubview(makeBackgroundCard())
        stack.addArrangedSubview(makeContentModeCard())
        stack.addArrangedSubview(makeAnimationCard())
        stack.addArrangedSubview(makeBlurCard())
        stack.addArrangedSubview(makeSnapshotCard())
    }

    private func makeBackgroundCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Background color + border"
        let sample = UXView().then {
            $0.backgroundColor = ShowcasePalette.primary
            $0.borderColor = ShowcasePalette.accent
            $0.wantsLayer = true
            $0.layer?.borderWidth = 3
            $0.layer?.cornerRadius = 8
        }
        sample.translatesAutoresizingMaskIntoConstraints = false
        card.bodyStack.addArrangedSubview(sample)
        NSLayoutConstraint.activate([
            sample.widthAnchor.constraint(equalToConstant: 240),
            sample.heightAnchor.constraint(equalToConstant: 80),
        ])
        return card
    }

    private func makeContentModeCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Content mode"
        let modes: [(String, UXView.ContentMode)] = [
            ("scaleToFill", .scaleToFill),
            ("scaleAspectFit", .scaleAspectFit),
            ("center", .center),
        ]
        for (name, mode) in modes {
            let label = UXLabel().then {
                $0.text = "contentMode = .\(name)"
                $0.font = .preferredFont(forTextStyle: .body)
                $0.textColor = ShowcasePalette.muted
            }
            let host = UXView().then {
                $0.backgroundColor = NSColor.controlBackgroundColor
                $0.contentMode = mode
                $0.wantsLayer = true
                $0.layer?.cornerRadius = 6
            }
            host.translatesAutoresizingMaskIntoConstraints = false
            host.heightAnchor.constraint(equalToConstant: 40).isActive = true
            card.bodyStack.addArrangedSubview(label)
            card.bodyStack.addArrangedSubview(host)
        }
        return card
    }

    private func makeAnimationCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "UXView.animate(withDuration:…)"

        animatedTarget.backgroundColor = ShowcasePalette.secondary
        animatedTarget.wantsLayer = true
        animatedTarget.layer?.cornerRadius = 30
        animatedTarget.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animatedTarget)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 80),
            container.widthAnchor.constraint(equalToConstant: 320),
            animatedTarget.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animatedTarget.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animatedTarget.widthAnchor.constraint(equalToConstant: 60),
            animatedTarget.heightAnchor.constraint(equalToConstant: 60),
        ])

        let bounceButton = NSButton(title: "Bounce", target: self, action: #selector(bounceAnimatedTarget))
        bounceButton.bezelStyle = .rounded
        let flashButton = NSButton(title: "Pulse", target: self, action: #selector(pulseAnimatedTarget))
        flashButton.bezelStyle = .rounded
        let buttons = NSStackView(views: [bounceButton, flashButton])
        buttons.orientation = .horizontal
        buttons.spacing = 8

        card.bodyStack.addArrangedSubview(container)
        card.bodyStack.addArrangedSubview(buttons)
        return card
    }

    @objc private func bounceAnimatedTarget() {
        UXView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.8,
                       options: [.allowUserInteraction],
                       animations: { [animatedTarget] in
                           animatedTarget.transform = CGAffineTransform(translationX: 220, y: 0)
                       },
                       completion: { [weak animatedTarget] _ in
                           UXView.animate(withDuration: 0.3) {
                               animatedTarget?.transform = .identity
                           }
                       })
    }

    @objc private func pulseAnimatedTarget() {
        UXView.animate(withDuration: 0.2,
                       animations: { [animatedTarget] in
                           animatedTarget.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                       },
                       completion: { [weak animatedTarget] _ in
                           UXView.animate(withDuration: 0.2) {
                               animatedTarget?.transform = .identity
                           }
                       })
    }

    private func makeBlurCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "blurEnabled + blurMaterial"
        blurTarget.blurEnabled = true
        blurTarget.blurMaterial = .hudWindow
        blurTarget.wantsLayer = true
        blurTarget.layer?.cornerRadius = 8
        blurTarget.translatesAutoresizingMaskIntoConstraints = false

        let backdrop = UXView().then {
            $0.backgroundColor = ShowcasePalette.accent
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 8
        }
        backdrop.translatesAutoresizingMaskIntoConstraints = false
        backdrop.addSubview(blurTarget)
        NSLayoutConstraint.activate([
            backdrop.heightAnchor.constraint(equalToConstant: 110),
            backdrop.widthAnchor.constraint(equalToConstant: 320),
            blurTarget.topAnchor.constraint(equalTo: backdrop.topAnchor, constant: 20),
            blurTarget.leadingAnchor.constraint(equalTo: backdrop.leadingAnchor, constant: 20),
            blurTarget.trailingAnchor.constraint(equalTo: backdrop.trailingAnchor, constant: -20),
            blurTarget.bottomAnchor.constraint(equalTo: backdrop.bottomAnchor, constant: -20),
        ])
        card.bodyStack.addArrangedSubview(backdrop)
        return card
    }

    private func makeSnapshotCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "snapshotView()"

        let source = UXView().then {
            $0.backgroundColor = ShowcasePalette.primary
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 8
        }
        source.translatesAutoresizingMaskIntoConstraints = false
        let label = UXLabel().then {
            $0.text = "Hello"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .white
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        source.addSubview(label)
        NSLayoutConstraint.activate([
            source.widthAnchor.constraint(equalToConstant: 140),
            source.heightAnchor.constraint(equalToConstant: 70),
            label.centerXAnchor.constraint(equalTo: source.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: source.centerYAnchor),
        ])

        let snapshotPlaceholder = UXView()
        snapshotPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        snapshotPlaceholder.widthAnchor.constraint(equalToConstant: 140).isActive = true
        snapshotPlaceholder.heightAnchor.constraint(equalToConstant: 70).isActive = true

        let snapshotButton = NSButton(title: "Take snapshot", target: nil, action: nil)
        snapshotButton.bezelStyle = .rounded
        snapshotButton.target = self
        snapshotButton.action = #selector(snapshotPlaceholderTapped)
        snapshotPlaceholderHolder = snapshotPlaceholder
        snapshotSource = source

        let row = NSStackView(views: [source, snapshotPlaceholder])
        row.orientation = .horizontal
        row.spacing = 16
        row.alignment = .centerY

        card.bodyStack.addArrangedSubview(row)
        card.bodyStack.addArrangedSubview(snapshotButton)
        return card
    }

    private var snapshotSource: UXView?
    private var snapshotPlaceholderHolder: UXView?

    @objc private func snapshotPlaceholderTapped() {
        guard let snapshotSource, let placeholder = snapshotPlaceholderHolder else { return }
        placeholder.subviews.forEach { $0.removeFromSuperview() }
        guard let snapshot = snapshotSource.snapshotView() else { return }
        snapshot.translatesAutoresizingMaskIntoConstraints = false
        placeholder.addSubview(snapshot)
        NSLayoutConstraint.activate([
            snapshot.topAnchor.constraint(equalTo: placeholder.topAnchor),
            snapshot.leadingAnchor.constraint(equalTo: placeholder.leadingAnchor),
            snapshot.trailingAnchor.constraint(equalTo: placeholder.trailingAnchor),
            snapshot.bottomAnchor.constraint(equalTo: placeholder.bottomAnchor),
        ])
    }
}

// MARK: - UXLabel

final class UXLabelShowcaseViewController: UXViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXLabel"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)

        stack.addArrangedSubview(makePlainCard())
        stack.addArrangedSubview(makeAttributedCard())
        stack.addArrangedSubview(makeMultilineCard())
        stack.addArrangedSubview(makeHighlightCard())
    }

    private func makePlainCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Plain text + font + color"
        let label = UXLabel().then {
            $0.text = "Hello, UXKit on AppKit"
            $0.font = .systemFont(ofSize: 18, weight: .semibold)
            $0.textColor = ShowcasePalette.primary
            $0.textAlignment = .center
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makeAttributedCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "attributedText"
        let label = UXLabel()
        let string = NSMutableAttributedString(string: "Mixed ",
                                               attributes: [.font: NSFont.systemFont(ofSize: 18)])
        string.append(NSAttributedString(string: "bold ",
                                         attributes: [.font: NSFont.boldSystemFont(ofSize: 18),
                                                      .foregroundColor: ShowcasePalette.primary]))
        string.append(NSAttributedString(string: "and ",
                                         attributes: [.font: NSFont.systemFont(ofSize: 18)]))
        string.append(NSAttributedString(string: "underlined",
                                         attributes: [.font: NSFont.systemFont(ofSize: 18),
                                                      .underlineStyle: NSUnderlineStyle.single.rawValue,
                                                      .foregroundColor: ShowcasePalette.accent]))
        label.attributedText = string
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makeMultilineCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "numberOfLines = 0 + lineBreakMode"
        let label = UXLabel().then {
            $0.text = """
            OpenUXKit's UXLabel wraps NSTextField and behaves like a UIKit-style label. Set numberOfLines to 0 to allow the text to flow over multiple lines, and use lineBreakMode to choose how truncation works.
            """
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.onSurface
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makeHighlightCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "isHighlighted + highlightedTextColor"
        let label = UXLabel().then {
            $0.text = "Tap the button to toggle isHighlighted"
            $0.textColor = ShowcasePalette.onSurface
            $0.highlightedTextColor = ShowcasePalette.accent
            $0.font = .preferredFont(forTextStyle: .body)
        }
        highlightTarget = label
        let toggle = NSButton(title: "Toggle highlight", target: self, action: #selector(toggleHighlight(_:)))
        toggle.bezelStyle = .rounded
        card.bodyStack.addArrangedSubview(label)
        card.bodyStack.addArrangedSubview(toggle)
        return card
    }

    private weak var highlightTarget: UXLabel?

    @objc private func toggleHighlight(_ sender: NSButton) {
        highlightTarget?.isHighlighted.toggle()
    }
}

// MARK: - UXImageView

final class UXImageViewShowcaseViewController: UXViewController {
    private let highlightedImageView = UXImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXImageView"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)

        stack.addArrangedSubview(makeImageCard())
        stack.addArrangedSubview(makeTintCard())
        stack.addArrangedSubview(makeHighlightCard())
    }

    private func makeImageCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "image"
        let imageView = UXImageView(image: NSImage(systemSymbolName: "swift", accessibilityDescription: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        card.bodyStack.addArrangedSubview(imageView)
        return card
    }

    private func makeTintCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "tintColor"

        let tints: [(String, NSColor)] = [
            ("primary", ShowcasePalette.primary),
            ("secondary", ShowcasePalette.secondary),
            ("accent", ShowcasePalette.accent),
        ]
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 18
        row.alignment = .centerY
        for (name, color) in tints {
            let imageView = UXImageView(image: NSImage(systemSymbolName: "heart.fill", accessibilityDescription: nil))
            imageView.tintColor = color
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

            let label = UXLabel().then {
                $0.text = name
                $0.font = .preferredFont(forTextStyle: .caption1)
                $0.textColor = ShowcasePalette.muted
            }
            let column = NSStackView(views: [imageView, label])
            column.orientation = .vertical
            column.alignment = .centerX
            column.spacing = 4
            row.addArrangedSubview(column)
        }
        card.bodyStack.addArrangedSubview(row)
        return card
    }

    private func makeHighlightCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "highlightedImage + isHighlighted"
        highlightedImageView.image = NSImage(systemSymbolName: "star", accessibilityDescription: nil)
        highlightedImageView.highlightedImage = NSImage(systemSymbolName: "star.fill", accessibilityDescription: nil)
        highlightedImageView.tintColor = ShowcasePalette.accent
        highlightedImageView.contentMode = .scaleAspectFit
        highlightedImageView.translatesAutoresizingMaskIntoConstraints = false
        highlightedImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        highlightedImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let toggle = NSButton(title: "Toggle isHighlighted", target: self, action: #selector(toggleHighlight))
        toggle.bezelStyle = .rounded

        card.bodyStack.addArrangedSubview(highlightedImageView)
        card.bodyStack.addArrangedSubview(toggle)
        return card
    }

    @objc private func toggleHighlight() {
        highlightedImageView.isHighlighted.toggle()
    }
}

// MARK: - UXControl

final class UXControlShowcaseViewController: UXViewController {
    private let logLabel = UXLabel()
    private let toggleButton = UXSwitchControl()
    private let pulseButton = UXPulseButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXControl"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)

        stack.addArrangedSubview(makeTargetActionCard())
        stack.addArrangedSubview(makeStateCard())
        stack.addArrangedSubview(makeLogCard())
    }

    private func makeTargetActionCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Target/action via UXControl"
        pulseButton.setTarget(self, action: #selector(pulse))
        pulseButton.translatesAutoresizingMaskIntoConstraints = false
        pulseButton.widthAnchor.constraint(equalToConstant: 160).isActive = true
        pulseButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        card.bodyStack.addArrangedSubview(pulseButton)
        return card
    }

    private func makeStateCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "isEnabled / isSelected / isHighlighted"
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        toggleButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        toggleButton.setTarget(self, action: #selector(toggleSwitched))

        let toggleEnabled = NSButton(title: "Toggle isEnabled", target: self, action: #selector(toggleEnabled(_:)))
        toggleEnabled.bezelStyle = .rounded
        card.bodyStack.addArrangedSubview(toggleButton)
        card.bodyStack.addArrangedSubview(toggleEnabled)
        return card
    }

    private func makeLogCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Action log"
        logLabel.text = "—"
        logLabel.numberOfLines = 0
        logLabel.font = .preferredFont(forTextStyle: .body)
        logLabel.textColor = ShowcasePalette.muted
        card.bodyStack.addArrangedSubview(logLabel)
        return card
    }

    @objc private func pulse() {
        pulseButton.isSelected.toggle()
        appendLog("pulse() received from UXPulseButton — \(pulseButton.isSelected ? "selected" : "normal")")
    }

    @objc private func toggleSwitched() {
        toggleButton.isSelected.toggle()
        appendLog("Switch toggled to \(toggleButton.isSelected ? "ON" : "OFF")")
    }

    @objc private func toggleEnabled(_ sender: NSButton) {
        toggleButton.isEnabled.toggle()
        appendLog("Switch isEnabled = \(toggleButton.isEnabled)")
    }

    private func appendLog(_ message: String) {
        let existing = logLabel.text ?? ""
        let entries = existing == "—" ? [] : existing.split(separator: "\n").map(String.init)
        let next = ([message] + entries).prefix(6).joined(separator: "\n")
        logLabel.text = next
    }
}

/// Minimal UXControl subclass that renders a coloured pill with state-driven
/// styling. Demonstrates target/action via UXControl.setTarget(_:action:);
/// UXControl's own mouseDown runs a synchronous modal event loop that flips
/// `isHighlighted` and dispatches the configured action on mouse-up, so this
/// subclass only needs to react to state changes.
private final class UXPulseButton: UXControl {
    private let label = UXLabel()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 18

        label.text = "Tap me"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var isHighlighted: Bool {
        didSet { refresh() }
    }
    override var isSelected: Bool {
        didSet { refresh() }
    }
    override var isEnabled: Bool {
        didSet { refresh() }
    }

    private func refresh() {
        if !isEnabled {
            backgroundColor = ShowcasePalette.muted.withAlphaComponent(0.4)
        } else if isHighlighted {
            backgroundColor = ShowcasePalette.accent.shadow(withLevel: 0.2)
        } else if isSelected {
            backgroundColor = ShowcasePalette.accent
        } else {
            backgroundColor = ShowcasePalette.primary
        }
    }
}

/// Switch-style UXControl that flips its state on click.
private final class UXSwitchControl: UXControl {
    private let knob = UXView()
    private let titleLabel = UXLabel()
    private let trailingConstraintWhenOn = NSLayoutConstraint()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 18
        backgroundColor = NSColor.controlBackgroundColor

        knob.backgroundColor = .white
        knob.wantsLayer = true
        knob.layer?.cornerRadius = 14
        knob.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "isSelected = false"
        titleLabel.textColor = ShowcasePalette.onSurface
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(knob)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            knob.widthAnchor.constraint(equalToConstant: 28),
            knob.heightAnchor.constraint(equalToConstant: 28),
            knob.centerYAnchor.constraint(equalTo: centerYAnchor),
            knob.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: knob.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override var isSelected: Bool {
        didSet {
            UXView.animate(withDuration: 0.2) {
                self.titleLabel.text = "isSelected = \(self.isSelected)"
                self.backgroundColor = self.isSelected ? ShowcasePalette.primary.withAlphaComponent(0.2) : NSColor.controlBackgroundColor
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            alphaValue = isEnabled ? 1.0 : 0.4
        }
    }
}
