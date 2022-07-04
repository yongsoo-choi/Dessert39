//
//  PutBasket.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/11.
//

import UIKit
import CoreLocation

class PutBasket: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var btn_goBasket: UIButton!
    @IBOutlet weak var btn_another: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
        backgroundView.alpha = 0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetY.constant = 0
            self.backgroundView.alpha = 0.7
            self.view.layoutIfNeeded()
        }
        
        setButton()
    }
    
    func setButton() {
        
        btn_another.layer.cornerRadius = btn_another.frame.height / 2
        btn_goBasket.layer.cornerRadius = btn_goBasket.frame.height / 2
        btn_goBasket.layer.borderWidth = 1
        btn_goBasket.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                
                if let tvc = self.presentingViewController as? UITabBarController {
                    if let nvc = tvc.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController {
                            self.dismiss(animated: false) {
                                
                                pvc.performSegue(withIdentifier: "basketSegue", sender: self)
                                
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func anotherHandler(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                
                if let tvc = self.presentingViewController as? UITabBarController {
                    if let nvc = tvc.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController {
                            self.dismiss(animated: false) {
                                pvc.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    @IBAction func closeHAndler(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
}

