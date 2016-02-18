//
//  EPDashboardViewController.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import UIKit

class EPDashboardViewController: UIViewController {
    
    weak var delegate: protocol<EPMenuToggleDelegate, EPMenuConfigurationProvider>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func isMenuVisible() -> Bool {
        return 0 == self.navigationController!.view.superview!.frame.origin.x ? false : true;

    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        if isMenuVisible() {
            delegate?.hideMenuAnimatedWithDuration(delegate!.defaultMenuAnimationDuration)
        } else {
            delegate?.showMenuAnimatedWithDuration(delegate!.defaultMenuAnimationDuration)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
