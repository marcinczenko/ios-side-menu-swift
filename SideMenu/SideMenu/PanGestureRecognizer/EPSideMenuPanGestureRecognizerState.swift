//
//  EPSideMenuPanGestureRecognizerState.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import UIKit


class EPSideMenuPanGestureRecognizerState {
    
    let SWIPE_THRESHOLD:CGFloat = 600.0
    
    weak var delegate: protocol<EPSideMenuPanGestureRecognizerDelegate, EPMenuConfigurationProvider>?
    
    var currentVelocity: CGPoint = CGPoint(x: 0, y: 0)
    
    var movingLeft: Bool {
        return self.currentVelocity.x < 0
    }
    
    var movingRight: Bool {
        return self.currentVelocity.x > 0
    }
    
    var swiping: Bool {
        return fabs(self.currentVelocity.x) > SWIPE_THRESHOLD
    }
    
    func getDeltaFor(panGestureRecognizer: UIPanGestureRecognizer) -> CGPoint {
        return panGestureRecognizer.translationInView(self.delegate?.mainView)
    }
    
    func getVelocityFor(panGestureRecognizer: UIPanGestureRecognizer) -> CGPoint {
        return panGestureRecognizer.velocityInView(panGestureRecognizer.view)
    }
    
    func isInTheRightHalfOfTheScreen(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return fabs(panGestureRecognizer.view!.center.x - panGestureRecognizer.view!.frame.size.width/2) > panGestureRecognizer.view!.frame.size.width/2;
    }
    
    func computeRamainingDistanceTravel(panGestureRecognizer: UIPanGestureRecognizer) -> CGFloat {
        if self.movingRight {
            return panGestureRecognizer.view!.frame.size.width - panGestureRecognizer.view!.frame.origin.x - self.delegate!.menuDistanceFromTheEdgeOfTheScreen;
        } else {
            return panGestureRecognizer.view!.frame.origin.x;
        }
    }
    
    func normalizeDuration(duration:NSTimeInterval) -> NSTimeInterval
    {
        if duration > 0.50 {
            return 0.50;
        }
        
        if (duration < 0.05) {
            return 0.05;
        }
        return duration;
    }
    
    func computeAnimationDuration(panGestureRecognizer: UIPanGestureRecognizer) -> NSTimeInterval {
        let distanceToTravel: CGFloat = self.computeRamainingDistanceTravel(panGestureRecognizer)
        let normalizedVelocity: CGFloat = fabs(self.currentVelocity.x) * 0.8
        
        return self.normalizeDuration(Double(distanceToTravel / normalizedVelocity))
    }
    
    func handleGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        panGestureRecognizer.view!.layer.removeAllAnimations()

        self.currentVelocity = self.getVelocityFor(panGestureRecognizer)
    }
}
