//
//  UIColorExtension.swift
//  PageKit
//
//  Created by yansong li on 2017-07-16.
//  Copyright © 2017 yansong li. All rights reserved.
//

import UIKit

extension UIColor {
  /// Return a random color.
  static func randomColor() -> UIColor {
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
  }
}
