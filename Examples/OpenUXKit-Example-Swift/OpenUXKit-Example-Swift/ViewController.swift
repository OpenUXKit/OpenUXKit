//
//  ViewController.swift
//  OpenUXKit-Example-Swift
//
//  Thin host that wires the storyboard window to an in-code UXNavigationController.
//  Every demo is pushed onto this navigation stack so the showcase exercises the
//  navigation bar, toolbar, accessory bar, scope bar and back-gesture stack in one
//  place.
//

import Cocoa
import OpenUXKit

final class ViewController: NSViewController {
    private lazy var rootViewController = ShowcaseHomeViewController()

    private lazy var navigationController = UXNavigationController(rootViewController: rootViewController)

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 960, height: 640))
        view.autoresizingMask = [.width, .height]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(navigationController)
        let navigationView = navigationController.view
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(navigationView)
        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.topAnchor),
            navigationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
