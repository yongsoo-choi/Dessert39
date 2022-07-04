//
//  JoinVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/18.
//

import UIKit

class JoinVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var agreeAll: UIButton!
    @IBOutlet weak var agree1: UIButton!
    @IBOutlet weak var agree2: UIButton!
    @IBOutlet weak var agree3: UIButton!
    @IBOutlet weak var agree4: UIButton!
    @IBOutlet weak var agree5: UIButton!
    @IBOutlet weak var smallText: UILabel!
    
    @IBOutlet weak var agreeSee1: UIButton!
    @IBOutlet weak var agreeSee2: UIButton!
    @IBOutlet weak var agreeSee3: UIButton!
    @IBOutlet weak var agreeSee4: UIButton!
    @IBOutlet weak var agreeSee5: UIButton!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var agreeBtns: [UIButton]?
    var isAll: Bool = false
    var isSns: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.numberOfLines = 2
        titleLabel.text = "디저트39 회원가입을 위해 \n약관에 동의해 주세요 :)"
        
        nextBtn.layer.cornerRadius = nextBtn.frame.height / 2
        nextBtn.isUserInteractionEnabled = false
        nextBtn.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "약관동의")
        
        setButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? AgreementVC {
            
            switch segue.identifier {
            case "termsSegue1":
                segueVC.agreeMentTag = 0
            case "termsSegue2":
                segueVC.agreeMentTag = 1
            case "termsSegue3":
                segueVC.agreeMentTag = 2
            case "termsSegue4":
                segueVC.agreeMentTag = 3
            case "termsSegue5":
                segueVC.agreeMentTag = 4
            default:
                break
            }
            
        }
        
        if let segueVC = segue.destination as? PersonalAuthVC {
            
            if segue.identifier == "authFromJoin"{
                
                if isSns {
                    segueVC.parentView = "snsSegue"
                } else {
                    segueVC.parentView = "fromJoin"
                }
                
            }
            
        }
        
    }
    
    func setButton() {
        
        agreeBtns = [agree1, agree2, agree3, agree4, agree5]
        
        let attributedString = NSMutableAttributedString.init(string: "보기")
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSRange.init(location: 0, length: 2))
        
        agreeSee1.setAttributedTitle(attributedString, for: .normal)
        agreeSee2.setAttributedTitle(attributedString, for: .normal)
        agreeSee3.setAttributedTitle(attributedString, for: .normal)
        agreeSee4.setAttributedTitle(attributedString, for: .normal)
        agreeSee5.setAttributedTitle(attributedString, for: .normal)
        
    }
    
    @objc func labelClicked(_ sender: Any) {
        print((sender as AnyObject).view.tag)
    }
    
    @IBAction func allAgree(_ sender: Any) {
        tapedAllAgree()
    }
    
    @IBAction func tabedAgree(_ sender: UIButton) {
        
        sender.tag += 1
        
        if sender.tag % 2 == 1 {
            // agree
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020), for: .normal)
            if sender == agreeBtns![4] {
                smallText.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
                store.isMarketing = "Y"
            }
            
            sender.setImage(UIImage(named: "agree_black"), for: .normal)
            
            var n = 0
            while n < agreeBtns!.count {
                
                if agreeBtns![n].tag % 2 == 1 {
                    
                    if n == 4 {
                        
                        isAll = true
                        agreeAll.setImage(UIImage(named: "agree_fill"), for: .normal)
                        
                    }
                    
                    if n == 3 {
                        nextBtn.isUserInteractionEnabled = true
                        nextBtn.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                    }
                    
                    n = n + 1
                    
                } else {
                    n = 10
                }
                
            }
            
        } else {
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE), for: .normal)
            if sender == agreeBtns![4] {
                smallText.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
                store.isMarketing = "N"
            }
            
            sender.setImage(UIImage(named: "agree_gray"), for: .normal)
            
            isAll = false
            agreeAll.setImage(UIImage(named: "agree"), for: .normal)
            
            var n = 0
            while n < agreeBtns!.count {
                
                if agreeBtns![n].tag % 2 == 1 {
                    n = n + 1
                } else {
                    if n != 4 {
                        nextBtn.isUserInteractionEnabled = false
                        nextBtn.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
                    }                                                      
                    
                    n = 10
                }
                
            }
            
        }
        
    }
    
    func tapedAllAgree() {
        
        isAll = !isAll
        
        if isAll {
            
            agreeAll.setImage(UIImage(named: "agree_fill"), for: .normal)
            
            store.isMarketing = "Y"
            
            for item in agreeBtns! {
                
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020), for: .normal)
                item.setImage(UIImage(named: "agree_black"), for: .normal)
                item.tag = 1
                
            }
            
            smallText.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
            
            nextBtn.isUserInteractionEnabled = true
            nextBtn.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            
        } else {
            
            agreeAll.setImage(UIImage(named: "agree"), for: .normal)
            
            store.isMarketing = "N"
            
            for item in agreeBtns! {
                
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE), for: .normal)
                item.setImage(UIImage(named: "agree_gray"), for: .normal)
                item.tag = 0
                
            }
            
            smallText.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
            
            nextBtn.isUserInteractionEnabled = false
            nextBtn.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
            
        }
        
    }
    
}
