//
//  CustomOption.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/16.
//

import UIKit

class CustomOption: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var view_shot: UIView!
    @IBOutlet var view_special: UIView!
    @IBOutlet weak var view_decaffein: UIView!
    @IBOutlet weak var view_strong: UIView!
    @IBOutlet weak var view_vanilla: UIView!
    @IBOutlet weak var view_hazel: UIView!
    @IBOutlet weak var view_caramel: UIView!
    @IBOutlet weak var view_pearl: UIView!
    @IBOutlet weak var view_coco: UIView!
    
    @IBOutlet var specialArr: [UIButton]!
    @IBOutlet var decaffeinArr: [UIButton]!
    @IBOutlet var strongArr: [UIButton]!
    @IBOutlet var pearlArr: [UIButton]!
    @IBOutlet var cocoArr: [UIButton]!
    
    @IBOutlet weak var btn_reset: UIButton!
    
    @IBOutlet weak var shot_minus: UIButton!
    @IBOutlet weak var shot_plus: UIButton!
    @IBOutlet weak var shot_label: UILabel!
    
    @IBOutlet weak var vanilla_minus: UIButton!
    @IBOutlet weak var vanilla_plus: UIButton!
    @IBOutlet weak var vanilla_label: UILabel!
    
    @IBOutlet weak var hazel_minus: UIButton!
    @IBOutlet weak var hazel_plus: UIButton!
    @IBOutlet weak var hazel_label: UILabel!
    
    @IBOutlet weak var caramel_minus: UIButton!
    @IBOutlet weak var caramel_plus: UIButton!
    @IBOutlet weak var caramel_label: UILabel!
    
    @IBOutlet weak var btnView: UIView!{
        didSet{
            btnView.layer.masksToBounds = false
            btnView.layer.shadowColor = UIColor.gray.cgColor
            btnView.layer.shadowOpacity = 0.1
            btnView.layer.shadowOffset = CGSize(width: 0, height: -2)
            btnView.layer.shadowRadius = 2
        }
    }
    
    @IBOutlet var customTotal: UILabel!
    @IBOutlet var btn_ok: UIButton!{
        didSet{
            btn_ok.layer.cornerRadius = btn_ok.frame.size.height / 2
        }
    }
    
    var add_shot: Int?
    var add_special: Int?
    var add_deffein: Int?
    var add_strong: Int?
    var add_vanilla: Int?
    var add_hazel: Int?
    var add_caramel: Int?
    var add_pearl: Int?
    var add_coco: Int?
    
    var maxOption: Int = 10
    
    var option : [String : Int] = ["shot":0, "special":0, "decaffein":0, "strong":0, "vanilla":0, "hazel":0, "caramel":0, "pearl":0, "coco":0]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
        backgroundView.alpha = 0
        
        add_shot = store.option["shot"]
        add_special = store.option["special"]
        add_deffein = store.option["decaffein"]
        add_strong = store.option["strong"]
        add_vanilla = store.option["vanilla"]
        add_hazel = store.option["hazel"]
        add_caramel = store.option["caramel"]
        add_pearl = store.option["pearl"]
        add_coco = store.option["coco"]
        
        option = store.option
        
        setView()
        setBtn()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetY.constant = 0
            self.backgroundView.alpha = 0.7
            self.view.layoutIfNeeded()
        }
        
    }
    
    func setView() {
        
        if store.dummySyrup == 0 {
            view_vanilla.isHidden = true
            view_hazel.isHidden = true
            view_caramel.isHidden = true
        } else {
            view_vanilla.isHidden = false
            view_hazel.isHidden = false
            view_caramel.isHidden = false
        }
        
        if store.dummyShot == 0 {
            view_shot.isHidden = true
        } else {
            view_shot.isHidden = false
        }
        
        if store.dummySpecial == 0 {
            view_special.isHidden = true
        } else {
            view_special.isHidden = false
        }
        
        if store.dummyDecaffeine == 0 {
            view_decaffein.isHidden = true
        } else {
            view_decaffein.isHidden = false
        }
        
        if store.dummyHard == 0 {
            view_strong.isHidden = true
        } else {
            view_strong.isHidden = false
        }
        
        if store.dummyPearl == 0 {
            view_pearl.isHidden = true
        } else {
            view_pearl.isHidden = false
        }
        
        if store.dummyNatadcoco == 0 {
            view_coco.isHidden = true
        } else {
            view_coco.isHidden = false
        }
        
    }
    
    func setBtn() {
        
        btn_reset.layer.cornerRadius = btn_reset.frame.height / 2
        
        shot_label.text = "\(add_shot!)"
        vanilla_label.text = "\(add_vanilla!)"
        hazel_label.text = "\(add_hazel!)"
        caramel_label.text = "\(add_caramel!)"
        
       setPlusMinus()
        
        for (index, item) in specialArr.enumerated() {
            
            if index == add_special {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
        for (index, item) in decaffeinArr.enumerated() {
            
            if index == add_deffein {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
        for (index, item) in strongArr.enumerated() {
            
            if index == add_strong {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
        for (index, item) in pearlArr.enumerated() {
            
            if index == add_pearl {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
        for (index, item) in cocoArr.enumerated() {
            
            if index == add_coco {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
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
    
    func setPlusMinus() {
        
        if add_shot! == 0 {
            shot_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            shot_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_shot! == 10 {
            shot_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            shot_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        if add_vanilla! == 0 {
            vanilla_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            vanilla_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_vanilla! == 10 {
            vanilla_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            vanilla_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        if add_hazel! == 0 {
            hazel_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            hazel_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_hazel! == 10 {
            hazel_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            hazel_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        if add_caramel! == 0 {
            caramel_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            caramel_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_caramel! == 10 {
            caramel_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            caramel_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
    }
    
    @IBAction func shotHandler(_ sender: UIButton) {
        
        if sender == shot_plus && add_shot! < maxOption{
            add_shot = add_shot! + 1
        }
        
        if sender == shot_minus && add_shot! > 0 {
            add_shot = add_shot! - 1
        }
        
        if add_shot == 0 {
            shot_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            shot_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_shot == maxOption {
            shot_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            shot_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        shot_label.text = "\(add_shot!)"
        option.updateValue(add_shot!, forKey: "shot")
        sumPrice()
        
    }
    
    @IBAction func vanillaHandler(_ sender: UIButton) {
        
        if sender == vanilla_plus && add_vanilla! < maxOption{
            add_vanilla = add_vanilla! + 1
        }
        
        if sender == vanilla_minus && add_vanilla! > 0 {
            add_vanilla = add_vanilla! - 1
        }
        
        if add_vanilla == 0 {
            vanilla_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            vanilla_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_vanilla == maxOption {
            vanilla_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            vanilla_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        vanilla_label.text = "\(add_vanilla!)"
        option.updateValue(add_vanilla!, forKey: "vanilla")
        sumPrice()
        
    }
    
    @IBAction func hazelHandler(_ sender: UIButton) {
        
        if sender == hazel_plus && add_hazel! < maxOption{
            add_hazel = add_hazel! + 1
        }
        
        if sender == hazel_minus && add_hazel! > 0 {
            add_hazel = add_hazel! - 1
        }
        
        if add_hazel == 0 {
            hazel_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            hazel_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_hazel == maxOption {
            hazel_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            hazel_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        hazel_label.text = "\(add_hazel!)"
        option.updateValue(add_hazel!, forKey: "hazel")
        sumPrice()
        
    }
    
    @IBAction func caramelHandler(_ sender: UIButton) {
        
        if sender == caramel_plus && add_caramel! < maxOption{
            add_caramel = add_caramel! + 1
        }
        
        if sender == caramel_minus && add_caramel! > 0 {
            add_caramel = add_caramel! - 1
        }
        
        if add_caramel == 0 {
            caramel_minus.setImage(UIImage(named: "btn_minus_g"), for: .normal)
        } else {
            caramel_minus.setImage(UIImage(named: "btn_minus_b"), for: .normal)
        }
        
        if add_caramel == maxOption {
            caramel_plus.setImage(UIImage(named: "btn_plus_g"), for: .normal)
        } else {
            caramel_plus.setImage(UIImage(named: "btn_plus_b"), for: .normal)
        }
        
        caramel_label.text = "\(add_caramel!)"
        option.updateValue(add_caramel!, forKey: "caramel")
        sumPrice()
        
    }
    
    @IBAction func specialHandler(_ sender: UIButton) {
        
        if add_special != nil{
            
            for unselectIndex in specialArr {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_special = specialArr.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_special = specialArr.firstIndex(of: sender)
        }
        
        option.updateValue(add_special!, forKey: "special")
        sumPrice()
        
    }
    
    @IBAction func decaffeinHandler(_ sender: UIButton) {
        
        if add_deffein != nil{
            
            for unselectIndex in decaffeinArr {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_deffein = decaffeinArr.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_deffein = decaffeinArr.firstIndex(of: sender)
        }
        
        option.updateValue(add_deffein!, forKey: "decaffein")
        sumPrice()
        
    }
    
    @IBAction func strongHandler(_ sender: UIButton) {
        
        if add_strong != nil{
            
            for unselectIndex in strongArr {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_strong = strongArr.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_strong = strongArr.firstIndex(of: sender)
        }
        
        option.updateValue(add_strong!, forKey: "strong")
        sumPrice()
        
    }
    
    @IBAction func pearlHandler(_ sender: UIButton) {
        
        if add_pearl != nil{
            
            for unselectIndex in pearlArr {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_pearl = pearlArr.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_pearl = pearlArr.firstIndex(of: sender)
        }
        
        option.updateValue(add_pearl!, forKey: "pearl")
        sumPrice()
        
    }
    
    @IBAction func cocoHandler(_ sender: UIButton) {
        
        if add_coco != nil{
            
            for unselectIndex in cocoArr {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_coco = cocoArr.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            add_coco = cocoArr.firstIndex(of: sender)
        }
        
        option.updateValue(add_coco!, forKey: "coco")
        sumPrice()
        
    }
    
    func sumPrice() {
        
        var priceStr: String = ""
        var optionPrice: Int = 0
        
        if option["shot"] != 0 {
            optionPrice = option["shot"]! * 500
        }
        
        if option["special"] != 0 {
            optionPrice = optionPrice + 1000
        }
        
        if option["decaffein"] != 0 {
            optionPrice = optionPrice + 300
        }
        
        if option["vanilla"] != 0 {
            optionPrice = optionPrice + option["vanilla"]! * 500
        }
        
        if option["hazel"] != 0 {
            optionPrice = optionPrice + option["hazel"]! * 500
        }
        
        if option["caramel"] != 0 {
            optionPrice = optionPrice + option["caramel"]! * 500
        }
        
        if option["pearl"] != 0 {
            optionPrice = optionPrice + 800
        }
        
        if option["coco"] != 0 {
            optionPrice = optionPrice + 500
        }
        
        priceStr = "\(optionPrice)"
        customTotal.text = currncyStr(str: priceStr)
        
    }
    
    @IBAction func resetHandler(_ sender: Any) {
        
        add_shot = 0
        add_special = 0
        add_deffein = 0
        add_strong = 0
        add_vanilla = 0
        add_hazel = 0
        add_caramel = 0
        add_pearl = 0
        add_coco = 0
        
        store.option.removeAll()
        store.option = ["shot":0, "special":0, "decaffein":0, "strong":0, "vanilla":0, "hazel":0, "caramel":0, "pearl":0, "coco":0]
        option = store.option
        sumPrice()
        
        setBtn()
        
    }
    
    @IBAction func okHandler(_ sender: UIButton) {
        
        store.option = option
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                if let tvc = self.presentingViewController as? UITabBarController {
                    if let nvc = tvc.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController {
                            self.dismiss(animated: false) {
                                pvc.viewWillAppear(false)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func closeHAndler(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                if let tvc = self.presentingViewController as? UITabBarController {
                    if let nvc = tvc.selectedViewController as? UINavigationController {
                        if let pvc = nvc.topViewController {
                            self.dismiss(animated: false) {
                                pvc.viewWillAppear(false)
                            }
                        }
                    }
                }
            }
        }
        
    }

}
