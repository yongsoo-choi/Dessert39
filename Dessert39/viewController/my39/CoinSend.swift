//
//  CoinSend.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/12.
//

import UIKit

class CoinSend: UIViewController {

    @IBOutlet var boxView: UIView!{
        didSet{
            boxView.layer.cornerRadius = 5
            boxView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            boxView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet var tf_addr: UITextField!
    @IBOutlet var tf_coin: UITextField!
    
    @IBOutlet var btn_qr: UIButton!{
        didSet{
            btn_qr.layer.cornerRadius = 5
        }
    }
    @IBOutlet var btn_all: UIButton!{
        didSet{
            btn_all.layer.cornerRadius = 5
            btn_all.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_all.layer.borderWidth = 1
        }
    }
    
    @IBOutlet var label_metr: UILabel!
    
    @IBOutlet var grayView: UIView!{
        didSet{
            grayView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet var btn_send: UIButton!
    @IBOutlet var warning: UIButton!
    
    var textFieldComp = TextFieldComp()
    var metr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "메테라 코인 송금")
        navigationController?.isNavigationBarHidden = false
        
        setTextField()
        
    }
    
    func setTextField() {
        
        if store.copyAddr != nil {
            
            tf_addr.text = store.copyAddr
            store.copyAddr = nil
            
        }
        
        label_metr.text = metr
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        textFieldComp.setInput(tf: tf_addr)
        tf_addr.inputAccessoryView = toolbar
        
        textFieldComp.setInput(tf: tf_coin)
        tf_coin.inputAccessoryView = toolbar
        tf_coin.addTarget(self, action: #selector(textFieldDidEnd(textField:)), for: .editingDidEnd)
        
        btn_send.layer.cornerRadius = btn_send.frame.size.height / 2
        btn_send.addTarget(self, action: #selector(sendHandler(sender:)), for: .touchUpInside)
        
        warning.isHidden = true
        
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }

    @IBAction func qrReader(_ sender: Any) {
        
        let pop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "QrcodeReader") as! QrcodeReader
//        pop.modalPresentationStyle = .fullScreen

        self.present(pop, animated: true, completion: nil)
        
    }
    
    @IBAction func sendAll(_ sender: Any) {
        
        tf_coin.text = label_metr.text
        
    }
    
    @objc func textFieldDidEnd(textField: UITextField) {

        let parentView = textField.superview
        let boarderView = parentView?.superview
        
        if textField.text != ""{
            
            if Double(tf_coin.text!)! <= 0 {
                warning.isHidden = false
                boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF61D0D)
            } else {
                warning.isHidden = true
            }
            
        } else {
            
            warning.isHidden = true
            parentView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xf8f8f8)
            boarderView!.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xe1e1e1)
            
        }

    }
    
    @objc func sendHandler(sender: UIButton) {
        
        if tf_addr.text == "" {
            AlertUtil().oneItem(self, title: "송금할 주소를 입력하세요.", message: "")
            return
        }
        
        if tf_coin.text == "" {
            AlertUtil().oneItem(self, title: "송금할 코인을 입력하세요.", message: "")
            return
        }
        
        if tf_coin.text != "" {
            
            if Double(tf_coin.text!)! > Double(label_metr.text!)! {
                AlertUtil().oneItem(self, title: "보유 코인이 부족합니다.", message: "")
                return
            }
            
            if Double(tf_coin.text!)! <= 0 {
                AlertUtil().oneItem(self, title: "전송 코인은 0보다 많아야 합니다.", message: "")
                return
            }
            
        }
        
        self.sendApi()
        
    }
    
    func sendApi() {
        
        ShowLoading.loadingStart(uiView: self.view)
        
        let cmd = "send_coin_to_address"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let amount = String(Int(Double(tf_coin.text!)! * store.metr))
        let addr = tf_addr.text!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><AMOUNT>\(amount)</AMOUNT><ADDR>\(addr)</ADDR></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        NetworkUtil().request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            ShowLoading.loadingStop()
                            
                            let alert = UIAlertController(title: "송금", message: "코인이 송금 되었습니다", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in

                                self.navigationController?.popToRootViewController(animated: true)

                            }))

                            self.present(alert, animated: true, completion: nil)

                        } else {
                            AlertUtil().oneItem(self, title: "실패", message: "송금이 되지 않았습니다.\n지갑주소 또는 수량을 확인해주세요")
                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    
}
