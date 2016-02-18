//
//  EPSideMenuPanGestureRecognizer.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import UIKit


class EPSideMenuPanGestureRecognizer: NSObject, EPMenuConfigurationProvider, EPSideMenuPanGestureRecognizerDelegate, UIGestureRecognizerDelegate {
    weak var delegate: protocol<EPSideMenuPanGestureRecognizerDelegate, EPMenuConfigurationProvider>?
    
    var panRecognizer: UIPanGestureRecognizer!
    
    var stateBegan: EPSideMenuPanGestureRecognizerStateBegan!
    var stateChanged: EPSideMenuPanGestureRecognizerStateChanged!
    var stateEnded: EPSideMenuPanGestureRecognizerStateEnded!
    
    weak var state: EPSideMenuPanGestureRecognizerState?
    
    init(panGestureOwnerView:UIView) {
        super.init()
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panRecognizer.minimumNumberOfTouches = 1
        panRecognizer.maximumNumberOfTouches = 1
        panRecognizer.delegate = self
        
        panGestureOwnerView.addGestureRecognizer(panRecognizer)
        
        setupStates()
    }
    
    func setupStates() {
        stateBegan = EPSideMenuPanGestureRecognizerStateBegan()
        stateBegan.delegate = self
        stateChanged = EPSideMenuPanGestureRecognizerStateChanged()
        stateChanged.delegate = self
        stateEnded = EPSideMenuPanGestureRecognizerStateEnded()
        stateEnded.delegate = self
    }
    
    func setStateFrom(panGestureRecognizer: UIPanGestureRecognizer) {
        switch panGestureRecognizer.state {
        case .Began:
            state = stateBegan
        case .Changed:
            state = stateChanged
        case .Ended:
            state = stateEnded
        default:
            state = nil
        }
    }
    
    func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        setStateFrom(panGestureRecognizer)
        state?.handleGesture(panGestureRecognizer)
    }
    
    /******** EPMenuConfigurationProvider protocol methods *********/
    
    var menuDistanceFromTheEdgeOfTheScreen: CGFloat {
        if let delegate = self.delegate {
            return delegate.menuDistanceFromTheEdgeOfTheScreen
        }
        return 60.0
    }
    
    var defaultMenuAnimationDuration: NSTimeInterval {
        if let delegate = self.delegate {
            return delegate.defaultMenuAnimationDuration
        }
        return 0.25
    }
    
    /******** EPSideMenuPanGestureRecognizerDelegate protocol methods *********/
    weak var mainView: UIView? {
        return delegate?.mainView
    }
    
    var leadingConstraintConstant: CGFloat {
        get {
            return delegate!.leadingConstraintConstant
        }
        set(newLeadingConstraintConstant) {
            delegate?.leadingConstraintConstant = newLeadingConstraintConstant
        }
    }
    
    func showMenuAnimatedWithDuration(duration: NSTimeInterval) {
        delegate?.showMenuAnimatedWithDuration(duration)
    }
    
    func hideMenuAnimatedWithDuration(duration: NSTimeInterval) {
        delegate?.hideMenuAnimatedWithDuration(duration)
    }
    
    /******** UIGestureRecognizerDelegate protocol methods *********/
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let velocity:CGPoint = panRecognizer.velocityInView(panRecognizer.view)
        
        if panRecognizer.view!.frame.origin.x == 0 && velocity.x<0 {
            return false;
        }
        
        if fabs(velocity.y)>100.0 && fabs(velocity.x)<300.0 {
            return false;
        }
        
        return true;
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
