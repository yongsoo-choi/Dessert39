//
//  NearStore.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/05.
//

import UIKit
import CoreLocation

class NearStore: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    
    @IBOutlet var firstView: UIView!
    @IBOutlet var firstName: UILabel!
    @IBOutlet var firstAddress: UILabel!
    @IBOutlet var firstTime: UILabel!
    @IBOutlet var firstDist: UIButton!
    
    @IBOutlet var secView: UIView!
    @IBOutlet var secName: UILabel!
    @IBOutlet var secAddress: UILabel!
    @IBOutlet var secTime: UILabel!
    @IBOutlet var secDist: UIButton!
    
    @IBOutlet weak var emptyImage: UIImageView!
    
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_another: UIButton!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var networkUtil = NetworkUtil()
    var shopListModel: NSArray?
    var shopNoArr: [String] = ["", ""]
    var billpayIdArr: [String] = ["", ""]
    var billpayPWArr: [String] = ["", ""]
    
    var idString: String = ""
    var locationManger = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
        backgroundView.alpha = 0
        
        emptyImage.isHidden = true
        firstView.isHidden = true
        secView.isHidden = true
        
        indicator.isHidden = false
        indicator.startAnimating()
        
        if store.nick != "" {
            
            let nick: String = store.nick!
            label_name.text = "\(nick)님과 가장 가까운 매장"
            
        } else if store.name != "" {
            
            let name: String = store.name!
            label_name.text = "\(name)님과 가장 가까운 매장"
            
        } else {
            
            let id: String = store.nick!
            label_name.text = "\(id)님과 가장 가까운 매장"
            
        }
        
        getNearStore()
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
        btn_cancel.layer.cornerRadius = btn_cancel.frame.height / 2
        btn_cancel.layer.borderWidth = 1
        btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        
    }
    
    func getNearStore() {
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        if #available(iOS 14.0, *) {
            // location accuracy
            let accuracyState = CLLocationManager().accuracyAuthorization
            switch accuracyState {
                case .fullAccuracy:
                    print("full")
                case .reducedAccuracy:
                    print("reduce")
                @unknown default:
                    print("Unknown")
            }
        }
        
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                break
            case .restricted, .notDetermined:
                locationManger.requestWhenInUseAuthorization()
            case .denied:
                showAuthoriaztionDeninedAlert()
            @unknown default:
                return
        }
        
        
        
        locationManger.startUpdatingLocation()
        let coor = locationManger.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude
        
        getStoreApi()
        
    }
    
    func getStoreApi() {
        
        let cmd = "get_shop_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let lat = latitude!
        let long = longitude!
        let shop = ""
        let part = "s"
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><LATITUDE>\(lat)</LATITUDE><LONGITUDE>\(long)</LONGITUDE><SHOPNAME>\(shop)</SHOPNAME><PART>\(part)</PART></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in

            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    self.shopListModel = jsonResult["shopList"] as? NSArray
                    
                    DispatchQueue.main.async {

                        if jsonResult["errCode"] as? String == "0000" {

                            self.setting()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setting() {
        
        self.indicator.stopAnimating()
        self.indicator.isHidden = true
        
        if self.shopListModel?.count == 0 {
            emptyImage.isHidden = false
        } else {
            
            firstView.isHidden = false
            
            let obj = self.shopListModel![0] as! NSDictionary
            let shopName = obj["name"] as! String
            let shopNo = obj["idx"] as! String
            let shopAddress = obj["addr1"] as! String
            let shopTime = obj["time"] as! String
            let shopDist = obj["distance"] as! String
            let billpayID = obj["billPayID"] as! String
            let billpayPW = obj["billPayPWD"] as! String
            
            firstName.text = shopName
            firstAddress.text = shopAddress
            firstTime.text = shopTime
            
            UIView.setAnimationsEnabled(false)
            firstDist.setTitle(distanceHandler(dist: shopDist), for: .normal)
            firstDist.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)

            
            shopNoArr[0] = shopNo
            billpayIdArr[0] = billpayID
            billpayPWArr[0] = billpayPW
//            print("billpayID = \(billpayID)")
            let firGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(firShop(_:)))
            firstView.addGestureRecognizer(firGesture)
            
            if self.shopListModel!.count > 1 {
                
                secView.isHidden = false
                
                let obj = self.shopListModel![1] as! NSDictionary
                let shopName1 = obj["name"] as! String
                let shopNo1 = obj["idx"] as! String
                let shopAddress1 = obj["addr1"] as! String
                let shopTime1 = obj["time"] as! String
                let shopDist1 = obj["distance"] as! String
                let billpayID = obj["billPayID"] as! String
                let billpayPW = obj["billPayPWD"] as! String
                
                secName.text = shopName1
                secAddress.text = shopAddress1
                secTime.text = shopTime1
                
                UIView.setAnimationsEnabled(false)
                secDist.setTitle(distanceHandler(dist: shopDist1), for: .normal)
                secDist.layoutIfNeeded()
                UIView.setAnimationsEnabled(true)
                
                shopNoArr[1] = shopNo1
                billpayIdArr[1] = billpayID
                billpayPWArr[1] = billpayPW
                
                let secGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(secShop(_:)))
                secView.addGestureRecognizer(secGesture)
                
            }
            
        }
        
    }
    
    func distanceHandler(dist: String) -> String {
        
        var strDist = ""
        
        let intDist = Double(dist)
        let dist = round(intDist! * 10) / 10
        
        if dist < 1 {
            strDist = "\(Int(dist * 1000))m"
        } else if dist == 0.0 {
            strDist = "100m 이내"
        } else {
            strDist = "\(dist)km"
        }
        
        return strDist
        
    }
    
    @objc func firShop(_ gesture: UITapGestureRecognizer) {
        
        store.storeName = firstName.text!
        store.storeAddress = firstAddress.text!
        store.storeNo = shopNoArr[0]
        store.billpayID = billpayPWArr[0]
        store.billpayPW = billpayPWArr[0]
        
        selectedShop()
    }
    
    @objc func secShop(_ gesture: UITapGestureRecognizer) {
        
        store.storeName = secName.text!
        store.storeAddress = secAddress.text!
        store.storeNo = shopNoArr[1]
        store.billpayID = billpayPWArr[1]
        store.billpayPW = billpayPWArr[1]
        
        selectedShop()
    }
    
    func selectedShop() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                
                if let tvc = self.presentingViewController as? UITabBarController {
                    if let nvc = tvc.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController as? OrderVC {
                            self.dismiss(animated: false) {
                                
                                pvc.viewWillAppear(true)
                                
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    func showAuthoriaztionDeninedAlert() {
        
        let alert = UIAlertController(title: "접근권한을 설정해 주세요.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: { action in
            
            self.dimmedViewTapped()
            
        }))
        alert.addAction(UIAlertAction(title: "설정으로 가기", style: .default, handler: { action in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        
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
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                
                if let tvc = self.presentingViewController as? UITabBarController {
                    if let nvc = tvc.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController as? OrderVC {
                            self.dismiss(animated: false) {
                                
                                pvc.performSegue(withIdentifier: "storeSelect", sender: self)
                                
                            }
                        }
                    }
                }
                
            }
        }
        
    }
    
    func dimmedViewTapped() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
    }

}
