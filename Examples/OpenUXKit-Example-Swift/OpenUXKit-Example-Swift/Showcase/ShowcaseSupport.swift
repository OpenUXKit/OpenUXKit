//
//  ShowcaseSupport.swift
//  OpenUXKit-Example-Swift
//
//  Shared models and view helpers for the showcase. Every demo in this app
//  is constructed through a `ShowcaseDemo`, which the home screen lists and
//  pushes onto the navigation stack on selection.
//

import Cocoa
#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#else
#error("")
#endif

struct ShowcaseSection {
    let title: String
    let demos: [ShowcaseDemo]
}

struct ShowcaseDemo {
    let title: String
    let subtitle: String
    let make: () -> UXViewController
}

enum ShowcaseCatalog {
    static let sections: [ShowcaseSection] = [
        ShowcaseSection(title: "Views & Animation", demos: [
            ShowcaseDemo(title: "UXView", subtitle: "Layer-backed view, animations, snapshot", make: UXViewShowcaseViewController.init),
            ShowcaseDemo(title: "UXLabel", subtitle: "Plain & attributed text, multiline", make: UXLabelShowcaseViewController.init),
            ShowcaseDemo(title: "UXImageView", subtitle: "Image, tint, highlighted state", make: UXImageViewShowcaseViewController.init),
            ShowcaseDemo(title: "UXControl", subtitle: "Target/action plumbing and state flags", make: UXControlShowcaseViewController.init),
        ]),
        ShowcaseSection(title: "Bars", demos: [
            ShowcaseDemo(title: "UXBarButtonItem", subtitle: "System items, styles and custom views", make: UXBarButtonItemShowcaseViewController.init),
            ShowcaseDemo(title: "UXNavigationItem", subtitle: "Title, prompt, leading/trailing items", make: UXNavigationItemShowcaseViewController.init),
            ShowcaseDemo(title: "UXToolbar tracks", subtitle: "toolbar / subtoolbar / accessoryBar / scopeBar", make: UXToolbarTracksShowcaseViewController.init),
        ]),
        ShowcaseSection(title: "Containers & Transitions", demos: [
            ShowcaseDemo(title: "UXNavigationController", subtitle: "Push, pop and replace the stack", make: UXNavigationStackShowcaseViewController.init),
            ShowcaseDemo(title: "Modal presentation", subtitle: "presentViewController(_:animated:completion:)", make: UXModalShowcaseViewController.init),
            ShowcaseDemo(title: "Animated transitioning", subtitle: "UXViewControllerAnimatedTransitioning", make: UXTransitioningShowcaseViewController.init),
        ]),
        ShowcaseSection(title: "Collection View", demos: [
            ShowcaseDemo(title: "UXCollectionView", subtitle: "Flow layout with headers + selection", make: UXCollectionViewShowcaseViewController.init),
            ShowcaseDemo(title: "UXCollectionViewController", subtitle: "Built-in collection view + data source", make: UXCollectionViewControllerShowcaseViewController.init),
            ShowcaseDemo(title: "Horizontal flow", subtitle: "scrollDirection = .horizontal, header/footer per section", make: UXCollectionViewHorizontalShowcaseViewController.init),
            ShowcaseDemo(title: "Mixed sizes", subtitle: "Truly variable item widths and heights", make: UXCollectionViewMixedSizeShowcaseViewController.init),
            ShowcaseDemo(title: "Per-section metrics", subtitle: "Different insets, spacings, and footers per section", make: UXCollectionViewMultiMetricsShowcaseViewController.init),
            ShowcaseDemo(title: "Edge cases", subtitle: "Empty sections, single-item rows, default itemSize", make: UXCollectionViewEdgeCasesShowcaseViewController.init),
        ]),
        ShowcaseSection(title: "Miscellaneous", demos: [
            ShowcaseDemo(title: "UXTabBarItemSegment", subtitle: "Segment model used by tab bars", make: UXTabBarItemSegmentShowcaseViewController.init),
            ShowcaseDemo(title: "UXLayoutSupport", subtitle: "topLayoutGuide / bottomLayoutGuide", make: UXLayoutSupportShowcaseViewController.init),
            ShowcaseDemo(title: "UXBase utilities", subtitle: "UXLocalizedString, completion handlers", make: UXBaseShowcaseViewController.init),
        ]),
    ]
}

enum ShowcasePalette {
    static let primary = NSColor.systemBlue
    static let secondary = NSColor.systemPurple
    static let accent = NSColor.systemOrange
    static let surface: NSColor = .windowBackgroundColor
    static let panel: NSColor = .controlBackgroundColor
    static let onSurface: NSColor = .labelColor
    static let muted: NSColor = .secondaryLabelColor
}

/// A reusable card view used to frame each demo. Uses UXView so we hit
/// UXView's layer-backed APIs without callers having to duplicate set-up.
final class ShowcaseCard: UXView {
    let titleLabel = UXLabel()
    let bodyStack = NSStackView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor
        backgroundColor = ShowcasePalette.panel

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = ShowcasePalette.onSurface
        titleLabel.numberOfLines = 1

        bodyStack.orientation = .vertical
        bodyStack.alignment = .leading
        bodyStack.spacing = 8

        let outer = NSStackView(views: [titleLabel, bodyStack])
        outer.orientation = .vertical
        outer.alignment = .leading
        outer.spacing = 12
        outer.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: topAnchor),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

/// Builds a vertical scroll view that hosts a stack of cards. Most demos use
/// this so users can resize the window without losing content.
func makeShowcaseScroller() -> (NSScrollView, NSStackView) {
    let stack = NSStackView()
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 20
    stack.edgeInsets = NSEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
    stack.translatesAutoresizingMaskIntoConstraints = false

    let document = NSView()
    document.translatesAutoresizingMaskIntoConstraints = false
    document.addSubview(stack)
    NSLayoutConstraint.activate([
        stack.topAnchor.constraint(equalTo: document.topAnchor),
        stack.leadingAnchor.constraint(equalTo: document.leadingAnchor),
        stack.trailingAnchor.constraint(equalTo: document.trailingAnchor),
        stack.bottomAnchor.constraint(equalTo: document.bottomAnchor),
    ])

    let scroller = NSScrollView()
    scroller.translatesAutoresizingMaskIntoConstraints = false
    scroller.hasVerticalScroller = true
    scroller.drawsBackground = false
    scroller.documentView = document
    NSLayoutConstraint.activate([
        document.widthAnchor.constraint(equalTo: scroller.widthAnchor),
    ])
    return (scroller, stack)
}

/// Pin a content view to the demo's `uxView`, accounting for top/bottom layout
/// guides so toolbar overlays do not cover content.
func pinFillingUXView(_ contentView: NSView, in controller: UXViewController) {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    controller.uxView.addSubview(contentView)
    NSLayoutConstraint.activate([
        contentView.leadingAnchor.constraint(equalTo: controller.uxView.leadingAnchor),
        contentView.trailingAnchor.constraint(equalTo: controller.uxView.trailingAnchor),
        contentView.topAnchor.constraint(equalTo: controller.topLayoutGuide.bottomAnchor),
        contentView.bottomAnchor.constraint(equalTo: controller.bottomLayoutGuide.topAnchor),
    ])
}
