//
//  EPSideMenuPanGestureRecognizerStateChanged.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import UIKit

class EPSideMenuPanGestureRecognizerStateChanged: EPSideMenuPanGestureRecognizerState {
    
    func computeNewCenterPosition(panGestureRecognizer: UIPanGestureRecognizer) -> CGPoint {
        return CGPoint(x: panGestureRecognizer.view!.center.x + getDeltaFor(panGestureRecognizer).x, y: panGestureRecognizer.view!.center.y)
    }
    
    override func handleGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let newCenter:CGPoint = computeNewCenterPosition(panGestureRecognizer)
        
        if (newCenter.x >= panGestureRecognizer.view!.frame.size.width/2) {
            delegate?.leadingConstraintConstant = newCenter.x - panGestureRecognizer.view!.frame.size.width/2
//            panGestureRecognizer.view!.center = newCenter;
        } else {
            delegate?.leadingConstraintConstant = 0.0
//            panGestureRecognizer.view!.center = CGPoint(x: panGestureRecognizer.view!.frame.size.width/2,
//                y: panGestureRecognizer.view!.frame.size.height/2);
        }
        panGestureRecognizer.setTranslation(CGPoint(x:0, y:0), inView:self.delegate!.mainView)
    }
}
