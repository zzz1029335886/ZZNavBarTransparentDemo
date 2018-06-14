//
//  ETNavBarTransparent.swift
//  ETNavBarTransparentDemo
//
//  Created by Bing on 2017/3/1.
//  Copyright © 2017年 tanyunbing. All rights reserved.
//

import UIKit

extension UIColor {
    // System default bar tint color
    open class var defaultNavBarTintColor: UIColor {
        return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1.0)
    }
    open class var defaultNavBarColor: UIColor {
        return UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
    }
}

extension DispatchQueue {
    
    private static var onceTracker = [String]()
    
    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}

extension UINavigationController {
    fileprivate struct AssociatedKeys {
        static var navBarBgColors: [UIColor] = []
    }
    
    open var navBarBgColors: [UIColor] {
        get {
            guard let colors = objc_getAssociatedObject(self, &UINavigationController.AssociatedKeys.navBarBgColors) as? [UIColor] else {
                return [self.viewControllers.first?.navBarColor ?? UIColor.defaultNavBarColor]
            }
            return colors
            
        }
        set {
            objc_setAssociatedObject(self, &UINavigationController.AssociatedKeys.navBarBgColors, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override func viewDidLoad() {
        UINavigationController.swizzle()
        super.viewDidLoad()
    }
    
    private static let onceToken = UUID().uuidString + "UINavigationController"
    
    class func swizzle() {
        guard self == UINavigationController.self else { return }
        
        DispatchQueue.once(token: onceToken) {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                #selector(popToViewController),
                #selector(popToRootViewController),
                #selector(pushViewController(_:animated:)),
            ]
            
            for selector in needSwizzleSelectorArr {
                
                let str = ("et_" + selector.description).replacingOccurrences(of: "__", with: "_")
                // popToRootViewControllerAnimated: et_popToRootViewControllerAnimated:
                
                let originalMethod = class_getInstanceMethod(self, selector)
                let swizzledMethod = class_getInstanceMethod(self, Selector(str))
                if originalMethod != nil && swizzledMethod != nil {
                    method_exchangeImplementations(originalMethod!, swizzledMethod!)
                }
            }
        }
    }
    
    @objc func et_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let topViewController = topViewController, let coordinator = topViewController.transitionCoordinator else {
            et_updateInteractiveTransition(percentComplete)
            return
        }
        
        let fromViewController = coordinator.viewController(forKey: .from)
        let toViewController = coordinator.viewController(forKey: .to)
        
        // Bg Alpha
        let fromAlpha = fromViewController?.navBarBgAlpha ?? 0
        let toAlpha = toViewController?.navBarBgAlpha ?? 0
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete
        
        
        // Tint Color
        let fromColor = fromViewController?.navBarTintColor ?? .blue
        let toColor = toViewController?.navBarTintColor ?? .blue
        let newColor = averageColor(fromColor: fromColor, toColor: toColor, percent: percentComplete)
        
        //backgruond Color
        let backgroundFromColor = fromViewController?.navBarColor
        let backgroundToColor = toViewController?.navBarColor
        
        let backgroundColor = averageColor(fromColor: backgroundFromColor!, toColor: backgroundToColor!, percent: percentComplete)
        
        navigationBar.tintColor = newColor
//        navigationBar.backgroundColor = backgroundColor
//        self.viewControllers.last?.view.backgroundColor = backgroundColor
        
        setNeedsNavigationBackground(alpha: newAlpha,color: backgroundColor)
        et_updateInteractiveTransition(percentComplete)
    }
    
    // Calculate the middle Color with translation percent
    private func averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
        
        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)
        
        let nowRed = fromRed + (toRed - fromRed) * percent
        let nowGreen = fromGreen + (toGreen - fromGreen) * percent
        let nowBlue = fromBlue + (toBlue - fromBlue) * percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent
        
        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }
    
    func printColor(_ fromColor:UIColor) {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)
//        print(fromRed,fromGreen,fromBlue,fromAlpha)
        
    }
    
    @objc func et_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        setNeedsNavigationBackground(alpha: viewController.navBarBgAlpha,color: viewController.navBarColor)
        self.navBarBgColors.removeLast()
        return et_popToViewController(viewController, animated: animated)
    }
    
    @objc func et_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        setNeedsNavigationBackground(alpha: viewControllers.first?.navBarBgAlpha ?? 0)
        navigationBar.tintColor = viewControllers.first?.navBarTintColor
        self.navBarBgColors = [self.viewControllers.first?.navBarColor ?? UIColor.defaultNavBarColor]
        return et_popToRootViewControllerAnimated(animated)
    }
    
    @objc func et_pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.navBarBgColors.append(viewController.navBarColor)
        et_pushViewController(viewController, animated: animated)
    }

    fileprivate func setNeedsNavigationBackground(alpha: CGFloat, color: UIColor = UIColor.defaultNavBarColor) {
        
        navigationBar.barTintColor = color
        
        let barBackgroundView = navigationBar.subviews[0]
        let valueForKey = barBackgroundView.value(forKey:)
        
        if let shadowView = valueForKey("_shadowView") as? UIView {
            shadowView.alpha = alpha
            shadowView.isHidden = alpha == 0
        }

        if navigationBar.isTranslucent {
            if #available(iOS 10.0, *) {
                if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, navigationBar.backgroundImage(for: .default) == nil {
                    backgroundEffectView.alpha = alpha
                    backgroundEffectView.subviews.last?.backgroundColor = color

                    return
                }
                
            } else {
                if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                    backdropEffectView.alpha = alpha
                    backdropEffectView.subviews.last?.backgroundColor = color

                    return
                }
            }
        }
        barBackgroundView.alpha = alpha
     

    }
}

extension UINavigationController: UINavigationBarDelegate {
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let topVC = topViewController, let coor = topVC.transitionCoordinator, coor.initiallyInteractive {
            if #available(iOS 10.0, *) {
                coor.notifyWhenInteractionChanges({ (context) in
                    self.dealInteractionChanges(context)
                })
            } else {
                coor.notifyWhenInteractionEnds({ (context) in
                    self.dealInteractionChanges(context)
                })
            }
            return true
        }
        
        let itemCount = navigationBar.items?.count ?? 0
        let n = viewControllers.count >= itemCount ? 2 : 1
        let popToVC = viewControllers[viewControllers.count - n]
        
        popToViewController(popToVC, animated: true)
        return true
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
        setNeedsNavigationBackground(alpha: topViewController?.navBarBgAlpha ?? 0)
        navigationBar.tintColor = topViewController?.navBarTintColor
        return true
    }
    
    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        let animations: (UITransitionContextViewControllerKey) -> () = {
            let nowAlpha = context.viewController(forKey: $0)?.navBarBgAlpha ?? 0
            self.setNeedsNavigationBackground(alpha: nowAlpha,color: context.viewController(forKey: $0)?.navBarColor ?? UIColor.defaultNavBarColor)
            
            self.navigationBar.tintColor = context.viewController(forKey: $0)?.navBarTintColor
        }
        
        
        if context.isCancelled {
            let cancelDuration: TimeInterval = context.transitionDuration * Double(context.percentComplete)
            UIView.animate(withDuration: cancelDuration) {
                self.navigationBar.barTintColor = self.navBarBgColors.last
                animations(.from)
            }
        } else {
            let finishDuration: TimeInterval = context.transitionDuration * Double(1 - context.percentComplete)
            UIView.animate(withDuration: finishDuration) {
                self.navBarBgColors.removeLast()
                self.navigationBar.barTintColor = self.navBarBgColors.last
                animations(.to)
            }
        }

    }
}

extension UIViewController {
    
    
    
//    private static let onceToken = UUID().uuidString + "UIViewController"
//
//    @objc class func swizzle() {
//        guard self == UIViewController.self else { return }
//
//        DispatchQueue.once(token: onceToken) {
//            let needSwizzleSelectorArr = [
//                #selector(viewDidAppear(_:)),
//                //                #selector(viewDidLoad)
//            ]
//
//            for selector in needSwizzleSelectorArr {
//
//                let str = ("et_" + selector.description).replacingOccurrences(of: "__", with: "_")
//                // popToRootViewControllerAnimated: et_popToRootViewControllerAnimated:
//
//                let originalMethod = class_getInstanceMethod(self, selector)
//                let swizzledMethod = class_getInstanceMethod(self, Selector(str))
//                if originalMethod != nil && swizzledMethod != nil {
//                    method_exchangeImplementations(originalMethod!, swizzledMethod!)
//                }
//            }
//        }
//    }
//
//    open override func viewDidLoad() {
//        UIViewControllero.swizzle()
//
//    }
//
//    @objc func et_viewDidAppear(_ animated: Bool) {
//        print(1)
//        et_viewDidAppear(animated)
//    }
    
    fileprivate struct AssociatedKeys {
        static var navBarBgAlpha: CGFloat = 1.0
        static var navBarTintColor: UIColor = UIColor.defaultNavBarTintColor
        static var navBarColor: UIColor = UIColor.defaultNavBarColor
    }
    
    open var navBarBgAlpha: CGFloat {
        get {
            guard let alpha = objc_getAssociatedObject(self, &AssociatedKeys.navBarBgAlpha) as? CGFloat else {
                return 1.0
            }
            return alpha
            
        }
        set {
            let alpha = max(min(newValue, 1), 0) // 必须在 0~1的范围
            
            objc_setAssociatedObject(self, &AssociatedKeys.navBarBgAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Update UI
            navigationController?.setNeedsNavigationBackground(alpha: alpha,color: navBarColor)
        }
    }
    
    open var navBarTintColor: UIColor {
        get {
            guard let tintColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarTintColor) as? UIColor else {
                return UIColor.defaultNavBarTintColor
            }
            return tintColor
            
        }
        set {
            navigationController?.navigationBar.tintColor = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.navBarTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open var navBarColor: UIColor {
        get{
            guard let navBarColor = objc_getAssociatedObject(self, &AssociatedKeys.navBarColor) as? UIColor else {
                return UIColor.defaultNavBarColor
            }
            return navBarColor
        }
        set {
            self.navigationController?.printColor(newValue)
            navigationController?.navigationBar.barTintColor = newValue
            objc_setAssociatedObject(self, &AssociatedKeys.navBarColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
}
