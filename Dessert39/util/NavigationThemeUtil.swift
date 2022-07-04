//
//  NavigationThemeUtil.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/20.
//

import UIKit

class NavigationThemeUtil {
    
    static func defaultTheme (_ navigationController:UINavigationController?, selfView:UIViewController?, title: String?){
        
        let navigationBar = navigationController?.navigationBar
        let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.shadowColor = .white
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-SemiBold", size: 24)!]
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        navigationBar?.standardAppearance = appearance
        
        selfView?.navigationItem.title = title
        selfView?.navigationItem.hidesBackButton = false
        selfView?.navigationItem.backButtonTitle = ""
        selfView?.navigationItem.backButtonDisplayMode = .minimal
        
    }
    
    static func clearBackTheme (_ navigationController:UINavigationController?, selfView:UIViewController?, title: String?){
        
        let navigationBar = navigationController?.navigationBar
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.shadowColor = .white
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-SemiBold", size: 24)!]

        navigationBar?.standardAppearance = appearance
        
        selfView?.navigationItem.title = title
        selfView?.navigationItem.hidesBackButton = true
        
    }
    
    static func defaultShadowTheme (_ navigationController:UINavigationController?, selfView:UIViewController?, title: String?){
        
        let navigationBar = navigationController?.navigationBar
        let backImage = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-SemiBold", size: 24)!]
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        let imageView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
        imageView.backgroundColor = UIColorFromRGB.colorInit(0.1, rgbValue: 0xB5B5B5)
        imageView.layer.masksToBounds = false
        imageView.layer.shadowColor = UIColor.gray.cgColor
        imageView.layer.shadowOpacity = 0.8
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 2
        
        let render = UIGraphicsImageRenderer(bounds: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 11))
        
        appearance.shadowImage = render.image { context in
            imageView.layer.render(in: context.cgContext)
        }

        navigationBar?.standardAppearance = appearance
        
        selfView?.navigationItem.title = title
        selfView?.navigationItem.hidesBackButton = false
        selfView?.navigationItem.backButtonTitle = ""
        selfView?.navigationItem.backButtonDisplayMode = .minimal
        
    }
    
}
