//
//  EventDetail.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit
import WebKit

class EventDetail: UIViewController {

    @IBOutlet var webview: WKWebView!
    @IBOutlet weak var label_header: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_contents: UITextView!
    
    var networkUtil = NetworkUtil()
    var detailModel: NSDictionary?
    var imgs: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "이벤트")
        navigationController?.isNavigationBarHidden = false
        
        getViewApi()
        
    }
    
    func getViewApi() {
        
        let cmd = "get_board_view"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let part = "event"
        let idx = store.dummyBoardNo!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><PART>\(part)</PART><IDX>\(idx)</IDX></DATA>"
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
                    self.detailModel = jsonResult["boardView"] as? NSDictionary
                    
                    DispatchQueue.main.async {

                        if jsonResult["errCode"] as? String == "0000" {

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
        
        let obj = self.detailModel!
        let subject = obj["subject"] as! String
        let status = obj["event_status"] as! String
        let startDate = obj["event_start_date"] as! String
        let endDate = obj["event_end_date"] as! String
//        let date = obj["write_date"] as! String
//        let arr = date.components(separatedBy: " ")
        let content = obj["content"] as! String
        imgs = obj["imgs"] as? NSArray
        
        label_header.text = "[\(status)]"
        label_title.text = subject
        label_date.text = "\(startDate) ~ \(endDate)"
        
        var imgStr = ""
        let conStr = content.replacingOccurrences(of: "\n", with: "<br>")
        
        for i in 0..<imgs!.count {

            let obj = imgs![i] as! NSDictionary
            let imgPath = obj["imgPath"] as! String
            
            imgStr = "\(imgStr) <img src='\(imgPath)' width='100%'>"

        }
        
        let html = """
        <html>
        <style>
        @font-face
            {
                font-family: 'Pretendard';
                font-weight: normal;
                src: url(Pretendard-Regular.ttf);
            }
        </style>
        <body>
        <span style="font-size: 14pt; color: #1C1C1C; font-family: Pretendard;">\(conStr)</span>
        \(imgStr)
        </body>
        </html>
        """
        
        webview.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
        
    }
    

}
