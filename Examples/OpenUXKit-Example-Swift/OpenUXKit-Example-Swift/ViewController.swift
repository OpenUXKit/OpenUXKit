//
//  ViewController.swift
//  OpenUXKit-Example-Swift
//
//  Created by JH on 2024/5/18.
//

import Cocoa
import OpenUXKit

@objc(FirstViewController)
class FirstViewController: UXViewController {
    deinit {
        print("\(Self.self) is deinit")
    }
}

@objc(SecondViewController)
class SecondViewController: UXViewController {
    deinit {
        print("\(Self.self) is deinit")
    }
}

@objc(ThirdViewController)
class ThirdViewController: UXViewController {
    deinit {
        print("\(Self.self) is deinit")
    }
}

class ViewController: NSViewController {
    @IBOutlet var contentBox: NSBox!

    @IBOutlet var pushButton: NSButton!

    @IBOutlet var popButton: NSButton!

    lazy var navigationController = UXNavigationController(rootViewController: rootViewController).then {
        $0.delegate = self
    }

    lazy var rootViewController = UXViewController().then {
        $0.uxView.backgroundColor = .black
    }

    let firstBackgroundColor = NSColor.systemRed

    let secondBackgroundColor = NSColor.systemBlue

    let thirdBackgroundColor = NSColor.systemCyan

    lazy var backgroundColors = [
        firstBackgroundColor,
        secondBackgroundColor,
        thirdBackgroundColor,
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
        if navigationController.viewControllers.count <= backgroundColors.count {
            let vc = switch navigationController.viewControllers.count {
            case 1:
                FirstViewController()
            case 2:
                SecondViewController()
            case 3:
                ThirdViewController()
            default:
                UXViewController()
            }
            vc.uxView.backgroundColor = backgroundColors[navigationController.viewControllers.count - 1]
            navigationController.setViewControllers([vc], animated: true)
        }
        checButtonEnabled()
    }

    @IBAction func popButtonAction(_ sender: NSButton) {
        navigationController.popViewController(animated: true)
        checButtonEnabled()
    }

    func checButtonEnabled() {
        pushButton.isEnabled = navigationController.viewControllers.count <= backgroundColors.count
        popButton.isEnabled = navigationController.viewControllers.count > 1
    }
}

extension ViewController: UXNavigationControllerDelegate {
    func navigationController(_ navigationController: UXNavigationController, willShow viewController: UXViewController) {
        checButtonEnabled()
    }
}
