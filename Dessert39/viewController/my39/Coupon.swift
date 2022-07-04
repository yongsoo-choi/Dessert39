//
//  Coupon.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/23.
//

import UIKit

class Coupon: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var couponModel: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        initRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "쿠폰")
        navigationController?.isNavigationBarHidden = false
        
        getListApi()
        
    }
    
    func initRefresh() {
        
        refresh.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        self.tableView.refreshControl = refresh
        
    }
     
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        print("refreshTable")
        getListApi()
        
    }
    
    @objc func goOrder(sender: UIButton) {
        
        guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
        tabBar.orderButton.setBackgroundImage(UIImage(named: "tb_basket"), for: .normal)
        self.tabBarController?.selectedIndex = 3
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
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
                    
                    DispatchQueue.main.async {
                        
                        if !self.refresh.isRefreshing {
                            ShowLoading.loadingStop()
                        }

                        if jsonResult["errCode"] as? String == "0000" {

                            self.tableView.reloadData()
                            self.refresh.endRefreshing()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func currncyStr(str: String) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0//소숫점은 없어요
        
        if (str.first == "0" && str == "") {
            return "\(str)원"
        } else {
            
            if let formattedNumber = formatter.number(from: str),
               let formattedString = formatter.string(from: formattedNumber) {
                
                return "\(formattedString)원"
            }
        }
        
        return "\(str)원"
        
    }

}

extension Coupon: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let total = self.couponModel?.count ?? 0
        
        if total == 0 {
            tableView.setEmptyView(title: "", message: "사용가능한 쿠폰이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = self.couponModel![indexPath.row] as! NSDictionary
        let isUse = obj["isUse"] as! String
//        let name = obj["name"] as! String
//        let useDate = obj["useDate"] as! String
        let minBuyPrice = obj["minBuyPrice"] as! String
        let couponStart = obj["couponStart"] as! String
        let couponEnd = obj["couponEnd"] as! String
//        let owner = obj["owner"] as! String
        let ownerName = obj["ownerName"] as! String
        
        var menuName = obj["menuName"] as! String
        let discountPart = obj["discountPart"] as! String
        let discountPercent = obj["discountPercent"] as! String
        let discountPrice = obj["discountPrice"] as! String
        
        if menuName == "" {
            menuName = "전메뉴"
        }
        
        if isUse == "0" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCell", for: indexPath) as! CouponCell
            cell.btn_use.addTarget(self, action: #selector(goOrder(sender:)), for: .touchUpInside)
            cell.label_date.text = "\(couponStart.prefix(10)) ~ \(couponEnd.prefix(10))"
            cell.label_minPrice.text = currncyStr(str: minBuyPrice)
            
            if discountPart == "0" {
                cell.label_coupon.text = "\(menuName) \(discountPercent)% 할인 쿠폰"
            } else {
                cell.label_coupon.text = "\(menuName) \(discountPrice)원 할인 쿠폰"
            }
            
//            if owner != "0"{
//                cell.label_store.text = ownerName
//            } else {
//                cell.label_store.text = "전매장 사용"
//            }
            cell.label_store.text = ownerName
            
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CouponCellDisable", for: indexPath) as! CouponCellDisable
            cell.label_date.text = "\(couponStart.prefix(10)) ~ \(couponEnd.prefix(10))"
            cell.label_minPrice.text = currncyStr(str: minBuyPrice)
            
            if discountPart == "0" {
                cell.label_coupon.text = "\(menuName) \(discountPercent)% 할인 쿠폰"
            }
            
            if discountPart == "1" {
                cell.label_coupon.text = "\(menuName) \(discountPrice)원 할인 쿠폰"
            }
            
            if discountPart == "2" {
                cell.label_coupon.text = "\(menuName) 사이즈업 쿠폰"
            }
            
//            if owner != "0"{
//                cell.label_store.text = ownerName
//            } else {
//                cell.label_store.text = "전매장 사용"
//            }
            cell.label_store.text = ownerName
            cell.selectionStyle = .none
            return cell
            
        }
        
        
    }
    
}
