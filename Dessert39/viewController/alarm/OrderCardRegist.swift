//
//  OrderCardRegist.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/08.
//

import UIKit

class OrderCardRegist: UIViewController {
    
    var networkUtil = NetworkUtil()
    var textFieldComp = TextFieldComp()
    
    var accessToken: String?
    var jti: String?
    let accessParams = [
        "password" : store.reappayPW,
        "userId" : store.reappayID
    ]
    
    var goodsName: String?
    var totAmt: String?
    var infoModel: NSDictionary?
    
    @IBOutlet var cardNums: [UITextField]!
    @IBOutlet var dateNums: [UITextField]!
    @IBOutlet var pwTF: UITextField!
    
    @IBOutlet var btn_regist: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
//        getAccessToken()
        setCardNum()
        setDateNum()
        textFieldComp.setInput(tf: pwTF)
        pwTF.inputAccessoryView = toolbar
        pwTF.addTarget(self, action: #selector(dateNumTfChange(textField:)), for: .editingChanged)
        
//        btn_regist.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
        btn_regist.layer.cornerRadius = btn_regist.frame.height / 2
        btn_regist.addTarget(self, action: #selector(registHandler(sender:)), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "결제카드 등록")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    func setCardNum() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        for tf in cardNums {
            
            let stView = tf.superview
            let parentView = stView?.superview
            let boarderView = parentView?.superview
            
            parentView?.layer.cornerRadius = 5
            boarderView?.layer.cornerRadius = 5
            
            parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
            boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
            
            tf.addTarget(self, action: #selector(cardNumTfDidBegin(textField:)), for: .editingDidBegin)
            tf.addTarget(self, action: #selector(cardNumTfDidEnd(textField:)), for: .editingDidEnd)
            tf.addTarget(self, action: #selector(cardNumTfChange(textField:)), for: .editingChanged)
            tf.inputAccessoryView = toolbar
            
        }
        
    }
    
    @objc func cardNumTfChange(textField: UITextField) {

        checkMaxLength(textField: textField, maxLength: 4)
        
    }
    
    @objc func cardNumTfDidBegin(textField: UITextField) {

        let stView = textField.superview
        let parentView = stView?.superview
        let boarderView = parentView?.superview
        
        parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x484848)
        
    }
    
    @objc func cardNumTfDidEnd(textField: UITextField) {

        for tf in cardNums {
            
            if tf.text == "" {
                
                let stView = textField.superview
                let parentView = stView?.superview
                let boarderView = parentView?.superview
                
                parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
                boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
                
                return
                
            }
            
        }

    }
    
    func setDateNum() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        for tf in dateNums {
            
            let stView = tf.superview
            let parentView = stView?.superview
            let boarderView = parentView?.superview
            
            parentView?.layer.cornerRadius = 5
            boarderView?.layer.cornerRadius = 5
            
            parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
            boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
            
            tf.addTarget(self, action: #selector(dateNumTfDidBegin(textField:)), for: .editingDidBegin)
            tf.addTarget(self, action: #selector(dateNumTfDidEnd(textField:)), for: .editingDidEnd)
            tf.addTarget(self, action: #selector(dateNumTfChange(textField:)), for: .editingChanged)
            tf.inputAccessoryView = toolbar
            
        }
        
    }
    
    @objc func dateNumTfDidBegin(textField: UITextField) {

        let stView = textField.superview
        let parentView = stView?.superview
        let boarderView = parentView?.superview
        
        parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x484848)
        
    }
    
    @objc func dateNumTfDidEnd(textField: UITextField) {

        for tf in dateNums {
            
            if tf.text == "" {
                
                let stView = textField.superview
                let parentView = stView?.superview
                let boarderView = parentView?.superview
                
                parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
                boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
                
                return
                
            }
            
        }

    }
    
    @objc func dateNumTfChange(textField: UITextField) {

        checkMaxLength(textField: textField, maxLength: 2)
        
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    func checkMaxLength(textField: UITextField!, maxLength: Int) {
        
        if (textField.text?.count ?? 0 > maxLength) {
            textField.deleteBackward()
        }
        
    }
    
    @objc func registHandler(sender: UIButton) {
        
        self.view.endEditing(true)
        
        for item in cardNums {
            
            if item.text == "" {
                AlertUtil().oneItem(self, title: "카드번호를 입력하세요", message: "")
                return
            }
            
        }
        
        for item in dateNums {
            
            if item.text == "" {
                AlertUtil().oneItem(self, title: "유효기간을 입력하세요", message: "")
                return
            }
            
        }
        
        if pwTF.text == "" {
            AlertUtil().oneItem(self, title: "비밀번호를 입력하세요", message: "")
            return
        }
        
//        if let billkeys = UserDefaults.standard.array(forKey: "billkeys") {
//            
//            var cardNumb: String = ""
//            for (index, item) in cardNums.enumerated() {
//                
//                if index == 1 {
//                    cardNumb = "\(cardNumb)\(String(describing: item.text!.prefix(2)))XX"
//                } else if index == 2 {
//                    cardNumb = "\(cardNumb)XXXX"
//                } else {
//                    cardNumb = "\(cardNumb)\(String(describing: item.text!))"
//                }
//                
//            }
//            
//            for item in billkeys {
//                
//                let obj = item as? NSDictionary
//                let cardNumber = obj!["billkeymaskedCardNumb"] as! String
//                
//                if cardNumber  == cardNumb {
//                    AlertUtil().oneItem(self, title: "이미 등록된 카드 입니다", message: "")
//                    return
//                }
//                
//            }
//            
//        }
        
        ShowLoading.loadingStart(uiView: self.view)
        getBirth()
        
    }
    
    func getBirth() {
        
        let cmd = "get_member_info"
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
                    
                    self.infoModel = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if self.infoModel!["errCode"] as! String == "0000" {
                            
                            let obj = self.infoModel!
                            let hp = obj["hp"] as! String
                            var strIndex: String?
                            var strBillkey: String?
                            
                            if var hps = UserDefaults.standard.array(forKey: "hps") {
                                
                                for (index, item) in hps.enumerated() {
                                    
                                    if item as! String == hp {
                                        strIndex = String(index)
                                    }
                                    
                                }
                                
                                if strIndex != nil {
                                    strBillkey = "billkeys" + strIndex!
                                } else {
                                    
                                    strBillkey = "billkeys\(hps.count)"
                                    hps.append(hp)
                                    UserDefaults.standard.set(hps, forKey: "hps")
                                    
                                }
                                
                                if let billkeys = UserDefaults.standard.array(forKey: strBillkey!) {
                                    
                                    var cardNumb: String = ""
                                    for (index, item) in self.cardNums.enumerated() {
                                        
                                        if index == 1 {
                                            cardNumb = "\(cardNumb)\(String(describing: item.text!.prefix(2)))XX"
                                        } else if index == 2 {
                                            cardNumb = "\(cardNumb)XXXX"
                                        } else {
                                            cardNumb = "\(cardNumb)\(String(describing: item.text!))"
                                        }
                                        
                                    }
                                    
                                    for item in billkeys {
                                        
                                        let obj = item as? NSDictionary
                                        let cardNumber = obj!["billkeymaskedCardNumb"] as! String
                                        
                                        if cardNumber  == cardNumb {
                                            AlertUtil().oneItem(self, title: "이미 등록된 카드 입니다", message: "")
                                            return
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            self.getAccessToken()
                            
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    func getAccessToken() {
        
        let url = URL(string: "\(store.reappayUrl)auth/login")
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        let jsonData = try? JSONSerialization.data(withJSONObject: accessParams)
        
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
                        self.jti = result!["jti"] as? String
                        
                        DispatchQueue.main.sync {
                            
                            self.registCard()
                            
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
    
    func registCard() {
        
//        var str: String?
//        let dic = [
//            "cardNo": "4906254196174171",
//            "expireYy": "27",
//            "expireMm": "02",
//            "passwd": "14",
//            "birthday": "820222",
//            "timestamp": String(Date().timeIntervalSince1970)
//        ]
//
//        let encoder = JSONEncoder()
//        if let jsonData = try? encoder.encode(dic) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//
//                let iv: String = String(jti!.prefix(16))
//                let encryped: String = AES256CBC.customEncryptString(jsonString, iv: iv, key: "\(store.reappayID)billkeyregist0000000000")!
//                let urlString: String = "\(store.configUrl)?code=\(encryped)"
//                str = urlString.replacingOccurrences(of: "+", with: "%2B")
//
//            }
//        }
        
        var cardNumb: String = ""
        for item in cardNums {
            
            cardNumb = "\(cardNumb)\(String(describing: item.text!))"
            
        }
        
        var expiryDate: String = ""
        for item in dateNums {
            
            expiryDate = "\(expiryDate)\(String(describing: item.text!))"
            
        }
        
        let obj = self.infoModel!
        let birth = obj["birth"] as! String
        let birthStr = String(birth.suffix(6))
    
        let params = [
            "billkey_cardNumb": cardNumb,
            "billkey_expiryDate": expiryDate,
            "billkey_password2": pwTF.text!,
            "billkey_userInfo": birthStr
        ]
        print(params)
        let url = URL(string: "\(store.reappayUrl)pay/billkeyregist")
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
//                    print(jsonResult["content"])
//                    print(jsonResult["message"])
                    if jsonResult["code"] as! String == "A000" {

                        let result:NSDictionary? = jsonResult["content"] as? NSDictionary
                        let obj = self.infoModel!
                        let hp = obj["hp"] as! String
                        var strIndex: String?
                        var strBillkey: String?
                        
                        if var hps = UserDefaults.standard.array(forKey: "hps") {
                            
                            for (index, item) in hps.enumerated() {
                                
                                if item as! String == hp {
                                    strIndex = String(index)
                                }
                                
                            }
                            
                            if strIndex != nil {
                                strBillkey = "billkeys" + strIndex!
                            } else {
                                
                                strBillkey = "billkeys\(hps.count)"
                                hps.append(hp)
                                UserDefaults.standard.set(hps, forKey: "hps")
                                
                            }
                            
                        } else {
                            let array = [hp]
                            UserDefaults.standard.set(array, forKey: "hps")
                            strBillkey = "billkeys0"
                        }
                        
                        let billkeyrespMessage = result?["billkeyrespMessage"] as! String
                        let nameArr = billkeyrespMessage.components(separatedBy: "/")
                        
                        let arr = [
                            "billkeybillingToken": result?["billkeybillingToken"] as! String,
                            "billkeyissuerCardName": nameArr[0],
                            "billkeymaskedCardNumb": result?["billkeymaskedCardNumb"] as! String
                        ]
                        
                        if var billkeys = UserDefaults.standard.array(forKey: strBillkey!) {
                            
                            billkeys.append(arr)
                            UserDefaults.standard.set(billkeys, forKey: strBillkey!)
                            
                        } else {
                            let array = [arr]
                            UserDefaults.standard.set(array, forKey: strBillkey!)
                        }
                        

                        DispatchQueue.main.sync {

                            ShowLoading.loadingStop()
                            
                            let alert = UIAlertController(title: "등록", message: "카드가 등록 되었습니다", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in

                                self.navigationController?.popViewController(animated: true)

                            }))

                            self.present(alert, animated: true, completion: nil)

                        }

                    } else {
                        
                        DispatchQueue.main.sync {
                            ShowLoading.loadingStop()
                            AlertUtil().oneItem(self, title: "등록실패", message: "카드 정보를 다시 확인해 주세요\n본인 명의의 카드만 등록 가능 합니다.")
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
    
//    func reappayRegist() {
//
//        let params = [
//            "billingToken": UserDefaults.standard.string(forKey: "billkey"),
//            "buyerTel": "1644-2927",
//            "cardCate": "02",
//            "goodsName": goodsName,
//            "installment": "0",
//            "interestFree": "0",
//            "productType": "001",
//            "taxFlag": "01",
//            "totAmt": totAmt
//        ]
//
//        let url = URL(string: "\(store.reappayUrl)pay/billkeypay")
//        let session = URLSession.shared
//        let request = NSMutableURLRequest(url: url!)
//        let jsonData = try? JSONSerialization.data(withJSONObject: params)
//
//        request.httpMethod = "POST"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.setValue("bearer " + accessToken!, forHTTPHeaderField: "Authorization")
//        request.httpBody = jsonData
//
//        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
//
//            if data != nil{
//                do{
//
//                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
////                    print(jsonResult["content"])
////                    print(jsonResult["message"])
//                    if jsonResult["status"] as! Int == 200 {
//
//                        DispatchQueue.main.sync {
//
//                            let alert = UIAlertController(title: "결제", message: "등록한 카드로 결제가 되었습니다.", preferredStyle: .alert)
//                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
//
//                                self.navigationController?.popToRootViewController(animated: true)
//
//                            }))
//
//                            self.present(alert, animated: true, completion: nil)
//
//                        }
//
//                    }
//
//                } catch {
//                    print("RequestError : \(error)")
//                }
//
//            }
//
//        }
//
//        task.resume()
//        session.finishTasksAndInvalidate()
//
//    }
    
}
