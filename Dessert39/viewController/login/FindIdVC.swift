//
//  FindIdVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/15.
//

import Foundation
import UIKit
import CryptoKit

class FindIdVC: UIViewController {
    
    @IBOutlet weak var name_input: UITextField!
    @IBOutlet weak var phone_input: UITextField!
    @IBOutlet weak var btn_request: UIButton!
    @IBOutlet weak var btn_auth: UIButton!
    @IBOutlet weak var view_auth: UIView!
    @IBOutlet weak var auth_input: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    
    var networkUtil = NetworkUtil()
    var textFieldComp = TextFieldComp()
    var alertUtil = AlertUtil()
    var sendSMS: SendSMS?
    var findIdModel: FindIdModel?
    var timer: Timer?
    var limiteMin: Int = 2
    var arr: [Int] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "아이디 찾기")
        
        setInput()
        setBtn()
        
        view_auth.isHidden = true
    }

// MARK: - Setting input
    func setInput() {
        
        textFieldComp.setInput(tf: name_input)
        textFieldComp.setInput(tf: phone_input)
        textFieldComp.setInput(tf: auth_input)
        
        name_input.text = ""
        phone_input.text = ""
        auth_input.text = ""
        
        phone_input.addTarget(self, action: #selector(fieldChanged(sender:)), for: .editingChanged)
        auth_input.addTarget(self, action: #selector(fieldChanged(sender:)), for: .editingChanged)
        
    }
    
    @objc func fieldChanged(sender: UITextField) {
        
        if phone_input.text != "" {
            
            btn_request.isUserInteractionEnabled = true
            btn_request.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            
        } else {
            
            btn_request.isUserInteractionEnabled = false
            btn_request.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
            
        }
        
        if auth_input.text != "" {
            
            btn_auth.isUserInteractionEnabled = true
            btn_auth.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            
        } else {
            
            btn_auth.isUserInteractionEnabled = false
            btn_auth.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
            
        }
        
    }
 
// MARK: - Setting button
    func setBtn() {
        
        btn_request.layer.cornerRadius = 5
        btn_auth.layer.cornerRadius = 5
        btn_request.isUserInteractionEnabled = false
        btn_request.addTarget(self, action: #selector(authRequest(sender:)), for: .touchUpInside)
        btn_auth.addTarget(self, action: #selector(authOk(sender:)), for: .touchUpInside)
        
        btn_request.isUserInteractionEnabled = false
        btn_request.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
        
        btn_auth.isUserInteractionEnabled = false
        btn_auth.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
        
    }
    
    @objc func authRequest(sender: UIButton) {
        
        isTextCheck()
        
    }
    
    func isTextCheck() {
        
        if name_input.text == "" {
            
            self.alertUtil.oneItem(self, title: "이름 없음", message: "이름을 입력해 주세요.")
            
        } else if phone_input.text == "" {
            
            self.alertUtil.oneItem(self, title: "휴대폰 없음", message: "휴대폰 번호를 입력해 주세요.")
            
        } else {
            
            view_auth.isHidden = false
            makeAuthNumber()
            setAuthTimer()
            
        }
        
    }
    
    func makeAuthNumber() {
        
        arr = []
        
        for _ in 0..<4 {
            let num = Int.random(in: 0...9)
            arr.append(num)
        }
        
        print(arr)
        networkAuthRequest()
    }
    
    func networkAuthRequest() {
        
        let cmd = "send_sms"
        let phone = phone_input.text!
        let content = "인증번호는 \(arr[0])\(arr[1])\(arr[2])\(arr[3])"
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><HPNUM>\(phone)</HPNUM><CONTENT>\(content)</CONTENT></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.sendSMS = try JSONDecoder().decode(SendSMS.self, from: decrypedData)

                    DispatchQueue.main.async {
                        
                        if self.sendSMS!.errCode == "0000" {
                            
                            print(self.sendSMS! as Any)
                            
                        } else {
                            print(self.sendSMS!.errCode)
                        }
                        
                        self.view.endEditing(true)
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    func setAuthTimer() {
        
        var min = self.limiteMin
        var timeNum = limiteMin * 60
        timerLabel.text = "0\(limiteMin):00"
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            timeNum = timeNum - 1
            let sec = timeNum % 60
            
            if sec == 59 {
                min = min - 1
            }
            
            if sec < 10 {
                self.timerLabel.text = "0\(min):0\(sec)"
            } else {
                self.timerLabel.text = "0\(min):\(sec)"
            }
            
            if min == 0 && sec == 0 {
                
                timer.invalidate()
                self.view.endEditing(true)
                self.alertUtil.oneItem(self, title: "시간 초과", message: "인증번호 유효시간이 지났습니다. /n인증번호를 다시 요청해 주세요.")
                self.auth_input.text = ""
                self.view_auth.isHidden = true
                
            }
            
        }
        
    }
    
    @objc func authOk(sender: UIButton) {
        
        if auth_input.text == "" {
            
            self.alertUtil.oneItem(self, title: "인증번호 없음", message: "인증번호를 입력해 주세요.")
            
        } else {
            
            if auth_input.text == "\(arr[0])\(arr[1])\(arr[2])\(arr[3])" {
                
                timer!.invalidate()
                self.view.endEditing(true)
                netWorkAuth()
                
            } else {
                self.alertUtil.oneItem(self, title: "인증번호 틀림", message: "인증번호를 확인해 주세요.")
            }
            
            
            
        }
        
    }
    
    func netWorkAuth() {
        
        let cmd = "find_id"
        let phone = phone_input.text!
        let name = name_input.text!
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><NAME>\(name)</NAME><PHONE>\(phone)</PHONE></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.findIdModel = try JSONDecoder().decode(FindIdModel.self, from: decrypedData)

                    DispatchQueue.main.async {
                        
                        if self.findIdModel!.errCode == "0000" {
                            
                            store.id = self.findIdModel?.userID
                            store.name = self.name_input.text!
                            
                        }
                        
                        self.performSegue(withIdentifier: "findIdResult", sender: self)
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }

}

