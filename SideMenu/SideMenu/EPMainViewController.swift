//
//  ViewController.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import UIKit

class EPMainViewController: UIViewController, EPSideMenuPanGestureRecognizerDelegate, EPMenuConfigurationProvider, EPMenuToggleDelegate {
    
    let MENU_DISTANCE_FROM_THE_EDGE_OF_THE_SCREEN:CGFloat = 60.0
    let DEFAULT_MENU_ANIMATION_DURATION:NSTimeInterval = 0.25
    
    weak var centerNavigationController: UINavigationController?
    weak var centerViewController: EPDashboardViewController?
    weak var panGestureRecognizerView: UIView?
    
    var panGestureRecognizer: EPSideMenuPanGestureRecognizer!
    
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    
    var leftTableViewController: EPMenuTableViewController!
    
    private func setupCenterView() {
        self.centerNavigationController = self.childViewControllers.first as? UINavigationController
        self.centerViewController = self.centerNavigationController?.topViewController as? EPDashboardViewController
        self.centerViewController?.delegate = self
    }
    
    private func setupMenuView() {
        let storyboard = self.storyboard
        
        self.leftTableViewController = storyboard!.instantiateViewControllerWithIdentifier("EPMenuTableViewController") as! EPMenuTableViewController
        self.addChildViewController(self.leftTableViewController)
        self.leftTableViewController.didMoveToParentViewController(self)
        self.view.addSubview(self.leftTableViewController.view)
        self.view.sendSubviewToBack(self.leftTableViewController.view)
    }
    
    private func setupPanGestureRecognizer() {
        panGestureRecognizerView = centerNavigationController?.view.superview
        panGestureRecognizer = EPSideMenuPanGestureRecognizer(panGestureOwnerView: panGestureRecognizerView!)
        panGestureRecognizer.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.setupCenterView()
        self.setupMenuView()
        self.setupPanGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {

    }
    
    /******** EPMenuConfigurationProvider protocol methods *********/
    
    var menuDistanceFromTheEdgeOfTheScreen: CGFloat {
        return MENU_DISTANCE_FROM_THE_EDGE_OF_THE_SCREEN
    }
    
    var defaultMenuAnimationDuration: NSTimeInterval {
        return DEFAULT_MENU_ANIMATION_DURATION
    }
    
    /************* EPSideMenuPanGestureRecognizerDelegate *************/
    weak var mainView: UIView? {
        return view
    }
    
    var leadingConstraintConstant: CGFloat {
        get {
            return containerViewLeadingConstraint.constant
        }
        set(newLeadingConstraintConstant) {
            containerViewLeadingConstraint.constant = newLeadingConstraintConstant
        }
    }
    
    /***********************************************************************************
     *
     * EPMenuToggleDelegate methods
     *
     **********************************************************************************/

    func showMenuAnimatedWithDuration(duration: NSTimeInterval) {
//        let parentView = self.centerNavigationController?.view.superview?.superview
//        let containerView = self.centerNavigationController?.view.superview!
//        print(parentView == view)
//        NSLayoutConstraint(item: containerView!, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .LeftMargin, multiplier: 1.0, constant: 50.0).active = true

        self.containerViewLeadingConstraint.constant = self.view.frame.width - 60.0
        
        UIView.animateWithDuration(duration, delay: 0, options: [.BeginFromCurrentState, .CurveLinear], animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func hideMenuAnimatedWithDuration(duration: NSTimeInterval) {
        self.containerViewLeadingConstraint.constant = 0
        
        UIView.animateWithDuration(duration, delay: 0, options: [.BeginFromCurrentState, .CurveLinear], animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)

    }

}
