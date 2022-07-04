//
//  CouponPop.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/14.
//

import UIKit

class CouponPop: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet var tableView: UITableView!
    
    var alertUtil = AlertUtil()
    var networkUtil = NetworkUtil()
    var couponModel: NSArray?
    var isUser: Bool = false
    var storeno: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
        backgroundView.alpha = 0
        
        if isUser {
            getCouponApi()
        } else {
            getUserCouponApi()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        -((tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.frame.height)!)
//        UIView.animate(withDuration: 0.3) {
//            self.bottomSheetY.constant = 0
//            self.backgroundView.alpha = 0.7
//            self.view.layoutIfNeeded()
//        }
        
    }
    
    func bottomSheetLayout() {
        
        let total = self.couponModel?.count ?? 0
        var hei: CGFloat?
        
        if total == 1 {
            hei = (tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.frame.height)! * 2
        } else if total == 2 {
            hei = (tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.frame.height)!
        } else {
            hei = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetY.constant = 0 - hei!
            self.backgroundView.alpha = 0.7
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func closeHAndler(_ sender: Any) {
        
        close()
        
    }
    
    func close() {
        
        isUser = false
        storeno = ""
        
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
                                pvc.viewWillAppear(false)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func getUserCouponApi() {
        
        let cmd = "get_user_coupons"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN></DATA>"
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
                    self.couponModel = jsonResult["couponList"] as? NSArray
//                    print(self.couponModel)
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.tableView.reloadData()
                            self.bottomSheetLayout()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func getCouponApi() {
        
        let cmd = "get_coupon_list"
        let no = store.storeNo ?? ""
        
//        if storeno == "100000000" {
//            no = store.storeNo ?? ""
//        } else {
//            no = storeno
//        }
//        print(no)
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><NO>\(no)</NO></DATA>"
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
                    self.couponModel = jsonResult["couponList"] as? NSArray
//                    print(self.couponModel)
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.tableView.reloadData()
                            self.bottomSheetLayout()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func downCoupon(_ no: String, start: String, end: String) {
        
        let cmd = "set_coupon_down"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NO>\(no)</NO><START>\(start)</START><END>\(end)</END></DATA>"
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
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.close()

                        } else {
                            
                            let msg = jsonResult["errMsg"] as? String
                            AlertUtil().oneItem(self, title: "Error", message: msg!)
                            
                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func errorHandler() {
        
        AlertUtil().oneItem(self, title: "이미 다운받은 쿠폰입니다.", message: "")
        
    }

}

extension CouponPop: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.couponModel?.count ?? 0
        
        if total == 0 {
            tableView.setEmptyView(title: "", message: "쿠폰이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isUser {
            
            let obj = self.couponModel![indexPath.row] as! NSDictionary
            let no = obj["no"] as! String
            let start = obj["couponStart"] as! String
            let end = obj["couponEnd"] as! String
            
            downCoupon(no, start: start, end: end)
            
        } else {
        
            let obj = self.couponModel![indexPath.row] as! NSDictionary
            let name = obj["name"] as! String
            let no = obj["no"] as! String
            let discountPercent = obj["discountPercent"] as! String
            let discountPrice = obj["discountPrice"] as! String
            let maxDiscountPrice = obj["maxDiscountPrice"] as! String
            let minBuyPrice = obj["minBuyPrice"] as! String
            let menuName = obj["menuName"] as! String
            let owner = obj["owner"] as! String
            
            if owner != "0" && owner != store.storeNo {
                
                self.alertUtil.oneItem(self, title: "쿠폰 사용 불가", message: "선택하신 매장에서는 사용하실 수 없습니다.")
                return
                
            }
            
            store.couponName = ""
            store.couponNo = ""
            store.couponPer = ""
            store.couponPrice = ""
            store.couponMax = ""
            store.couponMin = ""
            store.couponOwner = ""
            store.couponMenu = ""
            
            store.couponName = name
            store.couponNo = no
            store.couponPer = discountPercent
            store.couponPrice = discountPrice
            store.couponMax = maxDiscountPrice
            store.couponMin = minBuyPrice
            store.couponOwner = owner
            store.couponMenu = menuName
            
            close()
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponDownCell", for: indexPath) as! CouponDownCell
        let obj = self.couponModel![indexPath.row] as! NSDictionary
        var menuName = obj["menuName"] as! String
        let minBuyPrice = obj["minBuyPrice"] as! String
        let couponStart = obj["couponStart"] as! String
        let couponEnd = obj["couponEnd"] as! String
        let discountPart = obj["discountPart"] as! String
        let discountPercent = obj["discountPercent"] as! String
        let discountPrice = obj["discountPrice"] as! String
        
        if menuName == "" {
            menuName = "전메뉴"
        }
        
        cell.label_name.text = menuName
        
        if minBuyPrice != "" {
            cell.label_minPrice.text = minBuyPrice
        }
        
        if discountPart == "0" {
            cell.label_sale.text = "\(discountPercent)% 할인 쿠폰"
        }
        
        if discountPart == "1" {
            cell.label_sale.text = "\(discountPrice)원 할인 쿠폰"
        }
        
        if discountPart == "2" {
            cell.label_sale.text = "사이즈업 쿠폰"
        }
        
        let startIndex = couponStart.index(couponStart.startIndex, offsetBy: 9)
        let startRange = ...startIndex
        let endIndex = couponEnd.index(couponEnd.startIndex, offsetBy: 9)
        let endRange = ...endIndex
        
        cell.label_date.text = "\(couponStart[startRange]) ~ \(couponEnd[endRange])"
        
        if isUser {
            cell.btn_down.isHidden = false
        } else {
            cell.btn_down.isHidden = true
        }
        
        if obj["isUse"] as? String != nil {
            
            let isUse = obj["isUse"] as! String
            
            if isUse == "0" {
                cell.isUserInteractionEnabled = true
                cell.enabledView.alpha = 0
            } else {
                cell.isUserInteractionEnabled = false
                cell.enabledView.alpha = 0.7
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
//cell!.isUserInteractionEnabled = false
