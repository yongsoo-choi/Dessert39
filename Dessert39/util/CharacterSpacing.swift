//
//  CharacterSpacing.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/06.
//

import UIKit

open class CharacterSpacing : UILabel {
    @IBInspectable open var characterSpacing:CGFloat = 1 {
        didSet {
            let attributedString = NSMutableAttributedString(string: self.text!)
            attributedString.addAttribute(NSAttributedString.Key.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }

    }
}
