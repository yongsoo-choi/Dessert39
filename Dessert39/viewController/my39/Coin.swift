//
//  Coin.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/11.
//

import UIKit

class Coin: UIViewController {

    @IBOutlet var boxView: UIView!{
        didSet{
            boxView.layer.cornerRadius = 5
            boxView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            boxView.layer.borderWidth = 1
        }
    }
    @IBOutlet var label_marketPrice: UILabel!
    @IBOutlet var label_amount: UILabel!
    @IBOutlet var btn_re: UIButton!
    
    var networkUtil = NetworkUtil()
    var addr: String?
    var amount: String?
    var marketPrice: String?
    var isOn: Bool = false
    
    @IBOutlet var btn_recive: UIButton!
    @IBOutlet var btnView: UIView!{
        didSet{
            btnView.layer.borderWidth = 1
            btnView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btnView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var addBox: UIView!{
        didSet{
            addBox.layer.cornerRadius = 10
            addBox.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE).cgColor
            addBox.layer.borderWidth = 1.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "coinsend" {
            guard let vc = segue.destination as? CoinSend else { return }
            
            vc.metr = label_amount.text!
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "메테라 코인")
        navigationController?.isNavigationBarHidden = false
        
        getListApi()
        btn_recive.addTarget(self, action: #selector(reciveHandler(sender:)), for: .touchUpInside)
        
    }
    
    @IBAction func refrash(_ sender: Any) {
        
        self.getListApi()
        
    }
    
    func currncyStr(str: String) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0//소숫점은 없어요
        
        if (str.first == "0" && str == "") {
            return "\(str)원"
        } else {
            
            if let formattedNumber = formatter.number(from: str),
               let formattedString = formatter.string(from: formattedNumber) {
                
                return "\(formattedString)원"
            }
        }
        
        return "\(str)원"
        
    }
    
    func getListApi() {
        
        let cmd = "get_metera_coin_info"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    print(jsonResult)
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.addr = jsonResult["coinWalletAddr"] as? String
                            self.amount = jsonResult["coinWalletAmount"] as? String
                            self.marketPrice = jsonResult["coinMarketPrice"] as? String
                            
                            self.setting()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setting() {
        
        if addr == "" {
            
            addBox.isHidden = false
            
        } else {
            
            addBox.isHidden = true
            
            let strAmount = self.amount ?? "0"
            let mp = currncyStr(str: marketPrice!)
            let amo = String(Double(strAmount)! / store.metr)
            
            label_marketPrice.text = "1METR[\(mp)]"
            label_amount.text = amo
            
            if isOn {
                
                isOn = false
                
                let pop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "Qrpop") as! Qrpop
                pop.modalPresentationStyle = .overFullScreen
                pop.coinWalletAddr = self.addr
                pop.isOn = true

                self.present(pop, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    @objc func reciveHandler(sender: UIButton) {
        
        let pop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "Qrpop") as! Qrpop
        pop.modalPresentationStyle = .overFullScreen
        pop.coinWalletAddr = self.addr
        pop.isOn = false

        self.present(pop, animated: false, completion: nil)
        
    }
    
    @IBAction func addWallet(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "생성", message: "메테라 코인 지갑을 생성 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            
            self.creatWallet()
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func creatWallet() {
        
        let cmd = "create_coin_wallet"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        self.addr = jsonResult["coinWalletAddr"] as? String
                        self.amount = jsonResult["coinWalletAmount"] as? String
                        self.marketPrice = jsonResult["coinMarketPrice"] as? String
                        
                        self.isOn = true
                        self.setting()

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
}
