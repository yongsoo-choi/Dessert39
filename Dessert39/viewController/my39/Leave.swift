//
//  Leave.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/05/13.
//

import UIKit

class Leave: UIViewController {
    
    var networkUtil = NetworkUtil()
    var orderModel: NSArray?

    @IBOutlet var grayView: UIView!{
        didSet{
            grayView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet var btn_agree: UIButton!
    @IBOutlet var btn_cancel: UIButton!{
        didSet{
            btn_cancel.layer.cornerRadius = btn_cancel.frame.height / 2
            btn_cancel.layer.borderWidth = 1
            btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        }
    }
    @IBOutlet var btn_leave: UIButton!{
        didSet{
            btn_leave.layer.cornerRadius = btn_leave.frame.height / 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "회원 탈퇴")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func agreeHandler(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
    }
    
    @IBAction func cancelHandler(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func leaveHandler(_ sender: UIButton) {
        
        if !btn_agree.isSelected {
            
            AlertUtil().oneItem(self, title: "유의사항 확인 후 동의해 주세요", message: "")
            return
            
        }
        
        orderApi()
        
    }
    
    func orderApi() {
        
        let cmd = "get_order_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let status = ""
        let sdate = ""
        let edate = ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><STATUS>\(status)</STATUS><SDATE>\(sdate)</SDATE><EDATE>\(edate)</EDATE></DATA>"
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
                    self.orderModel = jsonResult["orderList"] as? NSArray
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.checkOrder()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func checkOrder() {
        
        for i in 0..<orderModel!.count {
            
            let obj = self.orderModel![i] as! NSDictionary
            let status = obj["status"] as! String
            
            if status == "주문완료" || status == "매장접수&결제대기" || status == "결제완료&매장확인중" || status == "제품준비중" || status == "제품준비완료" || status == "환불신청" {
                
                AlertUtil().oneItem(self, title: "완료하지 못한 주문건이 있습니다.", message: "")
                return
                
            }
            
        }
        
        let alert = UIAlertController(title: "탈퇴 하시겠습니까?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            
            self.leaveApi()
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func leaveApi() {
        
        let cmd = "set_mem_leave"
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
                        
                        if jsonResult["errCode"] as? String == "0000" {

//                            UserDefaults.standard.removeObject(forKey: "loginToken")
                            let domain = Bundle.main.bundleIdentifier!
                            UserDefaults.standard.removePersistentDomain(forName: domain)
                            UserDefaults.standard.synchronize()
                            Switcher.updateRootVC()

                        }

                    }

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
}
