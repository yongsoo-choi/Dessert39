//
//  PayVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/13.
//

import UIKit

class PayVC: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var label_storeName: UILabel!
    @IBOutlet var label_min: UILabel!
    @IBOutlet var view_min: UIView!{
        didSet{
            view_min.layer.borderWidth = 1
            view_min.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            view_min.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var label_price: UILabel!
    @IBOutlet var label_coupon: UILabel!
    @IBOutlet var label_disc: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet weak var btn_expend: UIButton!
    @IBOutlet var lineView: UIView!
    @IBOutlet var btnView: UIView!{
        didSet{
            btnView.layer.masksToBounds = false
            btnView.layer.shadowColor = UIColor.gray.cgColor
            btnView.layer.shadowOpacity = 0.1
            btnView.layer.shadowOffset = CGSize(width: 0, height: -2)
            btnView.layer.shadowRadius = 2
        }
    }
    @IBOutlet var btn: UIButton!
    
    @IBOutlet var label_total: UILabel!
    
    var alertUtil = AlertUtil()
    var networkUtil = NetworkUtil()
    var jsonResult: NSDictionary?
    var selectedType: Int?
    var isExpend: Bool = true
    var accessToken: String?
    var goodsName: String?
    var totAmt: String?
    var billkeys = [Any]()
    var seletedCard: Int = 0
    
    var SEQ: String = ""
    var APPNO: String = ""
    var CDNAME: String = ""
    var CDNO: String = ""
    var DATE: String = ""
    var TOTAMT: String = ""
    var SPLAMT:String = ""
    var VATAMT: String = ""
    var COINAMT: String = "0"
    var COINPER: String = ""
    
    @IBOutlet var registTypes: [UIButton]!
    @IBOutlet var registView: UIView!
    
    @IBOutlet var btn_addCard: UIButton!{
        didSet{
            btn_addCard.layer.borderWidth = 1
            btn_addCard.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_addCard.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var coinView: UIView!{
        didSet{
            coinView.layer.borderWidth = 1
            coinView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xE6E6E6).cgColor
            coinView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var label_useCoin: UILabel!
    @IBOutlet var label_haveCoin: UILabel!
    @IBOutlet var warning: UIButton!
    
    @IBOutlet var viewMetr: UIView!
    @IBOutlet var moveLayout: NSLayoutConstraint!
    @IBOutlet var btnLayout0: NSLayoutConstraint!
    @IBOutlet var btnLayout1: NSLayoutConstraint!
    
    var addr: String?
    var amount: String?
    var marketPrice: String?
    
    var strIndex: String?
    var strBillkey: String?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? Payment {
            
            if segue.identifier == "payment" {
                segueVC.orderNo = store.orderNo
            }
            
        }
        
        if let segueVC = segue.destination as? CardRegist {
            
            if segue.identifier == "reappaySegue" {
                segueVC.goodsName = goodsName
                segueVC.totAmt = totAmt
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        registTypes[1].isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "결제하기")
        navigationController?.isNavigationBarHidden = false
        
        if let hps = UserDefaults.standard.array(forKey: "hps") {
            
            for (index, item) in hps.enumerated() {
                
                if item as? String == store.hp {
                    strIndex = String(index)
                }
                
            }
            
            if strIndex != nil {
                strBillkey = "billkeys" + strIndex!
            } else {
                strBillkey = "billkeys\(hps.count)"
            }
            
            billkeys = UserDefaults.standard.array(forKey: strBillkey!) ?? []
            
        } else {
            billkeys = []
        }
        
        getOrder()
        setBtn()
        setCollectionView()
        
        if billkeys.count > 0 {
            registView.isHidden = true
        } else {
            registView.isHidden = false
        }
        
        warning.isHidden = true
    }
    
    func setCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let wid = (UIScreen.main.bounds.width - 40) / 1.4
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: ((UIScreen.main.bounds.width - 40)         * 70) / 335)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal

        collectionView.collectionViewLayout = layout
        
    }
    
    func setBtn() {
        
        selectedType = 0
        
        btn.layer.cornerRadius = btn.frame.height / 2
        
        for (index, item) in registTypes.enumerated() {
            
            if index == selectedType {
                
                item.isSelected = true
                
            } else {
                
                item.isSelected = false
                
            }
            
        }
        
        moveLayout.constant = -(viewMetr.frame.size.height)
        viewMetr.alpha = 0
        
    }
    
    @IBAction func typesHandler(_ sender: UIButton) {
        
        if registTypes[selectedType!] == sender {
            // 선택 취소
        } else {
            // 선택
            
//            if registTypes.firstIndex(of: sender) == 1 {
//                
//                AlertUtil().oneItem(self, title: "메테라 결제 서비스는 추후 업데이트를 통해 시행될 예정입니다.", message: "")
//                
//            }
            
            for unselectIndex in registTypes {
                unselectIndex.isSelected = false
            }

            sender.isSelected = true
            selectedType = registTypes.firstIndex(of: sender)

            if selectedType == 1 {

                for i in 0..<billkeys.count {

                    let cell = collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? CardCollectionCell
                    cell!.view_back.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
                    cell!.view_back.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)

                }

                coinView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x040404).cgColor
                coinView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)

                if Double(label_useCoin.text!)! > Double(label_haveCoin.text!)! {

                    coinView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF61D0D).cgColor
                    warning.isHidden = false
                }

                moveLayout.constant = 0
                btnLayout0.constant = -(collectionView.frame.size.height)
                btnLayout1.constant = -(collectionView.frame.size.height)

                UIView.animate(withDuration: 0.2, animations: {

                    self.collectionView.alpha = 0
                    self.registView.alpha = 0
                    self.viewMetr.alpha = 1.0
                    self.warning.alpha = 1.0
                    self.view.layoutIfNeeded()

                }, completion: nil)

            } else {

                if billkeys.count > 0 {

                    let cell = collectionView.cellForItem(at: IndexPath(row: seletedCard, section: 0)) as? CardCollectionCell
                    cell!.view_back.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x040404).cgColor
                    cell!.view_back.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)

                }

                coinView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
                coinView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)

                warning.isHidden = true

                moveLayout.constant = -(viewMetr.frame.size.height)
                btnLayout0.constant = 25
                btnLayout1.constant = 25

                UIView.animate(withDuration: 0.2, animations: {

                    self.collectionView.alpha = 1.0
                    self.registView.alpha = 1.0
                    self.viewMetr.alpha = 0
                    self.warning.alpha = 0
                    self.view.layoutIfNeeded()

                }, completion: nil)


            }
            
            
        }
        
    }
    
    func setting() {
        
        let obj = jsonResult!
        let shopName = obj["shopName"] as! String
        let pickupTime = obj["pickupTime"]!
        let payPrice = obj["payPrice"] as! String
        let couponDiscount = obj["couponDiscount"] as! String
        let totalDiscount = obj["totalDiscount"] as! String
//        let status = obj["status"] as? String
        let goodsList = obj["goodsList"] as! NSArray
        let goodsCount = goodsList.count
        let goodsFir = goodsList[0] as! NSDictionary
        let name = goodsFir["name"] as! String
        
        let billpayID = obj["billPayID"] as? String
        let billpayPW = obj["billPayPWD"] as? String
        
        store.billpayID = billpayID
        store.billpayPW = billpayPW
        
        if goodsCount > 1 {
            goodsName = "\(name) 외\(goodsCount - 1)"
        } else {
            goodsName = "\(name)"
        }
        
        totAmt = payPrice
        
        label_storeName.text = shopName
        label_min.text = "\(pickupTime)분"
        
        label_price.text = currncyStr(str: String(payPrice))
        label_total.text = currncyStr(str: String(payPrice))
        
        if couponDiscount != "" && couponDiscount != "0" {
            label_coupon.text = currncyStr(str: String(couponDiscount))
        } else {
            label_coupon.text = "0원"
        }
        
        if totalDiscount != "" && totalDiscount != "0" {
            label_disc.text = currncyStr(str: String(totalDiscount))
        } else {
            label_disc.text = "0원"
        }
        
        getCoinApi()
        
//        =====매장접수&결제대기
//
//        -----결제완료&매장확인중
//
//        결제취소
//
//        -----제품준비중
//
//        -----제품준비완료
//
//        -----제품픽업완료
//
//        주문거절
//
//        환불신청
//
//        환불완료
        
//        if status == "결제완료&매장확인중" || status == "제품준비중" || status == "제품준비완료" || status == "제품픽업완료" {
//
//            let alert = UIAlertController(title: "결제완료", message: "이미 결제하셨습니다.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
//
//                self.navigationController?.popToRootViewController(animated: true)
//
//            }))
//
//            self.present(alert, animated: true, completion: nil)
//
//        }
//
//        if status == "결제취소" || status == "주문거절" || status == "환불신청" || status == "환불완료" {
//
//            let alert = UIAlertController(title: "취소", message: "주문 또는 결제가 취소 되었습니다.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
//
//                self.navigationController?.popToRootViewController(animated: true)
//
//            }))
//
//            self.present(alert, animated: true, completion: nil)
//
//        }
        
    }
    
    @IBAction func expendAction(_ sender: Any) {
        
        if isExpend {
            
            textLabel.text = ""
            lineView.alpha = 0
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌵ 펴기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            
        } else {
            
            textLabel.text = "\n\n- 결제 후 즉시 메뉴 제조를 시작하므로 주문 완료 후에는 변경 또는 취소할 수 없습니다.\n\n- 매장 사정으로 인해 제품의 재고가 없거나 부족할 경우, 매장 혼잡으로 인해 주문이 취소될 수 있으며 알림으로 전달됩니다.\n\n- 메뉴 제조 완료된 후 20분까지 매장에서 보관 후 폐기됩니다. 폐기된 제품은 재 제공 및 환불이 불가능할 수 있으니 신속히 픽업하여 주시기 바랍니다."
            lineView.alpha = 1
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌃ 접기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
        }
        
        isExpend = !isExpend
        
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
    
    func getCoinApi() {
        
        let cmd = "get_metera_coin_info"
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
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.addr = jsonResult["coinWalletAddr"] as? String
                            self.amount = jsonResult["coinWalletAmount"] as? String
                            self.marketPrice = jsonResult["coinMarketPrice"] as? String
                            
                            self.coinSetting()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func coinSetting() {
        
        let obj = jsonResult!
        let payPrice = obj["payPrice"] as! String
        let useCoin = ceil(Double(payPrice)! / Double(marketPrice!)! * store.metr) / store.metr
        
        let strAmount = self.amount ?? "0"
        let amo = String(Double(strAmount)! / store.metr)
        
        label_haveCoin.text = amo
        label_useCoin.text = String(useCoin)
        
    }
    
    func getOrder() {
        
        let cmd = "get_order"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let orderno = store.orderNo!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><ORDERNO>\(orderno)</ORDERNO></DATA>"
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

                            self.setting()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

    @IBAction func setPay(_ sender: Any) {
        
        if selectedType == 0 {
            
            if billkeys.count == 0 {
                AlertUtil().oneItem(self, title: "등록된 카드가 없습니다.", message: "")
            } else {
                ShowLoading.loadingStart(uiView: self.view)
                getAccessToken()
            }
            
        } else {
            
            if warning.isHidden {
                
                ShowLoading.loadingStart(uiView: self.view)
                
                let obj = jsonResult!
                let payPrice = obj["payPrice"] as! String
                let useCoin = Int(ceil(Double(payPrice)! / Double(marketPrice!)! * store.metr))
                
                COINAMT = String(useCoin)
                COINPER = self.marketPrice!
                
                orderDone()
                
            } else {
                AlertUtil().oneItem(self, title: "결제 가능 메테라 잔고가 부족합니다.", message: "")
            }
            
            
        }
        
    }
    
    func getAccessToken() {
        
        let params = [
            "password" : store.billpayPW ?? store.reappayPW,
            "userId" : store.billpayID ?? store.reappayID
        ]
        
        let url = URL(string: "\(store.reappayUrl)auth/login")
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            if data != nil{
                do{
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    if jsonResult["status"] as! Int == 200 {
                        
                        let result:NSDictionary? = jsonResult["content"] as? NSDictionary
                        self.accessToken = result!["access_token"] as? String
                        
                        DispatchQueue.main.sync {
                            
                            self.reappayRegist()
                            
                        }
                        
                    }
                    
                } catch {
                    print("RequestError : \(error)")
                }

            }

        }

        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func reappayRegist() {
        
        let obj = billkeys[seletedCard] as! NSDictionary
        let billingToken = obj["billkeybillingToken"] as! String
        
        let splAmt = Double(Int(totAmt!)! * 10 / 110)
        let vatAmt = lroundl(splAmt)
    
        let params = [
            "billingToken": billingToken,
            "buyerTel": "1644-2927",
            "cardCate": "02",
            "goodsName": goodsName,
            "installment": "0",
            "interestFree": "0",
            "productType": "001",
            "taxFlag": "01",
            "totAmt": totAmt,
            "vatAmt": "\(vatAmt)"
        ]
        
        let url = URL(string: "\(store.reappayUrl)pay/billkeypay")
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            if data != nil{
                do{
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary

                    if jsonResult["status"] as! Int == 200 {
                        
                        let result:NSDictionary? = jsonResult["content"] as? NSDictionary
                        
                        self.SEQ = result?["billkeyTranseq"] as! String
                        self.APPNO = result?["billkeyapprovalNumb"] as! String
                        self.CDNAME = result?["billkeyissuerCardName"] as! String
                        self.CDNO = result?["billkeymaskedCardNumb"] as! String
                        self.DATE = result?["billkeytradeDateTime"] as! String
                        self.TOTAMT = result?["billkeytotAmt"] as! String
                        self.SPLAMT = result?["billkeysplAmt"] as! String
                        self.VATAMT = result?["billkeyvatAmt"] as! String
                    
                        DispatchQueue.main.sync {
                            
                            self.orderDone()

                        }

                    }
                    
                } catch {
                    print("RequestError : \(error)")
                }

            }

        }

        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func orderDone() {
        
        let cmd = "set_billpay_info"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let orderno = store.orderNo!
        let seq = SEQ
        let appno = APPNO
        let cdname = CDNAME
        let cdno = CDNO
        let date = DATE
        let totamt = TOTAMT
        let splamt = SPLAMT
        let vatamt = VATAMT
        let coinamt = COINAMT
        let coinper = COINPER
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><ORDNO>\(orderno)</ORDNO><SEQ>\(seq)</SEQ><APPNO>\(appno)</APPNO><CDNAME>\(cdname)</CDNAME><CDNO>\(cdno)</CDNO><DATE>\(date)</DATE><TOTAMT>\(totamt)</TOTAMT><SPLAMT>\(splamt)</SPLAMT><VATAMT>\(vatamt)</VATAMT><COINAMT>\(coinamt)</COINAMT><COINPRC>\(coinper)</COINPRC></DATA>"
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
                        
                        ShowLoading.loadingStop()
                        
                        if self.jsonResult!["errCode"] as? String == "0000" {
                            
                            var msg = ""
                             
                            if self.selectedType == 0 {
                                msg = "등록된 카드로 결제가 되었습니다."
                            } else {
                                msg = "메테라 코인으로 결제가 되었습니다."
                            }

                            let alert = UIAlertController(title: "결제", message: msg, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                
                                self.navigationController?.popToRootViewController(animated: true)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    

}

extension PayVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return billkeys.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let oldCell = collectionView.cellForItem(at: IndexPath(row: seletedCard, section: 0)) as? CardCollectionCell
        oldCell!.view_back.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
        oldCell!.view_back.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)
        
        let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionCell
        cell!.view_back.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x040404).cgColor
        cell!.view_back.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        
        seletedCard = indexPath.row
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionCell", for: indexPath) as! CardCollectionCell
        let obj = self.billkeys[indexPath.row] as? NSDictionary
        let cardName = obj!["billkeyissuerCardName"] as! String
        let cardNumber = obj!["billkeymaskedCardNumb"] as! String
        
        cell.label_name.text = cardName
        cell.label_num.text = cardNumber
        
        if indexPath.row == seletedCard {
            cell.view_back.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x040404).cgColor
            cell.view_back.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        }
        
        return cell
        
    }
    
}
