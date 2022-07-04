//
//  AlarmSetVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/03.
//

import UIKit

class AlarmSetVC: UIViewController {

    @IBOutlet weak var toggle_event: UISwitch!
    @IBOutlet weak var toggle_review: UISwitch!
    
    var networkUtil = NetworkUtil()
    var jsonResult: NSDictionary?
    var setAlarmModel: ApiDefaultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "환경설정")
        navigationController?.isNavigationBarHidden = false
     
        getAlarm()
        
    }
    
    func getAlarm() {
        
        let cmd = "get_user_config"
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
                    
                    self.jsonResult = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if self.jsonResult!["errCode"] as? String == "0000" {

                            self.setSwitch()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setSwitch() {
        
        let evt = jsonResult!["event"] as! Int
        let review = jsonResult!["review"] as! Int
        
        if evt == 0 {
            toggle_event.isOn = false
            toggle_event.thumbTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xc9c9c9)
            toggle_event.onTintColor = UIColorFromRGB.colorInit(0.1, rgbValue: 0xE1E1E1)
        } else {
            toggle_event.isOn = true
            toggle_event.thumbTintColor = .black
            toggle_event.onTintColor = UIColorFromRGB.colorInit(0.2, rgbValue: 0x1C1C1C)
        }
        
        if review == 0 {
            toggle_review.isOn = false
            toggle_review.thumbTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xc9c9c9)
            toggle_review.onTintColor = UIColorFromRGB.colorInit(0.1, rgbValue: 0xE1E1E1)
        } else {
            toggle_review.isOn = true
            toggle_review.thumbTintColor = .black
            toggle_review.onTintColor = UIColorFromRGB.colorInit(0.2, rgbValue: 0x1C1C1C)
        }
        
        toggle_event.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        toggle_review.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        toggle_event.addTarget(self, action: #selector(onClickSwitch(sender:)), for: .valueChanged)
        toggle_review.addTarget(self, action: #selector(onClickSwitch(sender:)), for: .valueChanged)
        
    }
    
    @objc func onClickSwitch(sender: UISwitch) {
        
        if sender.isOn {
            sender.thumbTintColor = .black
            sender.onTintColor = UIColorFromRGB.colorInit(0.2, rgbValue: 0x1C1C1C)
        } else {
            sender.thumbTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xc9c9c9)
            sender.onTintColor = UIColorFromRGB.colorInit(0.1, rgbValue: 0xE1E1E1)
        }
        
        setAlarm()
        
    }
    
    func setAlarm() {
        
        let cmd = "set_user_config"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let event = toggle_event.isOn ? "1" : "0"
        let review = toggle_review.isOn ? "1" : "0"
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><EVENT>\(event)</EVENT><REVIEW>\(review)</REVIEW></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.setAlarmModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)

                    DispatchQueue.main.async {

                        print(self.setAlarmModel!.errCode)

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

}
