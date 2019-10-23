//
//  UIColor+hex.swift
//  survey-list-app
//
//  Created by amnmblchllng on 23.10.19.
//  Copyright © 2019 amnmblchllng. All rights reserved.
//

import UIKit

extension UIColor {
    
    // Usage: UIColor(hexRgba: 0xAABBCCDD)
    convenience init(hexRgba: Int) {
        let r = CGFloat((hexRgba >> 24) & 0xFF) / 255.0
        let g = CGFloat((hexRgba >> 16) & 0xFF) / 255.0
        let b = CGFloat((hexRgba >> 8) & 0xFF) / 255.0
        let a = CGFloat((hexRgba >> 0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
}
