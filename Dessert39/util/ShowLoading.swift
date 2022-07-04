//
//  ShowLoading.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/01.
//

import UIKit

class ShowLoading {
    
    static var container: UIView = UIView()
    static var loadingView: UIView = UIView()
    static var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    static func loadingStart(uiView: UIView) {
        
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromRGB.colorInit(0.6, rgbValue: 0xffffff)

        loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColorFromRGB.colorInit(0.6, rgbValue: 0x444444)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        actInd.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        actInd.style = .medium
        actInd.color = .white
        actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        loadingView.addSubview(actInd)
        container.addSubview(loadingView)
        
//        uiView.addSubview(container)
//        uiView.superview?.addSubview(container)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
//        guard let window = UIApplication.shared.windows.last else { return }

        window!.addSubview(container)

        actInd.startAnimating()
        
    }
    
    static func loadingStop() {
        
        DispatchQueue.main.async {
            
            actInd.stopAnimating()
            container.removeFromSuperview()
            
        }
        
        
    }
    
}

