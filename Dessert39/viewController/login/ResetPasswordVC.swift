//
//  ResetPasswordVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/20.
//

import UIKit

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pw_input: UITextField!
    @IBOutlet weak var pwCheck_input: UITextField!
    @IBOutlet weak var btn_reset: UIButton!
    
    var textFieldComp = TextFieldComp()
    var alertUtil = AlertUtil()
    var networkUtil = NetworkUtil()
    var resetPwModel: ApiDefaultModel?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setEndEdting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "비밀번호 재설정")
        setInput()
        setBtn()
        registerNotifications()
        
        if let name = store.name {
            nameLabel.text = "\(name) 고객님"
        }
        
        
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
        
        textFieldComp.setInput(tf: pw_input)
        textFieldComp.setInput(tf: pwCheck_input)
        
    }
    
    func setBtn() {
        
        btn_reset.layer.cornerRadius = btn_reset.frame.height / 2
        btn_reset.addTarget(self, action: #selector(resetPw(sender:)), for: .touchUpInside)
        
    }
    
    @objc func resetPw(sender: UIButton) {
        
        self.view.endEditing(true)
        
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
        
        resetPwApi()
        
    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "비밀번호 재설정", message: str)
        
    }
    
    func validpassword(mypassword : String) -> Bool {
        //숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
        let passwordreg = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,}")
        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        
        return passwordtesting.evaluate(with: mypassword)
        
    }

    func resetPwApi() {
        
        let cmd = "set_user_pwd"
        let id = store.id!
        let pwd = pw_input.text!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id)</ID><PWD>\(pwd)</PWD></DATA>"
        
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.resetPwModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)

                    DispatchQueue.main.async {
                        
                        if self.resetPwModel!.errCode == "0000" {
                            
                            self.performSegue(withIdentifier: "resetPwSegue", sender: self)
                            
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }

}
