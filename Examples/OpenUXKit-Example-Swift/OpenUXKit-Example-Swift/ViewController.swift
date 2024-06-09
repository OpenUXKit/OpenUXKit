//
//  ViewController.swift
//  OpenUXKit-Example-Swift
//
//  Created by JH on 2024/5/18.
//

import Cocoa
import UXKit

class ViewController: NSViewController {
    @IBOutlet var contentBox: NSBox!
    
    @IBOutlet var pushButton: NSButton!
    
    @IBOutlet var popButton: NSButton!

    lazy var navigationController = UXNavigationController(rootViewController: rootViewController).then {
        $0.delegate = self
    }

    lazy var rootViewController = UXViewController().then {
        $0.view.backgroundColor = .black
    }

    lazy var firstViewController = UXViewController().then {
        $0.view.backgroundColor = .systemRed
    }

    lazy var secondViewController = UXViewController().then {
        $0.view.backgroundColor = .systemBlue
    }

    lazy var thirdViewController = UXViewController().then {
        $0.view.backgroundColor = .systemCyan
    }

    lazy var viewControllers = [
        firstViewController,
        secondViewController,
        thirdViewController,
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        contentBox.contentView?.addSubview(navigationController.view)
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        navigationController.view.frame = contentBox.bounds
    }

    @IBAction func pushButtonAction(_ sender: NSButton) {
        if navigationController.viewControllers.count <= viewControllers.count {
            navigationController.pushViewController(viewControllers[navigationController.viewControllers.count - 1], animated: true)
        }
        checButtonEnabled()
        
    }

    @IBAction func popButtonAction(_ sender: NSButton) {
        navigationController.popViewController(animated: true)
        checButtonEnabled()
    }

    func checButtonEnabled() {
        pushButton.isEnabled = navigationController.viewControllers.count <= viewControllers.count
        popButton.isEnabled = navigationController.viewControllers.count > 1
    }
}

extension ViewController: UXNavigationControllerDelegate {
    func navigationController(_ navigationController: UXNavigationController, willShow viewController: UXViewController) {
        checButtonEnabled()
    }
}
