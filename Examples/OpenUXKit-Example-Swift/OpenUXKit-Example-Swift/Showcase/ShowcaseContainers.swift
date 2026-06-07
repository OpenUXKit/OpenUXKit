//
//  ShowcaseContainers.swift
//  OpenUXKit-Example-Swift
//
//  UXNavigationController stack manipulation, modal presentation and a
//  hand-rolled UXViewControllerAnimatedTransitioning animator.
//

import Cocoa
import OpenUXKit

// MARK: - UXNavigationController stack manipulation

final class UXNavigationStackShowcaseViewController: UXViewController {
    private var depth = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Stack #\(depth)"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)

        stack.addArrangedSubview(makeOverviewCard())
        stack.addArrangedSubview(makePushCard())
        stack.addArrangedSubview(makeReplaceCard())
        stack.addArrangedSubview(makeDepthCard())
    }

    convenience init(depth: Int) {
        self.init()
        self.depth = depth
    }

    private func makeOverviewCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Stack overview"
        let label = UXLabel().then {
            $0.text = """
            Depth: \(depth)
            Total in stack: \(navigationController?.viewControllers.count ?? 0)
            visibleViewController == self: \(navigationController?.visibleViewController === self)
            topViewController == self: \(navigationController?.topViewController === self)
            """
            $0.numberOfLines = 0
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.muted
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    private func makePushCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Push a new stack frame"
        let push = NSButton(title: "pushViewController(_:animated: true)", target: self, action: #selector(pushDeeper))
        push.bezelStyle = .rounded
        card.bodyStack.addArrangedSubview(push)
        return card
    }

    private func makeReplaceCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Replace the stack"
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 8
        let popOne = NSButton(title: "popViewController", target: self, action: #selector(popOnce))
        let popRoot = NSButton(title: "popToRootViewController", target: self, action: #selector(popToRoot))
        let replace = NSButton(title: "setViewControllers([root, new], animated: true)", target: self, action: #selector(replaceStack))
        for button in [popOne, popRoot, replace] {
            button.bezelStyle = .rounded
            row.addArrangedSubview(button)
        }
        card.bodyStack.addArrangedSubview(row)
        return card
    }

    private func makeDepthCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Inspect stack"
        let label = UXLabel().then {
            $0.text = (navigationController?.viewControllers ?? [])
                .enumerated()
                .map { "[\($0.offset)] " + (($0.element.navigationItem?.title) ?? "(no title)") }
                .joined(separator: "\n")
            $0.numberOfLines = 0
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.muted
        }
        card.bodyStack.addArrangedSubview(label)
        return card
    }

    @objc private func pushDeeper() {
        navigationController?.pushViewController(UXNavigationStackShowcaseViewController(depth: depth + 1), animated: true)
    }

    @objc private func popOnce() {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc private func popToRoot() {
        _ = navigationController?.popToRootViewController(animated: true)
    }

    @objc private func replaceStack() {
        guard let navigationController, let root = navigationController.viewControllers.first else { return }
        let fresh = UXNavigationStackShowcaseViewController(depth: 99)
        navigationController.setViewControllers([root, fresh], animated: true)
    }
}

// MARK: - Modal presentation

final class UXModalShowcaseViewController: UXViewController {
    private let log = UXLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Modal presentation"
        uxView.backgroundColor = ShowcasePalette.surface

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        stack.addArrangedSubview(makePresentCard())
        stack.addArrangedSubview(makeLogCard())
    }

    private func makePresentCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "present(_:animated:completion:)"
        let presentButton = NSButton(title: "Present a modal", target: self, action: #selector(presentModal))
        presentButton.bezelStyle = .rounded
        card.bodyStack.addArrangedSubview(presentButton)
        return card
    }

    private func makeLogCard() -> ShowcaseCard {
        let card = ShowcaseCard()
        card.titleLabel.text = "Presentation log"
        log.text = "—"
        log.numberOfLines = 0
        log.font = .preferredFont(forTextStyle: .body)
        log.textColor = ShowcasePalette.muted
        card.bodyStack.addArrangedSubview(log)
        return card
    }

    @objc private func presentModal() {
        let modal = ModalContentViewController()
        modal.modalPresentationStyle = .formSheet
        modal.onDismiss = { [weak self] in
            self?.log.text = (self?.log.text ?? "") + "\n• Modal dismissed."
        }
        log.text = "• Calling present(_:animated:completion:)…"
        present(modal, animated: true) { [weak self] in
            self?.log.text = (self?.log.text ?? "") + "\n• Presentation animation finished."
        }
    }
}

private final class ModalContentViewController: UXViewController {
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        uxView.backgroundColor = ShowcasePalette.surface

        let title = UXLabel().then {
            $0.text = "I am a modal UXViewController"
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = ShowcasePalette.onSurface
        }
        let description = UXLabel().then {
            $0.text = "modalPresentationStyle = .formSheet\nTap the button below to call dismiss(animated:completion:)."
            $0.numberOfLines = 0
            $0.font = .preferredFont(forTextStyle: .body)
            $0.textColor = ShowcasePalette.muted
        }
        let dismiss = NSButton(title: "Dismiss", target: self, action: #selector(dismissTapped))
        dismiss.bezelStyle = .rounded

        let stack = NSStackView(views: [title, description, dismiss])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        uxView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: uxView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: uxView.centerYAnchor),
        ])
    }

    @objc private func dismissTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?()
        }
    }
}

// MARK: - Animated transitioning

final class UXTransitioningShowcaseViewController: UXViewController, UXNavigationControllerDelegate {
    private enum AnimationStyle: Int, CaseIterable {
        case fade
        case slideUp
        var name: String {
            switch self {
            case .fade: return "Fade"
            case .slideUp: return "Slide up"
            }
        }
    }

    private let nestedNavigation: UXNavigationController = {
        let root = NestedTransitionViewController(index: 1)
        return UXNavigationController(rootViewController: root)
    }()

    private var animationStyle: AnimationStyle = .fade

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Animated Transitioning"
        uxView.backgroundColor = ShowcasePalette.surface
        nestedNavigation.delegate = self

        let preview = UXView().then {
            $0.backgroundColor = .black
            $0.wantsLayer = true
            $0.layer?.cornerRadius = 12
            $0.layer?.masksToBounds = true
        }
        preview.translatesAutoresizingMaskIntoConstraints = false
        preview.heightAnchor.constraint(equalToConstant: 280).isActive = true

        addChild(nestedNavigation)
        let nestedView = nestedNavigation.view
        nestedView.translatesAutoresizingMaskIntoConstraints = false
        preview.addSubview(nestedView)
        NSLayoutConstraint.activate([
            nestedView.topAnchor.constraint(equalTo: preview.topAnchor),
            nestedView.leadingAnchor.constraint(equalTo: preview.leadingAnchor),
            nestedView.trailingAnchor.constraint(equalTo: preview.trailingAnchor),
            nestedView.bottomAnchor.constraint(equalTo: preview.bottomAnchor),
        ])

        let segment = NSSegmentedControl(labels: AnimationStyle.allCases.map(\.name), trackingMode: .selectOne, target: self, action: #selector(animationStyleChanged(_:)))
        segment.selectedSegment = 0

        let push = NSButton(title: "Push a child", target: self, action: #selector(pushChild))
        push.bezelStyle = .rounded
        let pop = NSButton(title: "Pop", target: self, action: #selector(popChild))
        pop.bezelStyle = .rounded
        let buttons = NSStackView(views: [push, pop])
        buttons.orientation = .horizontal
        buttons.spacing = 8

        let (scroller, stack) = makeShowcaseScroller()
        pinFillingUXView(scroller, in: self)
        let card = ShowcaseCard()
        card.titleLabel.text = "Nested UXNavigationController + custom animator"
        card.bodyStack.addArrangedSubview(preview)
        card.bodyStack.addArrangedSubview(segment)
        card.bodyStack.addArrangedSubview(buttons)
        let explain = UXLabel().then {
            $0.text = "Implements UXNavigationControllerDelegate.navigationController(_:animationControllerFor:from:to:) and returns custom UXViewControllerAnimatedTransitioning instances."
            $0.numberOfLines = 0
            $0.preferredMaxLayoutWidth = 520
            $0.font = .preferredFont(forTextStyle: .footnote)
            $0.textColor = ShowcasePalette.muted
        }
        card.bodyStack.addArrangedSubview(explain)
        stack.addArrangedSubview(card)
    }

    @objc private func animationStyleChanged(_ sender: NSSegmentedControl) {
        animationStyle = AnimationStyle(rawValue: sender.selectedSegment) ?? .fade
    }

    @objc private func pushChild() {
        let count = nestedNavigation.viewControllers.count + 1
        nestedNavigation.pushViewController(NestedTransitionViewController(index: count), animated: true)
    }

    @objc private func popChild() {
        _ = nestedNavigation.popViewController(animated: true)
    }

    // UXNavigationControllerDelegate
    func navigationController(_ navigationController: UXNavigationController,
                              animationControllerFor operation: UXNavigationController.Operation,
                              from fromViewController: UXViewController,
                              to toViewController: UXViewController) -> UXViewControllerAnimatedTransitioning? {
        switch animationStyle {
        case .fade: return FadeAnimator()
        case .slideUp: return SlideAnimator(operation: operation)
        }
    }
}

private final class NestedTransitionViewController: UXViewController {
    private let index: Int

    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem?.title = "Frame #\(index)"
        let colors: [NSColor] = [.systemBlue, .systemPurple, .systemPink, .systemTeal, .systemIndigo]
        uxView.backgroundColor = colors[(index - 1) % colors.count]

        let label = UXLabel().then {
            $0.text = "#\(index)"
            $0.font = .systemFont(ofSize: 60, weight: .heavy)
            $0.textColor = .white
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        uxView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: uxView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: uxView.centerYAnchor),
        ])
    }
}

private final class FadeAnimator: NSObject, UXViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UXViewControllerContextTransitioning?) -> TimeInterval { 0.35 }

    func animateTransition(using transitionContext: UXViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        let toView = toViewController.view
        let fromView = fromViewController.view
        toView.frame = container.bounds
        toView.alphaValue = 0
        container.addSubview(toView)

        UXView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
                           toView.alphaValue = 1
                           fromView.alphaValue = 0
                       },
                       completion: { _ in
                           fromView.alphaValue = 1
                           transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                       })
    }
}

private final class SlideAnimator: NSObject, UXViewControllerAnimatedTransitioning {
    let operation: UXNavigationController.Operation
    init(operation: UXNavigationController.Operation) { self.operation = operation }

    func transitionDuration(using transitionContext: UXViewControllerContextTransitioning?) -> TimeInterval { 0.4 }

    func animateTransition(using transitionContext: UXViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        guard
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        let toView = toViewController.view
        let fromView = fromViewController.view
        let containerBounds = container.bounds
        toView.frame = containerBounds
        container.addSubview(toView)

        let direction: CGFloat = operation == .push ? 1 : -1
        toView.frame = containerBounds.offsetBy(dx: 0, dy: -direction * containerBounds.height)

        UXView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: 0,
                       options: [],
                       animations: {
                           toView.frame = containerBounds
                           fromView.frame = containerBounds.offsetBy(dx: 0, dy: direction * containerBounds.height)
                       },
                       completion: { _ in
                           fromView.frame = containerBounds
                           transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                       })
    }
}
