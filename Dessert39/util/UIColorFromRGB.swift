//
//  UIColorFromRGB.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit

class UIColorFromRGB {
    
    static func colorInit(_ alpha: CGFloat, rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
}
