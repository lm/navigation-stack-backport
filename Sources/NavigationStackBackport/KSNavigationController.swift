// Forked from https://github.com/coffellas-cto/KSNavigationController

//
//  KSNavigationController.m
//
//  Copyright © 2016 Alex Gordiyenko. All rights reserved.
//

/*
 The MIT License (MIT)
 
 Copyright (c) 2016 A. Gordiyenko
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#if os(macOS)
import Cocoa

// MARK: Stack

class _KSStackItem<T> : NSObject {
    var value: T
    var next: _KSStackItem<T>?
    init(_ value: T) {
        self.value = value
    }
}

class _KSStack<T>: NSObject {
    fileprivate var _head: _KSStackItem<T>?
    fileprivate var _count: UInt = 0
    var headValue: T? {
        get {
            return self._head?.value
        }
    }
    var count: UInt {
        get {
            return self._count
        }
    }
    
    func push(_ object: T) -> Void {
        let item = _KSStackItem(object)
        item.next = self._head
        self._head = item
        self._count += 1
    }
    
    func pop() -> T? {
        guard self._head != nil else {
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "Popped an empty stack", userInfo: nil).raise()
            return nil
        }
        
        let retVal = self._head?.value
        self._head = self._head?.next
        self._count -= 1
        return retVal
    }
    
    func iterate(_ block: (T) -> (Void)) -> Void {
        var item = self._head
        while true {
            if let item = item {
                block(item.value)
            } else {
                break
            }
            
            item = item?.next
        }
    }

}

protocol KSNavigationControllerDelegate: NSObject {
    func navigationController(_ navigationController: KSNavigationController, didShow viewController: NSViewController, animated: Bool)
}

// MARK: KSNavigationControllerCompatible

/**
 Protocol your `NSViewController` subclass must conform to.
 
 Conform to this protocol if you want your `NSViewController` subclass to work with `KSNavigationController`.
 */
protocol KSNavigationControllerCompatible {
    /**
     Navigation controller object which holds your `NSViewController` subclass.
     
     Warning: Do not set this properly by yourself.
     */
    var navigationController: KSNavigationController? {get set}
}

// MARK: KSNavigationController

/**
 This class mimics UIKit's `UINavigationController` behavior.
 
 Navigation bar is not implemented. All methods must be called from main thread.
 */
class KSNavigationController: NSViewController {
    
    private lazy var __addRootViewOnce: () = {
        if let rootViewController = rootViewController {
            self._activeView = rootViewController.view
        }
        self.addActiveViewAnimated(false, subtype: nil)
    }()
    
    // MARK: Properties
    
    weak var delegate: KSNavigationControllerDelegate?
    
    /** The root view controller on the bottom of the stack. */
    fileprivate(set) var rootViewController: NSViewController?
    
    /** The current view controller stack. */
    var viewControllers: [NSViewController] {
        get {
            var retVal = [NSViewController]()
            self._stack.iterate { (object: NSViewController) -> (Void) in
                retVal.append(object)
            }
            
            if let rootViewController = rootViewController {
                retVal.append(rootViewController)
            }
            return retVal
        }
    }
    
    /** Number of view controllers currently in stack. */
    var viewControllersCount: UInt {
        get {
            return self._stack.count + 1
        }
    }
    
    /** The top view controller on the stack. */
    var topViewController: NSViewController? {
        get {
            if self._stack.count > 0 {
                return self._stack.headValue;
            }
            
            return self.rootViewController;
        }
    }

    fileprivate var _activeView: NSView?
    fileprivate var _addRootViewOnceToken: Int = 0
    fileprivate var _stack: _KSStack<NSViewController> = _KSStack<NSViewController>()
    fileprivate var _transition: CATransition {
        get {
            let transition = CATransition()
            transition.type = CATransitionType.push
            self.view.animations = ["subviews": transition]
            return transition
        }
    }
    
    // MARK: Life Cycle
    
    /**
     Initializes and returns a newly created navigation controller.
     This method throws exception if `rootViewController` doesn't conform to `KSNavigationControllerCompatible` protocol.
     - parameter rootViewController: The view controller that resides at the bottom of the navigation stack.
     - returns: The initialized navigation controller object or nil if there was a problem initializing the object.
     */
    init?(rootViewController: NSViewController) {
        self.rootViewController = rootViewController
        super.init(nibName: nil, bundle: nil)
        if var rootViewController = rootViewController as? KSNavigationControllerCompatible {
            rootViewController.navigationController = self
        } else {
            NSException(name: NSExceptionName.internalInconsistencyException, reason: "`rootViewController` doesn't conform to `KSNavigationControllerCompatible`", userInfo: nil).raise()
            return nil
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.rootViewController = NSViewController()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        _ = self.__addRootViewOnce
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    // MARK: Public Methods
    
    func setViewControllers(_ viewControllers: [NSViewController], animated: Bool) {
        // TODO: Animate only once (not per layer) depending on whether the resulting root VC was behind or ahead in the previous viewControllers, like native iOS
        while(popViewControllerAnimated(true) != nil) { }
        for (index, viewController) in viewControllers.enumerated() {
            pushViewController(viewController, animated: index == (viewControllers.count - 1))
        }
    }
    
    /**
     Pushes a view controller onto the receiver’s stack and updates the display. Uses a horizontal slide transition.
     - parameter viewController: The view controller to push onto the stack.
     - parameter animated: Set this value to YES to animate the transition, NO otherwise.
     */
    func pushViewController(_ viewController: NSViewController, animated: Bool) {
        self._activeView?.removeFromSuperview()
        self._stack.push(viewController)
        if var viewControllerWithNav = viewController as? KSNavigationControllerCompatible {
            viewControllerWithNav.navigationController = self
        }
        
        self._activeView = viewController.view
        self.addActiveViewAnimated(animated, subtype: NSApp.userInterfaceLayoutDirection == .leftToRight ? CATransitionSubtype.fromRight.rawValue : CATransitionSubtype.fromLeft.rawValue)
    }
    
    /**
     Pops the top view controller from the navigation stack and updates the display.
     - parameter animated: Set this value to YES to animate the transition, NO otherwise.
     - returns: The popped view controller.
     */
    func popViewControllerAnimated(_ animated: Bool) -> NSViewController? {
        if self._stack.count == 0 {
            return nil
        }
        
        self._activeView?.removeFromSuperview()
        let retVal = self._stack.pop()
        self._activeView = self._stack.headValue?.view
        if self._activeView == nil, let rootViewController = rootViewController {
            self._activeView = rootViewController.view
        }
        
        self.addActiveViewAnimated(animated, subtype: NSApp.userInterfaceLayoutDirection == .leftToRight ? CATransitionSubtype.fromLeft.rawValue : CATransitionSubtype.fromRight.rawValue)
        return retVal
    }
    
    /**
     Pops until there's only a single view controller left on the stack. Returns the popped view controllers.
     - parameter animated: Set this value to YES to animate the transitions if any, NO otherwise.
     - returns: The popped view controllers.
     */
    func popToRootViewControllerAnimated(_ animated: Bool) -> [NSViewController]? {
        if self._stack.count == 0 {
            return nil;
        }
        
        var retVal = [NSViewController]()
        for _ in 1...self._stack.count {
            if let vc = self.popViewControllerAnimated(animated) {
                retVal.append(vc)
            }
        }
        
        return retVal
    }
    
    // MARK: Private Methods
    
    fileprivate func addActiveViewAnimated(_ animated: Bool, subtype: String?) {
        if animated {
            if let subtype = subtype {
                self._transition.subtype = CATransitionSubtype(rawValue: subtype)
            }
            self.view.animator().addSubview(self._activeView!)
        } else {
            self.view.addSubview(self._activeView!)
        }
        
        if let viewController = viewControllers.first {
            // TODO: Ensure it's after any animation finishes?
            delegate?.navigationController(self, didShow: viewController, animated: animated)
        }
    }
}
#endif
