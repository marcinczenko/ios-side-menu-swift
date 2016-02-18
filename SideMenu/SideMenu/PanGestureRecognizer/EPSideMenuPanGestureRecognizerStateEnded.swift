//
//  EPSideMenuPanGestureRecognizerStateEnded.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import UIKit

class EPSideMenuPanGestureRecognizerStateEnded: EPSideMenuPanGestureRecognizerState {
    let GOING_BACK_ANIMATION_DURATION: NSTimeInterval = 0.25
    
    func handleMovingInLeftHalf(panGestureRecognizer: UIPanGestureRecognizer) {
        if movingRight {
            if swiping {
                delegate?.showMenuAnimatedWithDuration(computeAnimationDuration(panGestureRecognizer))
            } else {
                delegate?.hideMenuAnimatedWithDuration(GOING_BACK_ANIMATION_DURATION);
            }
        } else {
            delegate?.hideMenuAnimatedWithDuration(computeAnimationDuration(panGestureRecognizer))
        }
    }
    
    func handleMovingInRightHalf(panGestureRecognizer: UIPanGestureRecognizer) {
        if movingLeft {
            if swiping {
                delegate?.hideMenuAnimatedWithDuration(computeAnimationDuration(panGestureRecognizer))
            } else {
                delegate?.showMenuAnimatedWithDuration(GOING_BACK_ANIMATION_DURATION);
            }
        } else {
            delegate?.showMenuAnimatedWithDuration(computeAnimationDuration(panGestureRecognizer))
        }
    }
    
    override func handleGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        super.handleGesture(panGestureRecognizer)
        
        if isInTheRightHalfOfTheScreen(panGestureRecognizer) {
            handleMovingInRightHalf(panGestureRecognizer)
        } else {
            handleMovingInLeftHalf(panGestureRecognizer)
        }
    }
}
