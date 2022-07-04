//
//  OnBoardingItem.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/13.
//

import UIKit

class OnBoardingItem: UIViewController {

    var titleImage: UIImage? = UIImage()
    var image: UIImage? = UIImage()
    var btnDisabled: Bool = true
    
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var black: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleImageView.image = titleImage
        imageView.image = image
        
        btnLogin.layer.borderWidth = 1
        btnLogin.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff).cgColor
        btnLogin.layer.isHidden = btnDisabled
        
        btnRegister.layer.borderWidth = 1
        btnRegister.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff).cgColor
        btnRegister.layer.isHidden = btnDisabled
        
        black.isHidden = btnDisabled
        
    }

    @IBAction func loginAction(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "isFirst")
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func joinAction(_ sender: Any) {
        
        store.isJoin = true
        
        UserDefaults.standard.set(true, forKey: "isFirst")
        self.dismiss(animated: true, completion: nil)

    }
    
}
