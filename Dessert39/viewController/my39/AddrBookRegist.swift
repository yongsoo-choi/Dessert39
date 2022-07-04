//
//  AddrBookRegist.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/13.
//

import UIKit

class AddrBookRegist: UIViewController {
    
    @IBOutlet var tf_addr: UITextField!
    @IBOutlet var tf_nick: UITextField!
    @IBOutlet var btn_regist: UIButton!
    
    @IBOutlet var btn_qr: UIButton!{
        didSet{
            btn_qr.layer.cornerRadius = 5
        }
    }

    var addrBook = [Any]()
    var textFieldComp = TextFieldComp()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "주소록 등록")
        navigationController?.isNavigationBarHidden = false
        
        addrBook = UserDefaults.standard.array(forKey: "addrBook") ?? []
        setTextField()
        
    }
    
    func setTextField() {
        
        if store.copyAddr != nil {
            
            tf_addr.text = store.copyAddr
            store.copyAddr = nil
            
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        textFieldComp.setInput(tf: tf_addr)
        tf_addr.inputAccessoryView = toolbar
        
        textFieldComp.setInput(tf: tf_nick)
        tf_nick.inputAccessoryView = toolbar
        
        btn_regist.layer.cornerRadius = btn_regist.frame.size.height / 2
        btn_regist.addTarget(self, action: #selector(registHandler(sender:)), for: .touchUpInside)
        
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }

    @IBAction func qrReader(_ sender: Any) {
        
        let pop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "QrcodeReader") as! QrcodeReader
        pop.modalPresentationStyle = .fullScreen

        self.present(pop, animated: true, completion: nil)
        
    }
    
    @objc func registHandler(sender: UIButton) {
        
        if tf_addr.text == "" {
            AlertUtil().oneItem(self, title: "등록할 주소를 입력하세요.", message: "")
            return
        }
        
        if tf_nick.text == "" {
            AlertUtil().oneItem(self, title: "등록할 주소 별명을 입력하세요.", message: "")
            return
        }
        
        self.regist()
        
    }
    
    func regist() {
        
        let arr = [
            "name": tf_nick.text!,
            "addr": tf_addr.text!
        ]
        
        if var addrBook = UserDefaults.standard.array(forKey: "addrBook") {
            
            addrBook.append(arr)
            UserDefaults.standard.set(addrBook, forKey: "addrBook")
            
        } else {
            let array = [arr]
            UserDefaults.standard.set(array, forKey: "addrBook")
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }

}
