//
//  AskDone.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/02.
//

import UIKit

class AskDone: UIViewController {

    @IBOutlet weak var warpView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!{
        didSet{
            btn_cancel.layer.borderColor = UIColor.black.cgColor
            btn_cancel.layer.borderWidth = 1
        }
    }
    
    var networkUtil = NetworkUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setting()
    }
    
    func setting() {
        
        warpView.layer.cornerRadius = 20
        titleView.clipsToBounds = true
        titleView.layer.cornerRadius = 20
        titleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        btn_ok.layer.cornerRadius = btn_ok.frame.height / 2
        btn_cancel.layer.cornerRadius = btn_cancel.frame.height / 2
        
    }
    
    @IBAction func okHandler(_ sender: UIButton) {
        
        let cmd = "set_board"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let part = "custom"
        let subject = store.askTitle!
        let content = store.askContents!
        let category = store.askType!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><PART>\(part)</PART><SUBJECT>\(subject)</SUBJECT><CONTENT>\(content)</CONTENT><CATEGORY>\(category)</CATEGORY></DATA>"
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
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.dismissHandler()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

    @IBAction func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func dismissHandler() {
        
        if self.presentingViewController != nil {
            
            if let tvc = self.presentingViewController as? UITabBarController {
                if let nvc = tvc.selectedViewController as? UINavigationController {
                    if let pvc = nvc.topViewController {
                        self.dismiss(animated: false) {
                            pvc.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            }
            
        }
        
    }
}
