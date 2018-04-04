//
//  DLPageMenu.swift
//  DLPageMenu
//
//  Created by Linh Vo D. on 4/4/18.
//  Copyright © 2018 Linh Vo D. All rights reserved.
//

import UIKit

@objc public protocol DLPageMenuDelegate {
    @objc optional func willMoveToPage(_ pageMenu: DLPageMenu, from viewController: UIViewController, index currentViewControllerIndex: Int)
    @objc optional func didMoveToPage(_ pageMenu: DLPageMenu, to viewController: UIViewController, index currentViewControllerIndex: Int)
}

public struct PageMenuOption {

    public var frame: CGRect
    public var menuItemHeight: CGFloat
    public var menuItemWidth: CGFloat
    public var menuItemBackgroundColorNormal: UIColor
    public var menuItemBackgroundColorSelected: UIColor
    public var menuTitleMargin: CGFloat
    public var menuTitleFont: UIFont
    public var menuTitleColorNormal: UIColor
    public var menuTitleColorSelected: UIColor
    public var menuIndicatorHeight: CGFloat
    public var menuIndicatorColor: UIColor

    public init(frame: CGRect,
                menuItemHeight: CGFloat = 44,
                menuItemWidth: CGFloat = 0,
                menuItemBackgroundColorNormal: UIColor = .white,
                menuItemBackgroundColorSelected: UIColor = .white,
                menuTitleMargin: CGFloat = 40,
                menuTitleFont: UIFont = .systemFont(ofSize: 16),
                menuTitleColorNormal: UIColor = .lightGray,
                menuTitleColorSelected: UIColor = .black,
                menuIndicatorHeight: CGFloat = 3,
                menuIndicatorColor: UIColor = .darkGray) {
        self.frame = frame
        self.menuItemHeight = menuItemHeight
        self.menuItemWidth = menuItemWidth
        self.menuItemBackgroundColorNormal = menuItemBackgroundColorNormal
        self.menuItemBackgroundColorSelected = menuItemBackgroundColorSelected
        self.menuTitleMargin = menuTitleMargin
        self.menuTitleFont = menuTitleFont
        self.menuTitleColorNormal = menuTitleColorNormal
        self.menuTitleColorSelected = menuTitleColorSelected
        self.menuIndicatorHeight = menuIndicatorHeight
        self.menuIndicatorColor = menuIndicatorColor
    }
}

// MARK: - DLPageMenu
open class DLPageMenu: UIView {

    open weak var delegate: DLPageMenuDelegate?

    let cellId = "PageMenuCell"
    var option = PageMenuOption(frame: .zero)
    var viewControllers = [UIViewController]()

    var menuScrollView: UIScrollView!
    var menuBorderLine: UIView!
    var collectionView: UICollectionView!

    public convenience init() {
        self.init(viewControllers: [], option: PageMenuOption(frame: .zero))
    }

    public init(viewControllers: [UIViewController], option: PageMenuOption) {
        super.init(frame: option.frame)
        self.viewControllers = viewControllers
        self.option = option
        backgroundColor = .white
        setupMenus()
        setupPageView()
        setuOrientationpNotification()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Scroll View (Buttons)
extension DLPageMenu: UIScrollViewDelegate {
    func setupMenus() {
        setupMenuScrollView()
        setupMenuButtons()
        setupMenuIndicatorBorder()
        addSubview(menuScrollView)
    }

    func setupMenuScrollView() {
        menuScrollView = UIScrollView()
        menuScrollView.backgroundColor = option.menuItemBackgroundColorNormal
        menuScrollView.delegate = self
        menuScrollView.isPagingEnabled = false
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.frame = CGRect(x: 0, y: 0,
                                      width: frame.size.width,
                                      height: option.menuItemHeight)
    }

    func setupMenuButtons() {
        var menuX: CGFloat = 0
        for i in 1...viewControllers.count {
            let viewControllerIndex = i - 1

            // Menu button
            let menuButton = UIButton(type: .custom)
            menuButton.tag = i
            menuButton.setBackgroundColor(option.menuItemBackgroundColorNormal, forState: .normal)
            menuButton.setBackgroundColor(option.menuItemBackgroundColorSelected, forState: .selected)
            menuButton.setTitle(viewControllers[viewControllerIndex].title, for: .normal)
            menuButton.setTitleColor(option.menuTitleColorNormal, for: .normal)
            menuButton.setTitleColor(option.menuTitleColorSelected, for: .selected)
            menuButton.titleLabel?.font = option.menuTitleFont
            menuButton.addTarget(self, action: #selector(selectedMenuItem(_:)), for: .touchUpInside)
            menuButton.isSelected = (viewControllerIndex == 0)

            // Resize Menu item based on option
            let buttonWidth = getMenuButtonWidth(button: menuButton)
            menuButton.frame = CGRect(x: menuX, y: 0,
                                      width: buttonWidth,
                                      height: option.menuItemHeight)
            menuScrollView.addSubview(menuButton)

            // Update x position
            menuX += buttonWidth
        }
        menuScrollView.contentSize.width = menuX
    }

    func setupMenuIndicatorBorder() {
        guard let firstMenuButton = menuScrollView.viewWithTag(1) as? UIButton else { return }
        menuBorderLine = UIView()
        menuBorderLine.backgroundColor = option.menuIndicatorColor
        menuBorderLine.frame = CGRect(
            x: firstMenuButton.frame.origin.x,
            y: firstMenuButton.frame.maxY - option.menuIndicatorHeight,
            width: firstMenuButton.frame.size.width,
            height: option.menuIndicatorHeight)
        menuScrollView.addSubview(menuBorderLine)
    }

    func updateMenuTitle(title: String, viewControllerIndex: Int) {
        let buttonIndex = viewControllerIndex + 1
        guard let menuButton = menuScrollView.viewWithTag(buttonIndex)
            as? UIButton else { return }
        menuButton.setTitle(title, for: .normal)
        var rect = menuButton.frame
        rect.size.width = getMenuButtonWidth(button: menuButton)
        menuButton.frame = rect
        var minX = menuButton.frame.minX
        for i in buttonIndex...viewControllers.count {
            guard let button = menuScrollView.viewWithTag(i) as? UIButton else { continue }
            var origin = button.frame.origin
            origin.x = minX
            button.frame.origin = origin
            minX = button.frame.maxX
        }
        let currentButtonIndex = getCurrentMenuButtonIndex()
        updateIndicatorPosition(menuButtonIndex: currentButtonIndex)
    }

    func updateIndicatorPosition(menuButtonIndex: Int) {
        guard let menuButton = menuScrollView.viewWithTag(menuButtonIndex) else { return }
        var rect = menuBorderLine.frame
        rect.origin.x = menuButton.frame.minX
        rect.size.width = menuButton.frame.size.width
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
            self.menuBorderLine.frame = rect
        }, completion: nil)
    }

    func updateButtonStatus(menuButtonIndex: Int) {
        guard let menuButton = menuScrollView.viewWithTag(menuButtonIndex) as? UIButton else { return }
        for subview in menuScrollView.subviews {
            if let button = subview as? UIButton {
                button.setTitleColor(option.menuTitleColorNormal, for: .normal)
                button.isSelected = false
            }
        }
        menuButton.isSelected = true
        menuButton.setTitleColor(option.menuTitleColorSelected, for: .normal)
    }

    func updateMenuScrollOffsetIfNeeded(menuButtonIndex: Int) {
        guard let menuButton = menuScrollView.viewWithTag(menuButtonIndex) else { return }
        let collectionPagingWidth = collectionView.frame.size.width
        let currentMenuOffsetMinX = menuScrollView.contentOffset.x
        let currentMenuOffsetMaxX = currentMenuOffsetMinX + collectionPagingWidth
        let selectedButtonMinX = menuButton.frame.minX
        let selectedButtonMaxX = menuButton.frame.maxX
        if selectedButtonMinX < currentMenuOffsetMinX {
            // out of screen (left)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                self.menuScrollView.contentOffset.x = selectedButtonMinX
            }, completion: nil)
        } else if selectedButtonMaxX > currentMenuOffsetMaxX {
            // out of screen (right)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseIn], animations: {
                let newOffsetX = selectedButtonMinX - (collectionPagingWidth - menuButton.frame.size.width)
                self.menuScrollView.contentOffset.x = newOffsetX
            }, completion: nil)
        }
    }

    @objc func selectedMenuItem(_ sender: UIButton) {
        // DLPageMenuDelegate [WillMoveToPage]
        let currentViewControllerIndex = getCurrentMenuButtonIndex() - 1
        delegate?.willMoveToPage?(self,
                                  from: viewControllers[currentViewControllerIndex],
                                  index: currentViewControllerIndex)

        // Move to selected page
        let buttonIndex = sender.tag
        let nextViewControllerIndex = sender.tag - 1
        updateIndicatorPosition(menuButtonIndex: buttonIndex)
        updateButtonStatus(menuButtonIndex: buttonIndex)
        updateMenuScrollOffsetIfNeeded(menuButtonIndex: buttonIndex)
        collectionView.scrollToItem(
            at: IndexPath.init(row: nextViewControllerIndex, section: 0),
            at: .left,
            animated: true)
    }
}

// MARK: - Collection View (ViewControllers)
extension DLPageMenu: UICollectionViewDelegate, UICollectionViewDataSource {
    func setupPageView() {
        // CollectionView Layout
        let collectionViewHeight = frame.size.height - menuScrollView.frame.maxY
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.sectionInset = .zero
        collectionViewLayout.itemSize = CGSize(
            width: frame.size.width,
            height: collectionViewHeight)

        // CollectionView
        collectionView = UICollectionView(
            frame: CGRect(x: 0,
                          y: menuScrollView.frame.maxY,
                          width: frame.size.width,
                          height: collectionViewHeight),
            collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        addSubview(collectionView)
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        guard let controllerView = viewControllers[indexPath.row].view else {
            return UICollectionViewCell()
        }
        controllerView.frame = cell.bounds
        cell.addSubview(controllerView)
        return cell
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == menuScrollView { return }

        // DLPageMenuDelegate [WillMoveToPage]
        let viewControllerIndex = getCurrentMenuButtonIndex() - 1
        delegate?.willMoveToPage?(self,
                                  from: viewControllers[viewControllerIndex],
                                  index: viewControllerIndex)
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == menuScrollView { return }
        let buttonIndex = getCurrentMenuButtonIndex()
        updateIndicatorPosition(menuButtonIndex: buttonIndex)
        updateButtonStatus(menuButtonIndex: buttonIndex)
        updateMenuScrollOffsetIfNeeded(menuButtonIndex: buttonIndex)

        // DLPageMenuDelegate [DidMoveToPage]
        let viewControllerIndex = buttonIndex - 1
        delegate?.didMoveToPage?(self,
                                 to: viewControllers[viewControllerIndex],
                                 index: viewControllerIndex)
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == menuScrollView { return }

        // DLPageMenuDelegate [DidMoveToPage]
        let viewControllerIndex = getCurrentMenuButtonIndex() - 1
        delegate?.didMoveToPage?(self,
                                 to: viewControllers[viewControllerIndex],
                                 index: viewControllerIndex)
    }
}

// MARK: - Device Orientation
extension DLPageMenu {
    func setuOrientationpNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override open func removeFromSuperview() {
        super.removeFromSuperview()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    @objc func didChangeRotation() {
        menuScrollView.frame = CGRect(x: 0, y: 0,
                                      width: frame.size.width,
                                      height: option.menuItemHeight)

        // CollectionView Layout
        let collectionViewHeight = frame.size.height - menuScrollView.frame.maxY
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.sectionInset = .zero
        collectionViewLayout.itemSize = CGSize(
            width: frame.size.width,
            height: collectionViewHeight)

        // CollectionView
        collectionView.frame = CGRect(x: 0,
                                      y: menuScrollView.frame.maxY,
                                      width: frame.size.width,
                                      height: collectionViewHeight)
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.collectionViewLayout.invalidateLayout()

        // Adjust to collection view offset
        let currentViewControllerIndex = getCurrentMenuButtonIndex() - 1
        collectionView.scrollToItem(
            at: IndexPath.init(row: currentViewControllerIndex, section: 0),
            at: .left,
            animated: true)

        // Adjust to menu button offset
        let buttonIndex = currentViewControllerIndex + 1
        updateMenuScrollOffsetIfNeeded(menuButtonIndex: buttonIndex)
    }
}

// MARK: - Supporting Functions
extension DLPageMenu {
    func getCurrentMenuButtonIndex() -> Int {
        let offsetX = collectionView.contentOffset.x
        let collectionViewWidth = collectionView.bounds.size.width
        return Int(ceil(offsetX / collectionViewWidth)) + 1
    }

    func getMenuButtonWidth(button: UIButton) -> CGFloat {
        var buttonWidth: CGFloat = 0
        if option.menuItemWidth == 0 {
            // based on title text
            buttonWidth = button.sizeThatFits(
                CGSize(width: CGFloat.greatestFiniteMagnitude,
                       height: option.menuItemHeight)).width + option.menuTitleMargin / 2
        } else {
            // based on specified width
            buttonWidth = option.menuItemWidth + option.menuTitleMargin / 2
        }
        return buttonWidth
    }
}

// MARK: - UIButton Extension
extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(colorImage, for: forState)
    }
}

