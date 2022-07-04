//
//  File.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    var orderButton: UIButton!
    var alertUtil = AlertUtil()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.selectedIndex = 0
        
        guard let tabBar = self.tabBar as? TabBarVC else { return }
                
        tabBar.didTapButton = { [unowned self] in
            
            if self.selectedIndex != 3 {
                tabBar.orderButton.setBackgroundImage(UIImage(named: "tb_basket"), for: .normal)
            } else {
                
//                if store.basketArr.count > 0 {
                    // 장바구니 /////////////////////////////////////////////////////////////////////////////////
                if !store.isBasket {
                    
                    if let nvc = self.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController {
                            self.dismiss(animated: false) {
                                
                                pvc.performSegue(withIdentifier: "basketSegue", sender: self)
//                                let detail = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(identifier: "BasketVC")
//                                pvc.navigationController?.pushViewController(detail, animated: true)
                                
                            }
                        }
                    }
                    
                }
                    
//                } else {
//                    self.alertUtil.oneItem(self, title: "장바구니가 비어었습니다.", message: "")
//                }
                
            }
            
            self.selectedIndex = 3
            
            
//            let createAdNavController = self.storyboard?.instantiateViewController(withIdentifier: "OrderVC") as! UINavigationController
//            createAdNavController.modalPresentationCapturesStatusBarAppearance = true
//            self.present(createAdNavController, animated: true, completion: nil)
        }
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard let tabBar = self.tabBar as? TabBarVC else { return }
        tabBar.orderButton.setBackgroundImage(UIImage(named: "tb_order"), for: .normal)
        tabBar.badgeView.isHidden = true
        store.isStore = false
        
    }
        
}



