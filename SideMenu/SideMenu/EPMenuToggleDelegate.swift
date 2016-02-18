//
//  EPMenuToggleDelegate.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import CoreGraphics

protocol EPMenuToggleDelegate: class {
    func showMenuAnimatedWithDuration(duration: NSTimeInterval)
    func hideMenuAnimatedWithDuration(duration: NSTimeInterval)
}
