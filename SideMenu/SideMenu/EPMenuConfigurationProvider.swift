//
//  EPMenuConfigurationProvider.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import CoreGraphics

protocol EPMenuConfigurationProvider: class {
    var menuDistanceFromTheEdgeOfTheScreen: CGFloat {get}
    var defaultMenuAnimationDuration: NSTimeInterval {get}
}
