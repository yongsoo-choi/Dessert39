//
//  Ask.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/01.
//

import UIKit

class Ask: UIViewController {

    @IBOutlet weak var textField_type: UITextField!
    @IBOutlet weak var textField_title: UITextField!
    @IBOutlet weak var textView_contents: UITextView!
    @IBOutlet weak var btn_agree: UIButton!
    @IBOutlet weak var btn_ok: UIButton!
    
    var alertUtil = AlertUtil()
    
    var selectedType: String?
    var typeList = ["결제&주문", "쿠폰", "이벤트", "회원정보", "불만사항 접수", "기타"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        textField_title.inputAccessoryView = toolbar
        textView_contents.inputAccessoryView = toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        btn_ok.layer.cornerRadius = btn_ok.frame.height / 2
        
        createPickerView()
        dismissPickerView()
        
        setTextField()
        
        self.view.endEditing(true)
    }
    
    func createPickerView() {
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textField_type.inputView = pickerView
        
    }
    
    func dismissPickerView() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField_type.inputAccessoryView = toolBar
        
    }
    
    @objc func action() {
        view.endEditing(true)
    }
    
    func setTextField() {
        
        let imageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 10, height: 5))
        let image = UIImage(systemName: "chevron.down")
        imageView.image = image
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 5))
        iconContainerView.addSubview(imageView)
        
        textField_type.rightView = iconContainerView
        textField_type.rightViewMode = .always
        textField_type.tintColor = .lightGray
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 5))
        textField_type.leftView = paddingView
        textField_type.leftViewMode = .always
        
        textView_contents.delegate = self
        textView_contents.layer.borderWidth = 1
        textView_contents.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
        textView_contents.layer.cornerRadius = 5
        textView_contents.text = "문의 내용을 입력해 주세요."
        textView_contents.textColor = UIColor.lightGray
        
    }

    @IBAction func didTapAgree(_ sender: UIButton) {
        sender.isSelected.toggle()
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = CGFloat(-(keyboardHeight)) + 100
            
        }
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @IBAction func DoneAsk(_ sender: UIButton) {
        
        if textField_type.text == "" {
            alertHandler("문의 유형을 선택해 주세요")
            return
        }
        
        if textField_title.text == "" {
            alertHandler("제목을 입력해 주세요")
            return
        }
        
        if textView_contents.text == "문의 내용을 입력해 주세요." {
            alertHandler("내용을 입력해 주세요")
            return
        }
        
        if !btn_agree.isSelected {
            alertHandler("개인 정보 수집 및 이용에 동의해 주세요.")
            return
        }
        
        store.askTitle = textField_title.text!
        store.askContents = textView_contents.text!
        store.askType = textField_type.text!
        
        let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "AskDone") as! AskDone
        pop.modalPresentationStyle = .overFullScreen
        self.present(pop, animated: false, completion: nil)
        
    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "문의하기", message: str)
        
    }
    
}

extension Ask: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedType = typeList[row]
        textField_type.text = selectedType!
        
    }
    
}

extension Ask: UITextViewDelegate {
    
    // TextView Place Holder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
        }
        
    }
    // TextView Place Holder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "문의 내용을 입력해 주세요."
            textView.textColor = UIColor.lightGray
        }
    }
    
}
