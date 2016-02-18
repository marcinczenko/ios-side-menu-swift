//
//  EPSideMenuPanGestureRecognizerDelegate.swift
//  SideMenu
//
//  Created by Marcin Czenko on 18/02/16.
//  Copyright © 2016 Everyday Productive. All rights reserved.
//

import Foundation
import UIKit

protocol EPSideMenuPanGestureRecognizerDelegate: class, EPMenuToggleDelegate {
    weak var mainView: UIView? {get}
    var leadingConstraintConstant: CGFloat {get set}
}