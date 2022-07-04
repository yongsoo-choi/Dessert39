//
//  NoticeDetail.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit
import WebKit

class NoticeDetail: UIViewController {
    
    @IBOutlet var webview: WKWebView!
    
    @IBOutlet weak var label_urgency: UILabel!{
        didSet{
            label_urgency.isHidden = true
        }
    }
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_contents: UITextView!
    
    var imgs: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "공지사항")
        navigationController?.isNavigationBarHidden = false
        
        setting()
    }
    
    func setting() {
        
        let subject = store.dummyBoard!["subject"] as! String
        let date = store.dummyBoard!["write_date"] as! String
        let arr = date.components(separatedBy: " ")
        let content = store.dummyBoard!["content"] as! String
        imgs = store.dummyBoard!["imgs"] as? NSArray
        
        label_urgency.text = ""
        label_title.text = subject
        label_date.text = arr[0]
        
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
    
//    func htmlToAttributedString(html: String) -> NSAttributedString? {
//
//        guard let data = html.data(using: .utf8) else { return NSAttributedString() }
//
//        do {
//            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
//        } catch {
//            return NSAttributedString()
//        }
//
//    }

}
