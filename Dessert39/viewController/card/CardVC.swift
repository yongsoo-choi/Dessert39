//
//  CardVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/28.
//

import UIKit

class CardVC: UIViewController {

    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var label_money: UILabel!
    @IBOutlet weak var btn_setCharge: UIButton!
    @IBOutlet weak var btn_changeDesign: UIButton!
    
    var networkUtil = NetworkUtil()
    
    var isCard: Bool = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? CardSelecteVC {
            segueVC.isFirst = isCard
        }
        
        if let segueVC = segue.destination as? CardCharging {
            if segue.identifier == "cardSetting"{
                segueVC.parentView = "cardVC"
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "39카드")
        
        if store.userCardPath != nil {
            isCard = true
        }
        
        if isCard {
            cardView.isHidden = false
            setCardView()
        } else {
            cardView.isHidden = true
            setEmptyView()
        }
        
        store.fetchResult = nil
        store.cameraImage = nil
        store.cardName = nil
        store.cardPath = nil
        store.cardNo = nil
        
    }
    
    func setEmptyView() {
        
        grayView.layer.cornerRadius = 10
        grayView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE).cgColor
        grayView.layer.borderWidth = 1.0
        
    }
    
    func setCardView() {
        
        innerView.layer.cornerRadius = 10
        innerView.layer.masksToBounds = false
        innerView.layer.shadowColor = UIColorFromRGB.colorInit(0.16, rgbValue: 0x5A5A5A).cgColor
        innerView.layer.shadowOpacity = 1.0
        innerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        innerView.layer.shadowRadius = 10
        
        cardImage.layer.cornerRadius = 5
        
        btn_setCharge.layer.cornerRadius = 5
        btn_setCharge.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
        btn_setCharge.layer.borderWidth = 1.0
        
        UIView.setAnimationsEnabled(false)
        btn_setCharge.setTitle("카드 충전 하기", for: .normal)
        btn_setCharge.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        label_money.text = "\(store.userCash!)원"
        
        btn_changeDesign.layer.cornerRadius = btn_changeDesign.frame.height / 2
        
        if let image = store.userCardPath {
         
            self.loadImage(urlString: image) { image in

                DispatchQueue.main.async {
                    self.cardImage.image = image
                }

            }
            
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

    @IBAction func cardSeletHandler(_ sender: UIButton) {
        
        performSegue(withIdentifier: "cardSelect", sender: self)
        
    }
    @IBAction func cardChargingHandler(_ sender: UIButton) {
        
        performSegue(withIdentifier: "cardSetting", sender: self)
        
    }
}
