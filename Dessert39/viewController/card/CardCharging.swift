//
//  CardCharging.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/01.
//

import UIKit
import PhotosUI

class CardCharging: UIViewController {
    
    var parentView: String?

    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var selectedTitle: UILabel!
    @IBOutlet weak var attentionView: UIView!
    @IBOutlet weak var standardView: UIView!
    
    @IBOutlet var typeButtons: [UIButton]!
    @IBOutlet var standardButtons: [UIButton]!
    @IBOutlet var chargingButtons: [UIButton]!
    @IBOutlet var meansButtons: [UIButton]!
    
    @IBOutlet weak var input_standard: UITextField!
    @IBOutlet weak var amountTop: NSLayoutConstraint!
    @IBOutlet weak var input_charging: UITextField!
    @IBOutlet weak var meansTop: NSLayoutConstraint!
    
    @IBOutlet weak var attentionAspect: NSLayoutConstraint!
    @IBOutlet weak var lineViewTop: NSLayoutConstraint!
    @IBOutlet weak var attentionText: UILabel!
    @IBOutlet weak var btn_expend: UIButton!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var btn_register: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    @IBOutlet weak var btn_setChange: UIButton!
    @IBOutlet weak var generalBtns: UIStackView!
    
    var networkUtil = NetworkUtil()
    var alertUtil = AlertUtil()
    var isExpend = true
    var expendHei: CGFloat?
    var selectedType: Int?
    var selectedStandard: Int?
    var selectedCharging: Int?
    var selectedMeans: Int?
    
    var moneyArr = ["10,000", "30,000", "50,000", "70,000", "100,000"]
    var money = ["10000", "30000", "50000", "70000", "100000"]
    var meansArr = ["신용카드"]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? Payment {
            if segue.identifier == "payment"{
                segueVC.price = money[selectedCharging!]
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "카드충전")
        input_standard.delegate = self
        input_charging.delegate = self
        
        setBtn()
        attentionView.layer.cornerRadius = 10
        
        if let asset = store.fetchResult?[0] {
            loadPHAsset(asset: asset)
            selectedTitle.text = "Custom Design"
        }
        
        if let cameraImage = store.cameraImage {
            self.selectedImage.image = cameraImage
            selectedTitle.text = "Custom Design"
        }
        
        if let selectedName = store.cardName {
            
            self.loadImage(urlString: store.cardPath!) { image in

                DispatchQueue.main.async {
                    self.selectedImage.image = image
                }

            }
            
            selectedTitle.text = selectedName
        }
        
        if let userCardPath = store.userCardPath {
            
            self.loadImage(urlString: userCardPath) { image in

                DispatchQueue.main.async {
                    self.selectedImage.image = image
                }

            }
            
            selectedTitle.text = store.userCardName
        }
        
    }
    
    func loadPHAsset(asset: PHAsset) {
        
        let imageManager = PHImageManager()
        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: 150 * scale, height: 150 * scale)
        
        self.selectedImage.image = nil
        
        imageManager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: nil) { image, info in
            self.selectedImage.image = image
        }
        
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
    
    func setBtn() {
        
        selectedType = 0
        btn_register.isHidden = true
        
        for (index, item) in typeButtons.enumerated() {
            
            if index == selectedType {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                
            } else {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                
            }
            
        }
        
        for (index, item) in standardButtons.enumerated() {
            
            if index == selectedStandard {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                
            } else {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                
            }
            
        }
        
        for (index, item) in chargingButtons.enumerated() {
            
            if index == selectedCharging {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                
            } else {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                
            }
            
        }
        
        for (index, item) in meansButtons.enumerated() {
            
            if index == selectedMeans {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                
            } else {
                
                item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                item.layer.borderWidth = 1
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
                item.layer.cornerRadius = 5
                
            }
            
        }
        
        buttonView.addShadow(location: .top)
        btn_register.layer.cornerRadius = btn_register.frame.height / 2
        btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
        btn_register.isUserInteractionEnabled = false
        btn_register.addTarget(self, action: #selector(registerHandler(sender:)), for: .touchUpInside)
        
        btn_setChange.layer.cornerRadius = 5
        btn_cancel.layer.cornerRadius = 5
        btn_cancel.layer.borderWidth = 1
        btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        
    }
    
    @IBAction func touchTypeButtons(_ sender: UIButton) {
        
        if selectedType != nil{
            
            if typeButtons[selectedType!] == sender {
                // 선택 취소
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                selectedType = nil
                
            } else {
                // 선택
                for unselectIndex in typeButtons {
                    unselectIndex.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                }
                
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                selectedType = typeButtons.firstIndex(of: sender)
            }
            
        } else {
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedType = typeButtons.firstIndex(of: sender)
        }
        
        checkButtons()
        print(selectedType ?? 0)
        
        if selectedType == 1 {
            self.amountTop.constant = -(self.standardView.frame.size.height)
            self.btn_register.isHidden = false
            self.generalBtns.isHidden = true
        } else {
            self.amountTop.constant = 0
            self.btn_register.isHidden = true
            self.generalBtns.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func touchStandardButtons(_ sender: UIButton) {
        
        if selectedStandard != nil{
            
            if standardButtons[selectedStandard!] == sender {
                // 선택 취소
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                selectedStandard = nil
                
            } else {
                // 선택
                for unselectIndex in standardButtons {
                    unselectIndex.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                }
                
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                selectedStandard = standardButtons.firstIndex(of: sender)
                
            }
            
        } else {
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedStandard = standardButtons.firstIndex(of: sender)
        }
        
        if self.selectedStandard == self.standardButtons.count - 1 {
            self.amountTop.constant = self.input_standard.frame.height + 10
            input_standard.text = ""
            self.input_standard.becomeFirstResponder()
        } else {
            self.amountTop.constant = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        checkButtons()
        print(selectedStandard ?? 0)
        
    }
    
    @IBAction func touchChargingButtons(_ sender: UIButton) {
        
        if selectedCharging != nil{
            
            if chargingButtons[selectedCharging!] == sender {
                // 선택 취소
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                selectedStandard = nil
                
            } else {
                // 선택
                for unselectIndex in chargingButtons {
                    unselectIndex.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                }
                
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                selectedCharging = chargingButtons.firstIndex(of: sender)
                
            }
            
        } else {
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedCharging = chargingButtons.firstIndex(of: sender)
        }
        
        if self.selectedCharging == self.chargingButtons.count - 1 {
            self.meansTop.constant = self.input_charging.frame.height + 10
            input_charging.text = ""
            self.input_charging.becomeFirstResponder()
        } else {
            self.meansTop.constant = 0
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        checkButtons()
        print(selectedCharging ?? 0)
        
    }
    
    @IBAction func touchMeansButtons(_ sender: UIButton) {
        
        if selectedMeans != nil{
            
            if meansButtons[selectedMeans!] == sender {
                // 선택 취소
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                selectedMeans = nil
                
            } else {
                // 선택
                for unselectIndex in meansButtons {
                    unselectIndex.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                }
                
                sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                selectedMeans = meansButtons.firstIndex(of: sender)
                
            }
            
        } else {
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedMeans = meansButtons.firstIndex(of: sender)
        }
        
        checkButtons()
        print(selectedMeans ?? 0)
        
    }
    
    @IBAction func expendHandler(_ sender: UIButton) {
        
        isExpend = !isExpend
        
        if isExpend {
            attentionAspect.constant = 0
        } else {
            attentionAspect.constant = 255
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        if isExpend {
            attentionText.isHidden = false
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌃ 접기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
        } else {
            attentionText.isHidden = true
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌵ 펼치기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
        }
        
    }
    
    func checkButtons() {
        
        if selectedType == 0 {
            
            guard selectedStandard != nil else {
                btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
                btn_register.isUserInteractionEnabled = false
                return
            }
            guard selectedCharging != nil else {
                btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
                btn_register.isUserInteractionEnabled = false
                return
            }
            guard selectedMeans != nil else {
                btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
                btn_register.isUserInteractionEnabled = false
                return
            }
            
        } else {
            
            guard selectedCharging != nil else {
                btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
                btn_register.isUserInteractionEnabled = false
                return
            }
            guard selectedMeans != nil else {
                btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5)
                btn_register.isUserInteractionEnabled = false
                return
            }
            
        }
        
        btn_register.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
        btn_register.isUserInteractionEnabled = true
        print("test")
        
    }
    
    @objc func registerHandler(sender: UIButton) {
        
        if selectedType == 0 {
            if selectedStandard == 5 {
                if input_standard.text == "" {
                    alertHandler("기준 잔액을 입력해 주세요")
                    return
                }
            }
        }
        
        if selectedCharging == 5 {
            if input_charging.text == "" {
                alertHandler("충전 금액을 입력해 주세요")
                return
            }
        }
        
        if selectedType == 0 {
            let registerPop = UIStoryboard(name: "Card", bundle: nil).instantiateViewController(identifier: "AutoChargingSetAlert") as! AutoChargingSetAlert
            registerPop.modalPresentationStyle = .overFullScreen
            registerPop.strStandard = moneyArr[selectedStandard!]
            registerPop.strMoney = moneyArr[selectedCharging!]
            registerPop.strMeans = meansArr[selectedMeans!]
            
            self.present(registerPop, animated: false)
        } else {
            
            //일반 결제
//            let registerPop = UIStoryboard(name: "Card", bundle: nil).instantiateViewController(identifier: "AutoChargingCancelAlert") as! AutoChargingCancelAlert
//            registerPop.modalPresentationStyle = .overFullScreen
//
//            self.present(registerPop, animated: false)
            
            performSegue(withIdentifier: "payment", sender: self)
            
        }
        
    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "카드충전", message: str)
        
    }
    
}

extension CardCharging: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0//소숫점은 없어요
        
        if (string.first == "0" && textField.text == "") {
            return false
        } else {
            
            if let removeAllSeperator = textField.text?.replacingOccurrences(of: formatter.groupingSeparator, with: "") {
                
                let beforeFormattedString = removeAllSeperator + string
                
                if formatter.number(from: string) != nil {//누른 값이 있다면!
                    
                    if let formattedNumber = formatter.number(from: beforeFormattedString),
                       let formattedString = formatter.string(from: formattedNumber) {
                        
                        print("formattedNumber : \(formattedNumber)")
                        print("formattedString : \(formattedString)")
                        
                        textField.text = formattedString
                        return false
                    }
                } else {
                    //지운다면
                }
    
            }
            
            return true
        }
    }
    
}

extension UIView {
    
    enum VerticalLocation {
        case bottom
        case top
        case left
        case right
    }

    func addShadow(location: VerticalLocation, color: UIColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xB5B5B5), opacity: Float = 0.2, radius: CGFloat = 5.0) {
        switch location {
        case .bottom:
             addShadow(offset: CGSize(width: 0, height: 5), color: color, opacity: opacity, radius: radius)
        case .top:
            addShadow(offset: CGSize(width: 0, height: -5), color: color, opacity: opacity, radius: radius)
        case .left:
            addShadow(offset: CGSize(width: -5, height: 0), color: color, opacity: opacity, radius: radius)
        case .right:
            addShadow(offset: CGSize(width: 5, height: 0), color: color, opacity: opacity, radius: radius)
        }
    }

    func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.1, radius: CGFloat = 3.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
}
