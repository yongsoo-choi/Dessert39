//
//  TextFieldComponent.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/14.
//

import Foundation
import UIKit

class TextFieldComp {
    
    func setInput(tf: UITextField) {
        
        let parentView = tf.superview
        let boarderView = parentView?.superview
        
        parentView?.layer.cornerRadius = 5
        boarderView?.layer.cornerRadius = 5
        
        parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
        boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
        
        if let clearButton = tf.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            clearButton.frame.size = CGSize(width: 16, height: 16)
        }
        
        tf.addTarget(self, action: #selector(textFieldDidBegin(textField:)), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: .editingDidEnd)
        
        parentView?.subviews.forEach({ subview in
            
            guard let btn: UIButton = subview as? UIButton else { return }
            
            if btn.imageView?.frame.width ?? 10 > 0 {
            
                btn.addTarget(self, action: #selector(passwordHide(sender:)), for: .touchUpInside)
                
            }
            
        })
        
    }
    
    func setUnableInput(tf: UITextField) {
        
        tf.isUserInteractionEnabled = false
        
        let parentView = tf.superview
        let boarderView = parentView?.superview
        
        parentView?.layer.cornerRadius = 5
        boarderView?.layer.cornerRadius = 5
        
        parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
        
        if let clearButton = tf.value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            clearButton.frame.size = CGSize(width: 16, height: 16)
        }
        
        tf.addTarget(self, action: #selector(textFieldDidBegin(textField:)), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: .editingDidEnd)
        
        parentView?.subviews.forEach({ subview in
            
            guard let lab: UILabel = subview as? UILabel else { return }
            lab.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
            
            guard let btn: UIButton = subview as? UIButton else { return }
            
            if btn.imageView?.frame.width ?? 10 > 0 {
            
                btn.addTarget(self, action: #selector(passwordHide(sender:)), for: .touchUpInside)
                
            }
            
        })
        
    }
    
    @objc func textFieldDidBegin(textField: UITextField) {

        let parentView = textField.superview
        let boarderView = parentView?.superview
        
        parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x484848)

        parentView?.subviews.forEach({ subview in
            
            guard let btn: UIButton = subview as? UIButton else { return }
            
            if btn.imageView?.frame.width ?? 10 > 0 {
            
                if textField.isSecureTextEntry {
                    btn.setImage(UIImage(named: "textfield_eyes"), for: .normal)
                } else {
                    btn.setImage(UIImage(named: "textfield_eyes_hide"), for: .normal)
                }
                
            }
            
        })
        
    }
    
    @objc func textFieldDidEnd(textField: UITextField) {

        if textField.text == "" {
            
            let parentView = textField.superview
            let boarderView = parentView?.superview
            
            parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
            boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
            
            parentView?.subviews.forEach({ subview in
                
                guard let btn: UIButton = subview as? UIButton else { return }
                if btn.imageView?.frame.width ?? 10 > 0 {
                
                    if textField.isSecureTextEntry {
                        btn.setImage(UIImage(named: "textfield_eyes_gray"), for: .normal)
                    } else {
                        btn.setImage(UIImage(named: "textfield_eyes_grayHide"), for: .normal)
                    }
                    
                }
                
            })
            
        }

    }
    
    @objc func passwordHide(sender: UIButton) {
        
        let parentView = sender.superview
        
        parentView?.subviews.forEach({ subview in
            
            guard let input: UITextField = subview as? UITextField else { return }
            
            if input.isSecureTextEntry {
                input.isSecureTextEntry = false
                
                if input.isEditing {
                    sender.setImage(UIImage(named: "textfield_eyes_hide"), for: .normal)
                } else {
                    sender.setImage(UIImage(named: "textfield_eyes_grayHide"), for: .normal)
                }
                
            } else {
                input.isSecureTextEntry = true
                sender.setImage(UIImage(named: "textfield_eyes"), for: .normal)
                
                if input.isEditing {
                    sender.setImage(UIImage(named: "textfield_eyes"), for: .normal)
                } else {
                    sender.setImage(UIImage(named: "textfield_eyes_gray"), for: .normal)
                }
            }
            
        })
        
    }
    
}
