//
//  Toast.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/22.
//

import UIKit

class Toast {
    
    static func showToast(message : String, selfView: UIViewController?) {
        
        let toastLabel = UILabel(frame: CGRect(x: (selfView?.view.frame.size.width)! - 20, y: (selfView?.view.frame.size.height)! - (selfView?.tabBarController?.tabBar.frame.height ?? 0) - 50, width: (selfView?.view.frame.size.width)! - 40, height: 35))
        toastLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        selfView?.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.6, delay: 3.0, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
            
        }, completion: {
            (isCompleted) in toastLabel.removeFromSuperview()
            
        })
        
    }
    
}
