//
//  ShowcaseMisc.swift
//  OpenUXKit-Example-Swift
//
//  Catch-all demos for the remaining public API surface: UXTabBarItemSegment,
//  the UXKitAppearance protocol, the UXLayoutSupport guides on UXViewController,
//  and the UXBase helpers / typedefs.
//

import Cocoa
import OpenUXKit

// MARK: - UXTabBarItemSegment

final class UXTabBarItemSegmentShowcaseViewController: UXViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXTabBarItemSegment"
        uxView.backgroundColor = ShowcasePalette.surface

        let segments: [UXTabBarItemSegment] = [
            UXTabBarItemSegment(title: "Inbox",
                                symbol: NSImage(systemSymbolName: "tray", accessibilityDescription: nil)),
            UXTabBarItemSegment(title: "Sent",
                                symbol: NSImage(systemSymbolName: "paperplane", accessibilityDescription: nil)),
            UXTabBarItemSegment(title: nil,
                                symbol: NSImage(systemSymbolName: "star", accessibilityDescription: nil)),
            UXTabBarItemSegment(title: "Disabled").then { $0.isEnabled = false },
        ]

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(makeOverviewCard())
        stack.addArrangedSubview(makeSegmentsCard(segments))
        stack.addArrangedSubview(makeEqualityCard(segments))
    }

    private func makeOverviewCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "What is a UXTabBarItemSegment?"
        let label = UXLabel().then {
            $0.text = """
            UXTabBarItemSegment is a small value type used by UXTabBarItem to describe an individual segment (icon + title). It exposes:
              • init(title:)
              • init(title:symbol:)
              • title, isEnabled
              • symbol (read-only)
              • isEqual(to:)
            """
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.onSurface
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makeSegmentsCard(_ segments: [UXTabBarItemSegment]) -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Segments rendered as cards"
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 12
        for segment in segments {
            let pill = makeSegmentPill(segment)
            row.addArrangedSubview(pill)
        }
        card.bodyStack.addArrangedSubview(row)
        return card
    }

    private func makeSegmentPill(_ segment: UXTabBarItemSegment) -> NSView {
        let imageView = UXImageView(image: segment.symbol)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = segment.isEnabled ? ShowcasePalette.primary : ShowcasePalette.muted
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let titleLabel = UXLabel().then {
            $0.text = segment.title ?? "(no title)"
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = segment.isEnabled ? ShowcasePalette.onSurface : ShowcasePalette.muted
        }
        let column = NSStackView(views: [imageView, titleLabel])
        column.orientation = .vertical
        column.alignment = .centerX
        column.spacing = 4

        let pill = UXView()
        pill.backgroundColor = ShowcasePalette.panel
        pill.wantsLayer = true
        pill.layer?.cornerRadius = 10
        pill.layer?.borderColor = NSColor.separatorColor.cgColor
        pill.layer?.borderWidth = 1
        pill.translatesAutoresizingMaskIntoConstraints = false
        column.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(column)
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: pill.topAnchor, constant: 12),
            column.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -12),
            column.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 18),
            column.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -18),
        ])
        return pill
    }

    private func makeEqualityCard(_ segments: [UXTabBarItemSegment]) -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "isEqual(to:)"
        let inbox = segments[0]
        let duplicateInbox = UXTabBarItemSegment(title: inbox.title, symbol: inbox.symbol)
        let isEqual = inbox.isEqual(to: duplicateInbox)
        let label = UXLabel().then {
            $0.text = "inbox.isEqual(to: duplicateInbox) → \(isEqual)"
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.muted
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }
}

// MARK: - UXLayoutSupport

final class UXLayoutSupportShowcaseViewController: UXViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXLayoutSupport"
        uxView.backgroundColor = ShowcasePalette.surface

        toolbarItems = [
            UXBarButtonItem(title: "Toolbar", style: .plain, target: nil, action: nil),
            UXBarButtonItem(title: "Helps content avoid bars", style: .plain, target: nil, action: nil),
        ]

        let topMarker = UXView().then {
            $0.backgroundColor = ShowcasePalette.primary.withAlphaComponent(0.5)
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 4
        }
        let bottomMarker = UXView().then {
            $0.backgroundColor = ShowcasePalette.accent.withAlphaComponent(0.5)
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 4
        }
        let card = ShowcaseCard()
        card.titleLabel.text = "Content pinned to top/bottom layout guides"
        let infoLabel = UXLabel().then {
            $0.text = """
            UXViewController.topLayoutGuide and bottomLayoutGuide expose UXLayoutSupport, which conforms to:
              • topAnchor / bottomAnchor / heightAnchor
              • length (CGFloat)
            The blue and orange stripes below are pinned to the guides directly — when toolbar tracks are visible, they push the safe area in automatically.
            """
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.onSurface
        }
        card.bodyStack.addArrangedSubview(infoLabel)

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(card)

        topMarker.translatesAutoresizingMaskIntoConstraints = false
        bottomMarker.translatesAutoresizingMaskIntoConstraints = false
        uxView.addSubview(topMarker)
        uxView.addSubview(bottomMarker)
        NSLayoutConstraint.activate([
            topMarker.leadingAnchor.constraint(equalTo: uxView.leadingAnchor),
            topMarker.trailingAnchor.constraint(equalTo: uxView.trailingAnchor),
            topMarker.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            topMarker.heightAnchor.constraint(equalToConstant: 4),
            bottomMarker.leadingAnchor.constraint(equalTo: uxView.leadingAnchor),
            bottomMarker.trailingAnchor.constraint(equalTo: uxView.trailingAnchor),
            bottomMarker.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            bottomMarker.heightAnchor.constraint(equalToConstant: 4),
        ])
    }
}

// MARK: - UXBase

final class UXBaseShowcaseViewController: UXViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXBase utilities"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(makeLocalizedStringCard())
        stack.addArrangedSubview(makeCompletionHandlerCard())
    }

    private func makeLocalizedStringCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "UXLocalizedString(_:)"
        let label = UXLabel().then {
            $0.text = """
            OpenUXKit ships UXLocalizedString(key) — a thin wrapper around NSLocalizedStringFromTableInBundle(key, nil, frameworkBundle, nil) that looks up keys inside the OpenUXKit module bundle. Unknown keys fall back to the key itself.

            UXLocalizedString("Back")  → \"\(UXLocalizedString("Back"))\"
            UXLocalizedString("Cancel") → \"\(UXLocalizedString("Cancel"))\"
            """
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.onSurface
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makeCompletionHandlerCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Block typedefs"
        let label = UXLabel().then {
            $0.text = """
            UXCompletionHandler            = () -> Void
            UXParameterCompletionHandler   = (Bool) -> Void

            These two typedefs back the completion arguments on UXViewController.presentViewController(_:animated:completion:), UXNavigationController setters and the transition-coordinator hooks.
            """
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
            $0.textColor = ShowcasePalette.muted
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }
}
