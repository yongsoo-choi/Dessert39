//
//  DetailStore.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/15.
//

import UIKit

class DetailStore: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var label_address: UILabel!
    @IBOutlet weak var label_time: UILabel!
    
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_another: UIButton!
    
    @IBOutlet weak var btn_dist: UIButton!
    
    var networkUtil = NetworkUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
        backgroundView.alpha = 0
        
        imageView.layer.cornerRadius = 10
        infoView.layer.cornerRadius = 10
        
        setting()
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
    
    func setting() {
        
        label_store.text = store.dummyName
        label_address.text = store.dummyAddress
        label_time.text = store.dummyTime
        
        UIView.setAnimationsEnabled(false)
        btn_dist.setTitle(store.dummyDist, for: .normal)
        btn_dist.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        if store.dummyImg!.count != 0 {
            
            if let images = store.dummyImg![0] as? NSDictionary {
                
                let imgPath = images["imgPath"] as! String
                
                self.loadImage(urlString: imgPath) { image in

                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }

                }
                
            }
            
        } else {
            self.imageView.image = UIImage(named: "splash_logo")
        }
        
    }
    
    func setButton() {
        
        btn_another.layer.cornerRadius = btn_another.frame.height / 2
        btn_cancel.layer.cornerRadius = btn_cancel.frame.height / 2
        btn_cancel.layer.borderWidth = 1
        btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        
        btn_dist.layer.cornerRadius = 3
        
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        networkUtil.request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        
        store.dummyNo = nil
        store.dummyName = nil
        store.dummyAddress = nil
        store.dummyTime = nil
        store.dummyDist = nil
        store.dummyImg = nil
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
    }
    
    @IBAction func anotherHandler(_ sender: Any) {
        
        if store.storeName != "" {
         
            if let saveStore = UserDefaults.standard.string(forKey: "storeName") {
                
                if store.dummyName != saveStore {
                    
                    let alert = UIAlertController(title: "장바구니에는 같은 매장의 메뉴만 담을 수 있습니다.", message: "매장을 바꾸면 이전에 담은 메뉴가 삭제 됩니다. ", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "매장 선택", style: .default, handler: { action in
                        
                        UserDefaults.standard.removeObject(forKey: "basket")
                        UserDefaults.standard.removeObject(forKey: "storeName")
                        store.basketArr = []
                        
                        self.dismissHandler()
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    
//                    if let data = UserDefaults.standard.value(forKey: "basket") as? Data {
//                        store.basketArr = try! PropertyListDecoder().decode(Array<BasketModel>.self,from: data)
//                        store.storeName = UserDefaults.standard.string(forKey: "storeName")!
//                    }
                    
                } else {
                    dismissHandler()
                }
                
            } else {
                dismissHandler()
            }
            
        } else {
            dismissHandler()
        }
        
    }
    
    func dismissHandler() {
        
        store.storeName = store.dummyName!
        store.storeNo = store.dummyNo!
        store.storeAddress = store.dummyAddress!
        store.billpayID = store.dummybillpayId!
        store.billpayPW = store.dummybillpayPW!
        
        store.dummyNo = nil
        store.dummyName = nil
        store.dummyAddress = nil
        store.dummyTime = nil
        store.dummyDist = nil
        store.dummyImg = nil
        store.dummybillpayId = nil
        store.dummybillpayPW = nil
        
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

}
