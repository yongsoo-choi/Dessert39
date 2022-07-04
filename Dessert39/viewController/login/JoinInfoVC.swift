//
//  JoinInfoVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/20.
//

import UIKit

class JoinInfoVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var id_input: UITextField!
    @IBOutlet weak var idInfo: UILabel!
    @IBOutlet weak var idCheck: UIButton!
    @IBOutlet weak var pw_input: UITextField!
    @IBOutlet weak var pwCheck_input: UITextField!
    @IBOutlet weak var email_input: UITextField!
    @IBOutlet weak var nick_input: UITextField!
    @IBOutlet weak var name_input: UITextField!
    @IBOutlet weak var phone_input: UITextField!
    @IBOutlet weak var birth_input: UITextField!
    @IBOutlet weak var btn_join: UIButton!
    
    var networkUtil = NetworkUtil()
    var textFieldComp = TextFieldComp()
    var alertUtil = AlertUtil()
    var idCheckModel: ApiDefaultModel?
    var isCheck: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setEndEdting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "내 정보")
        navigationController?.isNavigationBarHidden = false
        
        setInput()
        setBtn()
        registerNotifications()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.contentInset.bottom = 0
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height - 150
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    func setEndEdting() {
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
    }
    
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)

    }
    
    func setInput() {
        
        idInfo.text = ""
        textFieldComp.setInput(tf: id_input)
        textFieldComp.setInput(tf: pw_input)
        textFieldComp.setInput(tf: pwCheck_input)
        textFieldComp.setInput(tf: email_input)
        textFieldComp.setInput(tf: nick_input)
        
        textFieldComp.setUnableInput(tf: name_input)
        name_input.text = store.name
        textFieldComp.setUnableInput(tf: phone_input)
        phone_input.text = store.hp
        textFieldComp.setUnableInput(tf: birth_input)
        birth_input.text = store.birth
        
    }
    
    func setBtn() {
        
        btn_join.layer.cornerRadius = btn_join.frame.height / 2
        idCheck.layer.cornerRadius = 5
        idCheck.addTarget(self, action: #selector(idCheckHandler(sender:)), for: .touchUpInside)
        
    }
    
    @objc func idCheckHandler(sender: UIButton) {
        
        if id_input.text == "" {
            alertHandler("아이디를 입력해 주세요")
            return
        }
        
        isCheckApi()
        
    }
    
    func isCheckApi() {
        
        let cmd = "chk_id"
        let id = id_input.text!
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id)</ID></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.idCheckModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)

                    DispatchQueue.main.async {
                        
                        if self.idCheckModel!.errCode == "0000" {
                            self.isCheck = true
                        }
                        
                        self.idInfo.text = self.idCheckModel?.errMsg
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    @IBAction func joinHandler(_ sender: Any) {
        
        if id_input.text == "" {
            alertHandler("아이디를 입력해 주세요")
            return
        }
        
        if !isCheck {
            alertHandler("아이디 중복 확인을 해주세요")
            return
        }
        
        if pw_input.text == "" {
            alertHandler("비밀번호를 입력해 주세요")
            return
        }
        
        if let pw = pw_input.text {
            if !validpassword(mypassword: pw) {
                alertHandler("비밀번호는 영문+숫자 조합 8자 이상 입니다")
                return
            }
        }
        
        if pwCheck_input.text == "" {
            alertHandler("비밀번호 확인을 해주세요")
            return
        }
        
        if pw_input.text != pwCheck_input.text {
            alertHandler("비밀번호가 일치하지 않습니다")
            return
        }
        
        if email_input.text == "" {
            alertHandler("이메일을 입력해 주세요")
            return
        }
        
        if let em = email_input.text {
            if !isValidEmail(emailStr: em) {
                alertHandler("이메일 형식이 맞지 않습니다")
                return
            }
        }
        
        joinApi()
        
    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "정보입력", message: str)
        
    }
    
    func validpassword(mypassword : String) -> Bool {
        //숫자+문자 포함해서 8
        let passwordreg = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,}")
        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        
        return passwordtesting.evaluate(with: mypassword)
        
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
       return emailTest.evaluate(with: emailStr)
        
    }
    
    func joinApi() {
        
        let cmd = "mem_reg"
        let id = id_input.text!
        let pwd = pw_input.text!
        let email = email_input.text!
        let nick = nick_input.text!
        let name = name_input.text!
        let phone = phone_input.text!
        let birth = birth_input.text!
        let marketing = store.isMarketing
        let uuid = store.fcmToken
        let os = "ios"
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id)</ID><PWD>\(pwd)</PWD><EMAIL>\(email)</EMAIL><NICK>\(nick)</NICK><NAME>\(name)</NAME><PHONE>\(phone)</PHONE><BIRTH>\(birth)</BIRTH><MARKETING>\(marketing)</MARKETING><UUID>\(uuid)</UUID><OS>\(os)</OS></DATA>"
        
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.idCheckModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)

                    DispatchQueue.main.async {
                        
                        if self.idCheckModel!.errCode == "0000" {
                            
                            UserDefaults.standard.set(self.idCheckModel?.strToken, forKey: "loginToken")
                            self.performSegue(withIdentifier: "joinSuccess", sender: self)
                            
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }

}
