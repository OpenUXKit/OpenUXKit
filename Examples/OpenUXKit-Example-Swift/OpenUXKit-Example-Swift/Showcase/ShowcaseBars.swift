//
//  ShowcaseBars.swift
//  OpenUXKit-Example-Swift
//
//  UXBarButtonItem, UXNavigationItem and the four UXToolbar tracks exposed by
//  UXNavigationController (toolbar / subtoolbar / accessoryBar / scopeBar).
//

import Cocoa
#if canImport(OpenUXKit)
import OpenUXKit
#elseif canImport(UXKit)
import UXKit
#else
#error("")
#endif

// MARK: - UXBarButtonItem

final class UXBarButtonItemShowcaseViewController: UXViewController {
    private let logLabel = UXLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXBarButtonItem"
        uxView.backgroundColor = ShowcasePalette.surface

        configureNavigationItems()
        configureToolbarItems()

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(makeSystemItemListCard())
        stack.addArrangedSubview(makeLogCard())
    }

    private func configureNavigationItems() {
        // Use `leadingBarButtonItems` rather than `leftBarButtonItem` so the
        // framework still auto-generates the back button next to our items.
        let cancel = UXBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(navigationItemAction(_:)))
        cancel.label = "Cancel"

        let done = UXBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(navigationItemAction(_:)))
        done.label = "Done"
        done.style = .done

        let custom = UXBarButtonItem(title: "Custom", style: .bordered, target: self, action: #selector(navigationItemAction(_:)))

        navigationItem?.leadingBarButtonItems = [cancel]
        navigationItem?.trailingBarButtonItems = [done, custom]
    }

    private func configureToolbarItems() {
        // SF Symbol images instead of UXBarButtonSystemItem so the demo works
        // against Apple's private UXKit (which only knows a handful of system
        // items — items like .add / .search / .refresh / .flexibleSpace log
        // "unexpected UXBarButtonSystemItem" warnings and render blank).
        func imageItem(_ symbolName: String, label: String) -> UXBarButtonItem {
            let item = UXBarButtonItem(image: NSImage(systemSymbolName: symbolName, accessibilityDescription: label)!,
                                       style: .plain,
                                       target: self,
                                       action: #selector(toolbarItemAction(_:)))
            item.label = label
            return item
        }

        toolbarItems = [
            imageItem("trash", label: "Trash"),
            imageItem("arrow.clockwise", label: "Refresh"),
            imageItem("plus", label: "Add"),
            imageItem("square.and.arrow.up", label: "Share"),
            imageItem("sparkles", label: "Sparkles"),
        ]
    }

    private func makeSystemItemListCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Every UXBarButtonItem.SystemItem"

        let systems: [(String, UXBarButtonItem.SystemItem)] = [
            ("done", .done), ("cancel", .cancel), ("edit", .edit), ("save", .save),
            ("add", .add), ("compose", .compose), ("reply", .reply), ("action", .action),
            ("organize", .organize), ("bookmarks", .bookmarks), ("search", .search),
            ("refresh", .refresh), ("stop", .stop), ("camera", .camera), ("trash", .trash),
            ("play", .play), ("pause", .pause), ("rewind", .rewind), ("fastForward", .fastForward),
            ("undo", .undo), ("redo", .redo), ("pageCurl", .pageCurl), ("close", .close),
        ]
        let columns = NSStackView()
        columns.orientation = .horizontal
        columns.spacing = 24
        columns.alignment = .top

        let chunkSize = (systems.count + 2) / 3
        for chunk in stride(from: 0, to: systems.count, by: chunkSize) {
            let inner = NSStackView()
            inner.orientation = .vertical
            inner.alignment = .leading
            inner.spacing = 4
            for (name, _) in systems[chunk..<min(chunk + chunkSize, systems.count)] {
                let label = UXLabel().then {
                    $0.text = "• \(name)"
                    $0.font = .systemFont(ofSize: 13)
                    $0.textColor = ShowcasePalette.muted
                }
                inner.addArrangedSubview(label)
            }
            columns.addArrangedSubview(inner)
        }
        card.bodyStack.addArrangedSubview(columns)
        let hint = UXLabel().then {
            $0.text = "Scroll the toolbar at the bottom to see every system glyph rendered live."
            $0.font = .preferredFont(forTextStyle: .footnote)
            $0.textColor = ShowcasePalette.muted
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 480
        }
        card.bodyStack.addArrangedSubview(hint)
        return card
    }

    private func makeLogCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Bar button action log"
        logLabel.text = "Tap a navigation or toolbar item to log its action…"
        logLabel.numberOfLines = 0
        logLabel.font = .preferredFont(forTextStyle: .body)
        logLabel.textColor = ShowcasePalette.muted
        card.bodyStack.addArrangedSubview(logLabel)
        return card
    }

    @objc private func navigationItemAction(_ sender: UXBarButtonItem) {
        logLabel.text = "Navigation item tapped → \(sender.label ?? sender.title ?? "(unnamed)")"
    }

    @objc private func toolbarItemAction(_ sender: UXBarButtonItem) {
        logLabel.text = "Toolbar item tapped → \(sender.label ?? sender.title ?? "(unnamed)")"
    }
}

// MARK: - UXNavigationItem

final class UXNavigationItemShowcaseViewController: UXViewController {
    private var promptVisible = true

    override func viewDidLoad() {
        super.viewDidLoad()
        uxView.backgroundColor = ShowcasePalette.surface

        guard let navigationItem else { return }
        navigationItem.title = "UXNavigationItem"
        navigationItem.prompt = "navigationItem.prompt = …"

        let titleView = UXLabel().then {
            $0.text = "Custom titleView"
            $0.font = .systemFont(ofSize: 14, weight: .semibold)
            $0.textColor = ShowcasePalette.accent
        }
        navigationItem.titleView = titleView

        // Avoid explicitly setting backBarButtonItem — Apple's private UXKit
        // does not re-wire its target/action when the developer supplies the
        // item directly, so the auto-generated back button is the safest path.

        navigationItem.leadingBarButtonItems = [
            UXBarButtonItem(image: NSImage(systemSymbolName: "plus", accessibilityDescription: "Add")!,
                            style: .plain, target: self, action: #selector(togglePrompt)),
            UXBarButtonItem(image: NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: nil)!,
                            style: .plain, target: nil, action: nil),
        ]
        navigationItem.trailingBarButtonItems = [
            UXBarButtonItem(image: NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "Search")!,
                            style: .plain, target: nil, action: nil),
            UXBarButtonItem(title: "Edit", style: .bordered, target: nil, action: nil),
        ]

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(makeOverviewCard())
        stack.addArrangedSubview(makePromptControlCard())
    }

    private func makeOverviewCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "What you'll see"
        let label = UXLabel().then {
            $0.text = """
            • title  → shown when titleView is nil
            • prompt → secondary text above the title
            • titleView → custom NSView, replaces the title label
            • leadingBarButtonItems / trailingBarButtonItems
            • backBarButtonItem → drives the auto back button
            """
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.onSurface
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makePromptControlCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "navigationItem.prompt"
        let button = NSButton(title: "Toggle prompt", target: self, action: #selector(togglePrompt))
        button.bezelStyle = .rounded
        card.bodyStack.addArrangedSubview(button)
        return card
    }

    @objc private func togglePrompt() {
        promptVisible.toggle()
        navigationItem?.prompt = promptVisible ? "navigationItem.prompt = …" : nil
    }
}

// MARK: - UXToolbar tracks

final class UXToolbarTracksShowcaseViewController: UXViewController {
    private let logLabel = UXLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "UXToolbar tracks"
        uxView.backgroundColor = ShowcasePalette.surface

        toolbarItems = [
            UXBarButtonItem(title: "Toolbar A", style: .plain, target: self, action: #selector(logItem(_:))),
            UXBarButtonItem(title: "Toolbar B", style: .bordered, target: self, action: #selector(logItem(_:))),
        ]
        subtoolbarItems = [
            UXBarButtonItem(title: "Subtoolbar 1", style: .plain, target: self, action: #selector(logItem(_:))),
            UXBarButtonItem(title: "Subtoolbar 2", style: .plain, target: self, action: #selector(logItem(_:))),
        ]
        accessoryBarItems = [
            UXBarButtonItem(title: "Accessory", style: .plain, target: self, action: #selector(logItem(_:))),
        ]
        scopeBarItems = [
            UXBarButtonItem(title: "All", style: .plain, target: self, action: #selector(logItem(_:))),
            UXBarButtonItem(title: "Recent", style: .plain, target: self, action: #selector(logItem(_:))),
            UXBarButtonItem(title: "Favourites", style: .plain, target: self, action: #selector(logItem(_:))),
        ]

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(makeOverviewCard())
        stack.addArrangedSubview(makeToggleCard())
        stack.addArrangedSubview(makeLogCard())
    }

    private func makeOverviewCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Four toolbar tracks"
        let label = UXLabel().then {
            $0.text = """
            UXNavigationController exposes four UXToolbar instances on its bottom edge:
              1. toolbar         — primary actions
              2. subtoolbar      — secondary track shown below the toolbar
              3. accessoryBar    — pinned accessory track
              4. scopeBar        — search-style scope segments

            Each is populated from the corresponding *toolbarItems*, *subtoolbarItems*,
            *accessoryBarItems*, and *scopeBarItems* arrays on the active UXViewController.
            """
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.onSurface
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makeToggleCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Hide / show tracks"
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 8

        let toolbar = NSButton(title: "toolbar", target: self, action: #selector(toggleToolbar))
        let subtoolbar = NSButton(title: "subtoolbar", target: self, action: #selector(toggleSubtoolbar))
        let navBar = NSButton(title: "navigationBar", target: self, action: #selector(toggleNavigationBar))

        for button in [toolbar, subtoolbar, navBar] {
            button.bezelStyle = .rounded
            row.addArrangedSubview(button)
        }
        card.bodyStack.addArrangedSubview(row)
        return card
    }

    private func makeLogCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Action log"
        logLabel.text = "Tap any bar item or toggle to log."
        logLabel.numberOfLines = 0
        logLabel.font = .preferredFont(forTextStyle: .body)
        logLabel.textColor = ShowcasePalette.muted
        card.bodyStack.addArrangedSubview(logLabel)
        return card
    }

    @objc private func toggleToolbar() {
        guard let navigation = navigationController else { return }
        navigation.setToolbarHidden(!navigation.isToolbarHidden, animated: true)
        logLabel.text = "navigationController.isToolbarHidden = \(navigation.isToolbarHidden)"
    }

    @objc private func toggleSubtoolbar() {
        guard let navigation = navigationController else { return }
        navigation.isSubtoolbarHidden.toggle()
        logLabel.text = "navigationController.isSubtoolbarHidden = \(navigation.isSubtoolbarHidden)"
    }

    @objc private func toggleNavigationBar() {
        guard let navigation = navigationController else { return }
        navigation.setNavigationBarHidden(!navigation.isNavigationBarHidden, animated: true)
        logLabel.text = "navigationController.isNavigationBarHidden = \(navigation.isNavigationBarHidden)"
    }

    @objc private func logItem(_ sender: UXBarButtonItem) {
        logLabel.text = "Bar item tapped → \(sender.title ?? "(no title)")"
    }
}
