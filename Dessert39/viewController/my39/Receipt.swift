//
//  Receipt.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/03.
//

import UIKit

class Receipt: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerView: UIView!
    
    @IBOutlet var label_company: UILabel!
    @IBOutlet var label_companyNum: UILabel!
    @IBOutlet var label_address: UILabel!
    @IBOutlet var lable_phone: UILabel!
    @IBOutlet var label_date: UILabel!
    @IBOutlet var lable_ceo: UILabel!
    
    @IBOutlet var label_menu: UILabel!
    @IBOutlet var label_menuNum: UILabel!
    @IBOutlet var label_menuPrice: UILabel!
    
    @IBOutlet var label_total: UILabel!
    
    @IBOutlet var label_supply: UILabel!
    @IBOutlet var label_tex: UILabel!
    
    @IBOutlet var label_supplyTotal: UILabel!
    @IBOutlet var label_cardPrice: UILabel!
    
    @IBOutlet var label_cardMonth: UILabel!
    @IBOutlet var label_price: UILabel!
    @IBOutlet var label_texTotal: UILabel!
    @IBOutlet var label_sum: UILabel!
    @IBOutlet var label_card: UILabel!
    @IBOutlet var lable_lastDate: UILabel!
    @IBOutlet var label_receiveNum: UILabel!
    @IBOutlet var lable_contents: UILabel!
    
    var alertUtil = AlertUtil()
    var orderNo: String?
    
    var networkUtil = NetworkUtil()
    var jsonResult: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        orderNo = store.receiptNo
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "전자영수증")
        self.navigationItem.hidesBackButton = true
        
        let capture = UIBarButtonItem(image: UIImage(systemName: "icloud.and.arrow.down"), style: .done, target: self, action: #selector(captureHandler(sender:)))
        capture.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .done, target: self, action: #selector(close(sender:)))
        close.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        self.navigationItem.rightBarButtonItems = [close, capture]
        
        innerView.backgroundColor = UIColor(patternImage: UIImage(named: "receiptBackground")!)
        
        getApi()
        
    }
    
    @objc func close(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func captureHandler(sender: UIBarButtonItem) {
        
        UIImageWriteToSavedPhotosAlbum(self.view.snapshot(scrollView: scrollView)!, self, #selector(imageWasSaved), nil)
        
    }
    
    @objc func imageWasSaved(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer) {
        
        if error != nil {
//            Toast.showToast(message: "정상적으로 저장하지 못했습니다.", selfView: self)
            alertHandler("정상적으로 저장하지 못했습니다.")
            return
        }
//        Toast.showToast(message: "전자영수증이 저장 되었습니다.", selfView: self)
        alertHandler("전자영수증이 저장 되었습니다.")

    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "전자영수증", message: str)
        
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
    
    func setPage() {
        
        let shopName = jsonResult!["shopName"] as! String
        let shopAddr = jsonResult!["shopAddr"] as! String
        let shopTel = jsonResult!["shopTel"] as! String
        let orderDate = jsonResult!["orderDate"] as! String
        
        label_company.text = "상호 : \(shopName)"
        label_address.text = "주소 : \(shopAddr)"
        lable_phone.text = "전화번호 : \(shopTel)"
        label_date.text = orderDate
        
        //----------------------------------------------------------------------------------------
        
        let goods = jsonResult!["goodsList"] as! NSArray
        
        var goodsName: String = ""
        var goodsCnt: String = ""
        var goodsPrice: String = ""
        for i in 0..<goods.count {
            
            let obj = goods[i] as! NSDictionary
            let gn = obj["goodsName"] as! String
            let gc = obj["goodsCnt"] as! String
            let gp = obj["goodsPrice"] as! String
            
            if goodsName == "" {
                goodsName = gn
                goodsCnt = gc
                goodsPrice = currncyStr(str: gp)
            } else {
                goodsName = "\(goodsName)\n\(gn)"
                goodsCnt = "\(goodsCnt)\n\(gc)"
                goodsPrice = "\(goodsPrice)\n\(currncyStr(str: gp))"
            }
            
        }
        print(goodsName)
        label_menu.text = goodsName
        label_menuNum.text = goodsCnt
        label_menuPrice.text = goodsPrice
        
        //----------------------------------------------------------------------------------------
        
        let orderTotalPrice = jsonResult!["orderTotalPrice"] as! String
        
        label_total.text = currncyStr(str: orderTotalPrice)
        
        //----------------------------------------------------------------------------------------
        
        let orderPriceTax = jsonResult!["orderPriceTax"] as! Int
        let orderTax = jsonResult!["orderTax"] as! Int
        
        label_supply.text = currncyStr(str: String(orderPriceTax))
        label_tex.text = currncyStr(str: String(orderTax))
        
        
        //----------------------------------------------------------------------------------------
        
        label_supplyTotal.text = currncyStr(str: orderTotalPrice)
        label_cardPrice.text = currncyStr(str: orderTotalPrice)
        
        //----------------------------------------------------------------------------------------
        
        var orderInstallmentMonth = jsonResult!["orderInstallmentMonth"] as! String
        let orderPayMethod = jsonResult!["orderPayMethod"] as! String
        let orderApprovalDate = jsonResult!["orderApprovalDate"] as! String
        let orderApprovalNumber = jsonResult!["orderApprovalNumber"] as! String
        
        if orderInstallmentMonth == "" {
            orderInstallmentMonth = "일시불"
        }
        
        label_cardMonth.text = "[\(orderInstallmentMonth)]"
        label_price.text = currncyStr(str: String(orderPriceTax))
        label_texTotal.text = currncyStr(str: String(orderTax))
        label_sum.text = currncyStr(str: orderTotalPrice)
        label_card.text = orderPayMethod
        lable_lastDate.text = orderApprovalDate
        label_receiveNum.text = orderApprovalNumber
        
    }
    
    func getApi() {
        
        let cmd = "get_receipt"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let no = orderNo!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NO>\(no)</NO></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.jsonResult = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if self.jsonResult!["errCode"] as? String == "0000" {

                            self.setPage()

                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                        

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

}

extension UIView {
    
    func snapshot(scrollView: UIScrollView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, false, UIScreen.main.scale)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let savedContentOffset = scrollView.contentOffset
        let savedFrame = frame
        
        scrollView.contentOffset = CGPoint.zero
        frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        scrollView.contentOffset = savedContentOffset
        frame = savedFrame
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
