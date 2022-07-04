//
//  BasketVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/11.
//

import UIKit

class BasketVC: UIViewController {
    
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var totalSum: UILabel!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var btn_order: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var warpView: UIView!{
        didSet{
            warpView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var titleView: UIView!{
        didSet{
            titleView.clipsToBounds = true
            titleView.layer.cornerRadius = 20
            titleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!{
        didSet{
            btn_cancel.layer.borderColor = UIColor.black.cgColor
            btn_cancel.layer.borderWidth = 1
        }
    }
    @IBOutlet var alertImage: UIImageView!
    @IBOutlet var alertTitle: UILabel!
    @IBOutlet var alertSub: UILabel!
    @IBOutlet var alertSubBold: UILabel!
    
    var networkUtil = NetworkUtil()
    var total: Int = 0
    var totalDisc: Int = 0
    var couponDisc: Int = 0
    var alertUtil = AlertUtil()
    
    var copyView = ActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.couponName = ""
        store.couponNo = ""
        store.couponPer = ""
        store.couponPrice = ""
        store.couponMax = ""
        store.couponMin = ""
        store.couponOwner = ""
        store.couponMenu = ""
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        store.isBasket = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "장바구니")
        
        store.isBasket = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset.right = 20
        
        btnView.layer.masksToBounds = false
        btnView.layer.shadowColor = UIColor.gray.cgColor
        btnView.layer.shadowOpacity = 0.1
        btnView.layer.shadowOffset = CGSize(width: 0, height: -2)
        btnView.layer.shadowRadius = 2
        
        btn_order.layer.cornerRadius = btn_order.frame.height / 2
        total = 0
        
        alertView.isHidden = true
        btn_ok.layer.cornerRadius = btn_ok.frame.height / 2
        btn_cancel.layer.cornerRadius = btn_ok.frame.height / 2
        btn_ok.addTarget(self, action: #selector(removeItem(sender:)), for: .touchUpInside)
        btn_cancel.addTarget(self, action: #selector(cancelAlert(sender:)), for: .touchUpInside)
        
        setFooter()
        
        var ts: Int = 0
        for arr in store.basketArr {
            
            ts = ts + Int(arr.count)!
            
        }
        
        totalSum.text = "총 \(ts)건"
        
        if store.couponName != "" && store.couponMenu != "" {
            
            var i = 0
            for arr in store.basketArr {
                
                if arr.name == store.couponMenu {
                    i += 1
                }
                
            }
            
            if i == 0 {
                
                store.couponName = ""
                store.couponNo = ""
                store.couponPer = ""
                store.couponPrice = ""
                store.couponMax = ""
                store.couponMin = ""
                store.couponOwner = ""
                store.couponMenu = ""
                
                self.alertUtil.oneItem(self, title: "쿠폰사용불가", message: "장바구니에 쿠폰 적용 메뉴가 없습니다.")
                
            }
        }
        
        if store.couponName != "" {
            
            var t: Int = 0
            var ts: Int = 0
            for arr in store.basketArr {
                
                let price = arr.result
                let intStr = price.replacingOccurrences(of: ",", with: "")
                let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
                t = t + strInt
                
                ts = ts + Int(arr.count)!
                
            }
            
            totalSum.text = "총 \(ts)건"
            
            if t >= Int(store.couponMin)! {
                
                if store.couponPrice != "0" {
                    
                    t = t - Int(store.couponPrice)!
                    totalDisc = Int(store.couponPrice)!
                    couponDisc = Int(store.couponPrice)!
                    
                    if totalDisc > Int(store.couponMax)! && Int(store.couponMax)! > 0 {
                        t = t - Int(store.couponMax)!
                        totalDisc = Int(store.couponMax)!
                        couponDisc = Int(store.couponMax)!
                        
                        let footer = tableView.tableFooterView as! BasketFooter
                        
                        if footer.couponTF.text != store.couponName {
                            self.alertUtil.oneItem(self, title: "쿠폰사용 최대금액", message: "해당 쿠폰의 최대 할인 금액은 \(store.couponMax)입니다.")
                        }
                        
                    }
                    
                } else {
                    t = Int((Double(t) - (Double(t) * Double(store.couponPer)! * 0.01)))
                    totalDisc = Int(Double(t) * Double(store.couponPer)! * 0.01)
                    couponDisc = Int(Double(t) * Double(store.couponPer)! * 0.01)
                }
                
                totalPrice.text = currncyStr(str: String(t))
                
                let footer = tableView.tableFooterView as! BasketFooter
                footer.couponTF.text = store.couponName
                
            } else {
                couponDisc = 0
                totalDisc = 0
                
                let footer = tableView.tableFooterView as! BasketFooter
                if footer.couponTF.text != store.couponName {
                    self.alertUtil.oneItem(self, title: "쿠폰사용불가", message: "결제금액이 최소 주문금액보다 적습니다.")
                }
                
                footer.couponTF.text = ""
                store.couponName = ""
                store.couponNo = ""
                store.couponPer = ""
                store.couponPrice = ""
                store.couponMax = ""
                store.couponMin = ""
                
            }
            
        }
        
        setTotal()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let footerView = self.tableView.tableFooterView else {
            return
        }
        
        let width = self.tableView.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            self.tableView.tableFooterView = footerView
        }
        
    }
    
    func setFooter() {
        
        let total = store.basketArr.count
        
        if total != 0 {
            
            let header = BasketHeader()
            header.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 111)
            header.label_store.text = store.storeName
            header.btn_copyAddress.addTarget(self, action: #selector(copyAddress(sender:)), for: .touchUpInside)
            header.btn_remove.addTarget(self, action: #selector(removeHandler(sender:)), for: .touchUpInside)
            
            let footer = BasketFooter()
            footer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 380)
            
            let gest: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewCoupon(_:)))
            footer.couponTF.addGestureRecognizer(gest)
            
            tableView.tableHeaderView = header
            tableView.tableFooterView = footer
            
            btnView.isHidden = false
            
        } else {
            btnView.isHidden = true
        }
        
    }
    
    @objc func viewCoupon(_ gesture: UITapGestureRecognizer) {
        
        let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "CouponPop") as! CouponPop
        pop.modalPresentationStyle = .overFullScreen
        self.present(pop, animated: false, completion: nil)
        
    }
    
    @objc func copyAddress(sender: UIButton) {
        
        UIPasteboard.general.string = store.storeAddress
        AlertUtil().oneItem(self, title: "주소가 복사 되었습니다.", message: store.storeAddress)
        
//        copyView.copy(self)
//        let activityViewController = UIActivityViewController(activityItems: [store.storeAddress], applicationActivities: nil)
//        present(activityViewController, animated: true, completion: nil)
        
    }
    
    @objc func removeHandler(sender: UIButton) {
        
        alertImage.image = UIImage(named: "alert_remove")
        alertTitle.text = "메뉴를 전체 삭제하시겠습니까?"
        alertSub.text = "삭제 시 되돌릴 수 없습니다. "
        alertSubBold.text = ""
        
        UIView.setAnimationsEnabled(false)
        btn_ok.setTitle("삭제", for: .normal)
        btn_ok.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        alertView.isHidden = false
        btn_ok.tag = 100
        
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
    
    func currncyStr(str: String) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0//소숫점은 없어요
        
        if (str.first == "0" && str == "") {
            return "\(str) 원"
        } else {
            
            if let formattedNumber = formatter.number(from: str),
               let formattedString = formatter.string(from: formattedNumber) {
                
                return "\(formattedString) 원"
            }
        }
        
        return "\(str) 원"
        
    }
    
    func setTotal() {
        
        for index in store.basketArr.indices {
         
            let obj = store.basketArr[index]
            let price = obj.result
            
            let intStr = price.replacingOccurrences(of: ",", with: "")
            let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
            total = total + strInt
            
            totalPrice.text = currncyStr(str: String(total))
            
        }
        
    }
    
    @objc func solveHandler(sender: UIButton) {
        
        var isCoupon: Bool = false
        
        let index = sender.tag
        let pm = sender.imageView!.tag
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! BasketCell
        
        let obj = store.basketArr[index]
        let price = obj.result
        let amount = obj.count
        
        let intStr = price.replacingOccurrences(of: ",", with: "")
        let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
        let onePrice: Int = strInt / Int(amount)!
        
        if pm == 1 {
            cell.labe_sum.text = String(Int(cell.labe_sum.text!)! + 1)
        }
        
        if pm == 0 && cell.labe_sum.text != "1" {
            cell.labe_sum.text = String(Int(cell.labe_sum.text!)! - 1)
        }

        
        if cell.labe_sum.text == "1" {
            cell.btn_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            cell.btn_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        cell.label_price.text = currncyStr(str: String(onePrice * Int(cell.labe_sum.text!)!))
        
        store.basketArr[index].count = cell.labe_sum.text!
        
        let priceR = cell.label_price.text!
        let intStrR = priceR.replacingOccurrences(of: ",", with: "")
        let strIntR: Int = Int(intStrR.replacingOccurrences(of: " 원", with: ""))!
        let totalPriceR = strIntR
        
        store.basketArr[index].result = String(totalPriceR)
        UserDefaults.standard.setValue(try? PropertyListEncoder().encode(store.basketArr), forKey: "basket")
        
        var t: Int = 0
        var ts: Int = 0
        for arr in store.basketArr {
            
            let price = arr.result
            let intStr = price.replacingOccurrences(of: ",", with: "")
            let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
            t = t + strInt
            
            if arr.name == store.couponMenu {
                isCoupon = true
            }
            
            ts = ts + Int(arr.count)!
            
        }
        
        totalSum.text = "총 \(ts)건"

        if store.couponName != "" {
            
            if isCoupon || store.couponMenu == "" {
                
                if t >= Int(store.couponMin)! {
                    
                    if store.couponPrice != "" {
                        
                        t = t - Int(store.couponPrice)!
                        totalDisc = Int(store.couponPrice)!
                        couponDisc = Int(store.couponPrice)!
                        
                        if totalDisc > Int(store.couponMax)! && Int(store.couponMax)! > 0 {
                            
                            t = t - Int(store.couponMax)!
                            totalDisc = Int(store.couponMax)!
                            couponDisc = Int(store.couponMax)!
                            self.alertUtil.oneItem(self, title: "쿠폰사용 최대금액", message: "해당 쿠폰의 최대 할인 금액은 \(store.couponMax)입니다.")
                            
                        }
                        
                    } else {
                        
                        if isCoupon {
                            
                            for arr in store.basketArr {
                                
                                if arr.name == store.couponMenu {
                                    
                                    let price = arr.result
                                    let intStr = price.replacingOccurrences(of: ",", with: "")
                                    let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
                                    
                                    let option = arr.option
                                    var intOpt: String = ""
                                    var strOpt: Int = 0
                                    if option != "" || option != "0" {
                                       
                                        if option.contains(",") {
                                            intOpt = option.replacingOccurrences(of: ",", with: "")
                                        } else {
                                            intOpt = option
                                        }
                                        
                                        if intOpt.contains(" ") {
                                            intOpt = intOpt.replacingOccurrences(of: " ", with: "")
                                        }
                                        
                                        if intOpt.contains("원") {
                                            strOpt = Int(intOpt.replacingOccurrences(of: "원", with: ""))!
                                        } else {
                                            strOpt = Int(intOpt)!
                                        }
                                        
                                        
                                    }
                                    
                                    var tt = strInt - strOpt
                                    
                                    tt = Int((Double(tt) - (Double(tt) * Double(store.couponPer)! * 0.01)))
                                    totalDisc = Int(Double(tt) * Double(store.couponPer)! * 0.01)
                                    couponDisc = Int(Double(tt) * Double(store.couponPer)! * 0.01)
                                    
                                    break
                                }
                                
                            }
                            
                        } else {
                            
                            t = Int((Double(t) - (Double(t) * Double(store.couponPer)! * 0.01)))
                            totalDisc = Int(Double(t) * Double(store.couponPer)! * 0.01)
                            couponDisc = Int(Double(t) * Double(store.couponPer)! * 0.01)
                            
                        }
                        
                    }
                    
                    totalPrice.text = currncyStr(str: String(t))
                    
                } else {
                    
                    couponDisc = 0
                    totalDisc = 0
                    
                    store.couponName = ""
                    store.couponNo = ""
                    store.couponPer = ""
                    store.couponPrice = ""
                    store.couponMax = ""
                    store.couponMin = ""
                    store.couponOwner = ""
                    store.couponMenu = ""
                    
                    let footer = tableView.tableFooterView as! BasketFooter
                    footer.couponTF.text = ""
                    
                    self.alertUtil.oneItem(self, title: "쿠폰사용불가", message: "결제금액이 최소 주문금액보다 적습니다.")
                    
                }
                
            } else {
                
                if !isCoupon && store.couponMenu != "" {
                    
                    couponDisc = 0
                    totalDisc = 0
                    
                    store.couponName = ""
                    store.couponNo = ""
                    store.couponPer = ""
                    store.couponPrice = ""
                    store.couponMax = ""
                    store.couponMin = ""
                    store.couponOwner = ""
                    store.couponMenu = ""
                    
                    let footer = tableView.tableFooterView as! BasketFooter
                    footer.couponTF.text = ""
                    
                    self.alertUtil.oneItem(self, title: "쿠폰사용불가", message: "장바구니에 쿠폰 적용 메뉴가 없습니다.")
                    
                }
                
            }
            
        }
            
        totalPrice.text = currncyStr(str: String(t))
        
    }
    
    @objc func removeCell(sender: UIButton) {
        
        alertImage.image = UIImage(named: "alert_remove")
        alertTitle.text = "해당 메뉴를 삭제하시겠습니까?"
        alertSub.text = "삭제 시 되돌릴 수 없습니다. "
        alertSubBold.text = ""
        
        UIView.setAnimationsEnabled(false)
        btn_ok.setTitle("삭제", for: .normal)
        btn_ok.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        alertView.isHidden = false
        btn_ok.tag = sender.tag
        
    }
    
    @objc func removeItem(sender: UIButton) {
        
        alertView.isHidden = true
        
        let index = sender.tag
        
        if index == 100 {
            // 전체 삭제
            store.basketArr.removeAll()
            UserDefaults.standard.removeObject(forKey: "basket")
            
            store.couponName = ""
            store.couponNo = ""
            store.couponPer = ""
            store.couponPrice = ""
            store.couponMax = ""
            store.couponMin = ""
            store.couponOwner = ""
            store.couponMenu = ""
            
            tableView.reloadData()
            
        } else if index == 200 {
            //주문하기
            orderApi()
            
        } else {
            //cell 삭제
            store.basketArr.remove(at: index)
            UserDefaults.standard.setValue(try? PropertyListEncoder().encode(store.basketArr), forKey: "basket")
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            tableView.endUpdates()
            
            var t: Int = 0
            var ts: Int = 0
            for arr in store.basketArr {
                
                let price = arr.result
                let intStr = price.replacingOccurrences(of: ",", with: "")
                let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
                t = t + strInt
                
                ts = ts + Int(arr.count)!
                
            }
            totalPrice.text = currncyStr(str: String(t))
            totalSum.text = "총 \(ts)건"
            
        }
        
    }
    
    @objc func cancelAlert(sender: UIButton) {
        
        alertView.isHidden = true
        
    }

    @IBAction func orderHandler(_ sender: Any) {
        
        if store.basketArr.count != 0 {
        
            alertImage.image = UIImage(named: "alert_order")
            alertTitle.text = "주문 하시겠습니까?"
            alertSub.text = "확인 시 매장에 주문서가 접수됩니다."
            alertSubBold.text = "앱 내 주문 현황 알림이 꺼져있을 경우\n결제하기 및 중요한 알림을 놓칠 수 있습니다."
            
            UIView.setAnimationsEnabled(false)
            btn_ok.setTitle("확인", for: .normal)
            btn_ok.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            alertView.isHidden = false
            btn_ok.tag = 200
            
        } else {
            AlertUtil().oneItem(self, title: "주문할 상품이 없습니다.", message: "")
        }
        
    }
    
    func totalDiscount() -> Int {
        
        var t: Int = 0
        for arr in store.basketArr {
            
            let price = arr.discount
            let count = arr.count
            
            var intStr: String = ""
            var strInt: Int = 0
            
            if price != "" {
                
                if price.contains(",") {
                    intStr = price.replacingOccurrences(of: ",", with: "")
                } else {
                    intStr = price
                }
                
                if intStr.contains(" ") {
                    intStr = intStr.replacingOccurrences(of: " ", with: "")
                }
                
                if intStr.contains("원") {
                    strInt = Int(intStr.replacingOccurrences(of: "원", with: ""))!
                } else {
                    strInt = Int(intStr)!
                }
                
                t = t + (strInt * Int(count)!)
            }
            
            
        }
        
//        t = t + totalDisc
        
        return t
        
    }
    
    func originPrice() -> Int {
        
        var t: Int = 0
        for arr in store.basketArr {
            
            let price = arr.price
            let option = arr.option
            let count = arr.count
            
            var intStr: String = ""
            var strInt: Int = 0
            
            if price != "" {
                
                if price.contains(",") {
                    intStr = price.replacingOccurrences(of: ",", with: "")
                } else {
                    intStr = price
                }
                
                if intStr.contains(" ") {
                    intStr = intStr.replacingOccurrences(of: " ", with: "")
                }
                
                if intStr.contains("원") {
                    strInt = Int(intStr.replacingOccurrences(of: "원", with: ""))!
                } else {
                    strInt = Int(intStr)!
                }
                
                t = t + (strInt * Int(count)!)
            }
            
            if option != "" || option != "0" {
               
                if option.contains(",") {
                    intStr = option.replacingOccurrences(of: ",", with: "")
                } else {
                    intStr = option
                }
                
                if intStr.contains(" ") {
                    intStr = intStr.replacingOccurrences(of: " ", with: "")
                }
                
                if intStr.contains("원") {
                    strInt = Int(intStr.replacingOccurrences(of: "원", with: ""))!
                } else {
                    strInt = Int(intStr)!
                }
                
                t = t + (strInt * Int(count)!)
                
            }
            
        }
        
        return t
        
    }
    
    func orderApi() {
        
        let cmd = "set_order"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let shopNo = store.storeNo!
        let totalCnt = store.basketArr.count
        
        let price = totalPrice.text!
        let intStr = price.replacingOccurrences(of: ",", with: "")
        let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
        let totalPrice = strInt
        
        let footer = tableView.tableFooterView as! BasketFooter
        let request = footer.tf_request.text!
        var couponNo = store.couponNo
        if couponNo == "" {
            couponNo = "0"
        }
        var couponOwner = store.couponOwner
        if couponOwner == "" {
            couponOwner = "0"
        }
        let couponDC = couponDisc
        let totalDC = totalDiscount() + couponDisc
        let totalTumbler = totalDiscount()
        let originPrice = originPrice()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try? encoder.encode(store.basketArr)
        if let jsonData = jsonData, let goods = String(data: jsonData, encoding: .utf8) {
            
            let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><SHOPNO>\(shopNo)</SHOPNO><GOODS>\(goods)</GOODS><TOTALCNT>\(totalCnt)</TOTALCNT><TOTALPRICE>\(totalPrice)</TOTALPRICE><REQUEST>\(request)</REQUEST><COUPON>\(couponNo)</COUPON><COUPONOWNER>\(couponOwner)</COUPONOWNER><COUPONDISCOUNT>\(couponDC)</COUPONDISCOUNT><TOTALDISCOUNT>\(totalDC)</TOTALDISCOUNT><TOTALTUMBLER>\(totalTumbler)</TOTALTUMBLER><ORIGINPRICE>\(originPrice)</ORIGINPRICE></DATA>"
            let encryped: String = AES256CBC.encryptString(strCode)!
            let urlString: String = "\(store.configUrl)?code=\(encryped)"
            let str = urlString.replacingOccurrences(of: "+", with: "%2B")
            print(strCode)
            networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in

                if let hasData = data {
                    do {

                        let dataStr = String(decoding: hasData, as: UTF8.self)
                        let decryped = AES256CBC.decryptString(dataStr)!
                        let decrypedData = decryped.data(using: .utf8)!

                        let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                        DispatchQueue.main.async {
                            
                            if jsonResult["errCode"] as? String == "0000" {

                                store.orderNo = jsonResult["order_no"] as? String
                                store.basketArr.removeAll()
                                store.couponName = ""
                                store.couponNo = ""
                                store.couponPer = ""
                                store.couponPrice = ""
                                store.couponMax = ""
                                store.couponMin = ""
                                store.couponMenu = ""
                                
                                UserDefaults.standard.removeObject(forKey: "basket")
                                self.performSegue(withIdentifier: "finishSegue", sender: self)

                            }

                        }

                    } catch {
                        print("JSONDecoder Error : \(error)")
                    }

                }

            }

        }
        
    }
    
}

extension BasketVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = store.basketArr.count
        
        if total == 0 {
            tableView.setEmptyView(title: "장바구니가 비어있습니다.", message: "원하시는 메뉴를 장바구니에 담아 \n한번에 확인 후 주문하세요 :)", imageStr: "empty_basket", imageW: 118, imageH: 105)
        } else {
            tableView.restore()
            tableView.separatorStyle = .singleLine
            
//            totalSum.text = "총 \(total)건"
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasketCell", for: indexPath) as! BasketCell
        let obj = store.basketArr[indexPath.row]
        let goodsName = obj.name
        let temp = obj.hot_ice
        let size = obj.size
        let cup = obj.cup
        let optionStr = obj.optionStr
        let price = obj.result
        let amount = obj.count
        let goodsPath = obj.goodsPath
        let tumblerSale = obj.discount
        let priceDefault = obj.price
        let priceOption = obj.option
        
        cell.label_name.text = goodsName
        cell.label_default.text = "\(temp) | \(size) | \(cup)"
        
        if cell.label_default.text == " |  | " {
            cell.label_default.text = ""
        }
        
        cell.label_option.text = optionStr
        cell.label_price.text = currncyStr(str: price)
        cell.labe_sum.text = amount
        cell.price_default.text = currncyStr(str: priceDefault)
        
        if priceOption != "0" {
            cell.price_option.text = "+\(priceOption)"
        } else {
            cell.price_option.text = ""
        }
        
        self.loadImage(urlString: goodsPath) { image in

            DispatchQueue.main.async {
                cell.menuImage.image = image
            }

        }
        
        if tumblerSale != "" {
            cell.label_tumbler.text = "텀블러할인"
            cell.price_tumbler.text = "-\(tumblerSale)"
        } else {
            cell.label_tumbler.text = ""
            cell.price_tumbler.text = ""
        }
        
//        let intStr = price.replacingOccurrences(of: ",", with: "")
//        let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
//        total = total + strInt
//
//        totalPrice.text = currncyStr(str: String(total))
        
        if cell.labe_sum.text == "1" {
            cell.btn_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            cell.btn_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        cell.btn_plus.addTarget(self, action: #selector(solveHandler(sender:)), for: .touchUpInside)
        cell.btn_plus.tag = indexPath.row
        cell.btn_plus.imageView!.tag = 1
        
        cell.btn_minus.addTarget(self, action: #selector(solveHandler(sender:)), for: .touchUpInside)
        cell.btn_minus.tag = indexPath.row
        cell.btn_minus.imageView!.tag = 0
        
        cell.btn_close.addTarget(self, action: #selector(removeCell(sender:)), for: .touchUpInside)
        cell.btn_close.tag = indexPath.row
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}

//extension BasketVC: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return countryList.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return countryList[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedCountry = countryList[row]
//        textField.text = selectedCountry
//    }
//
//}

