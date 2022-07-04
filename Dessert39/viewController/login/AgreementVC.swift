//
//  AgreementVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/19.
//

import UIKit
import WebKit

class AgreementVC: UIViewController {

    @IBOutlet var webview: WKWebView!
    
    var networkUtil = NetworkUtil()
    var termModel: TermModel?
    var agreeMentTag: Int?
    let arr = ["이용약관", "개인정보 수집 및 이용 동의", "메테라 코인 이용약관", "위치기반 서비스 이용약관", "개인정보처리방침"]
    let parts = ["T", "P", "V", "G", "M"]
    var results = ["TERM", "PRIVACY", "COIN", "GPS", "MARKET"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "이용약관")
        self.title = arr[agreeMentTag!]
        
        ShowLoading.loadingStart(uiView: self.view)
        loadAgreement()
        
    }
    
    func loadAgreement() {
        
        let cmd = "terms"
        let part = parts[agreeMentTag!]
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><PART>\(part)</PART></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            ShowLoading.loadingStop()
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.termModel = try JSONDecoder().decode(TermModel.self, from: decrypedData)

                    DispatchQueue.main.async { [self] in
                        
                        if self.termModel!.errCode == "0000" {
                            
                            switch self.agreeMentTag {

                            case 0:
                            self.webview.loadHTMLString((self.termModel?.TERM)!, baseURL: nil)
                                break
                            case 1:
                            self.webview.loadHTMLString((self.termModel?.PRIVACY)!, baseURL: nil)
                                break
                            case 2:
                            self.webview.loadHTMLString((self.termModel?.COIN)!, baseURL: nil)
                                break
                            case 3:
                            self.webview.loadHTMLString((self.termModel?.GPS)!, baseURL: nil)
                                break
                            case 4:
                            self.webview.loadHTMLString((self.termModel?.MARKET)!, baseURL: nil)
                                break
                            default:
                                break

                            }
                            
                            
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    func htmlToAttributedString(html: String) -> NSAttributedString? {
      
      guard let data = html.data(using: .utf8) else {
        return NSAttributedString()
      }
        
      do {
        return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
      } catch {
        return NSAttributedString()
      }
    }

}
