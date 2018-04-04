//
//  ViewController.swift
//  PageMenu
//
//  Created by Linh Vo D. on 4/2/18.
//  Copyright © 2018 Linh Vo D. All rights reserved.
//

import UIKit
import DLPageMenu

class ViewController: UIViewController {

    var pageMenu: DLPageMenu!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Init View Contollers
        let viewControllers = getViewControllers()

        // Page menu UI option
        let option = getPageMenuOption()

        // Init Page Menu with view controllers and UI option
        pageMenu = DLPageMenu(viewControllers: viewControllers, option: option)
        pageMenu.delegate = self
        pageMenu.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(pageMenu)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if UIDevice.current.orientation == .portrait {
            pageMenu.frame = CGRect(
                x: 0, y: 20, width: view.frame.size.width, height: view.frame.size.height - 20)
        } else {
            pageMenu.frame = CGRect(
                x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        }
    }
}

// MARK: - PageMenuViewDelegate
extension ViewController: DLPageMenuDelegate {
    func willMoveToPage(_ pageMenu: DLPageMenu, from viewController: UIViewController, index currentViewControllerIndex: Int) {
        print("---------")
        print("willMoveToPage: ", viewController.title!)
    }

    func didMoveToPage(_ pageMenu: DLPageMenu, to viewController: UIViewController, index currentViewControllerIndex: Int) {
        print("didMoveToPage: ", viewController.title!)
    }
}

// MARK: - Model
extension ViewController {
    func getPageMenuOption() -> PageMenuOption {
        var option = PageMenuOption(frame:
            CGRect(x: 0, y: 20,
                   width: view.frame.size.width,
                   height: view.frame.size.height - 20))
        option.menuItemHeight = 44
        option.menuTitleFont = .boldSystemFont(ofSize: 16)
        option.menuTitleColorNormal = .lightGray
        option.menuTitleColorSelected = .black
        option.menuItemBackgroundColorNormal = .white
        option.menuItemBackgroundColorSelected = .white
        option.menuIndicatorColor = .black
        return option
    }

    func getViewControllers() -> [UIViewController] {
        var viewControllers = [UIViewController]()
        let names = ["Lionel Messi", "Neymar", "Xavi", "Andres Iniesta", "Sergio Busquets", "Thierry Henry", "Abidal", "Alves", "Carles Puyol", "Gerard Pique"]
        for name in names {
            let viewController = UIViewController()
            viewController.title = name
            viewController.view.backgroundColor = UIColor(red: CGFloat(arc4random_uniform(256))/255, green: CGFloat(arc4random_uniform(256))/255, blue: CGFloat(arc4random_uniform(256))/255, alpha: 1)
            viewControllers.append(viewController)
        }
        return viewControllers
    }
}
