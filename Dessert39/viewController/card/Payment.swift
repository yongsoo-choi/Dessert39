//
//  Payment.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/04.
//

//
//  Payment.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/19.
//

import UIKit
import WebKit

class Payment: UIViewController {
    
    
    @IBOutlet var backView: UIView!
    var webView: WKWebView!
    var popupView: WKWebView?
    var parentView: String?
    var urlStr: String?
    var price: String?
    var orderNo: String?
    var alertUtil = AlertUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "결제하기")
        navigationController?.isNavigationBarHidden = false
        
        setWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        popupView?.removeFromSuperview()
        popupView = nil
        
        let url = store.payUrl
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        urlStr = "\(url)?token=\(token)&no=\(orderNo!)"
        
        if let url = URL(string: urlStr!) {

            let request = URLRequest(url: url)
            webView!.load(request)
            webView!.uiDelegate = self
            webView!.navigationDelegate = self

        }
    }
    
    func setWebView() {
        
        let contentController = WKUserContentController()
        // Bridge 등록
        contentController.add(self, name: "scriptHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        backView.addSubview(webView)
        
        webView.scrollView.bounces = false;
        webView.scrollView.alwaysBounceHorizontal = false;
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: backView.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: backView.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
                for cookie in cookies {
                    print("@@@ cookie ==> \(cookie.name) : \(cookie.value)")
                    if cookie.name == "PHPSESSID" {
                        UserDefaults.standard.set(cookie.value, forKey:"PHPSESSID")
                        print("@@@ PHPSESSID 저장하기: \(cookie.value)")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }

}

// MARK: - WKWebview extension
extension Payment: WKUIDelegate, WKNavigationDelegate {
    
    // 중복 reload 방지
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    //alert 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            
        let hei = (self.navigationController?.navigationBar.frame.height)! + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height)!
        popupView = WKWebView(frame: CGRect(x: 0, y: hei, width: self.view.frame.width, height: self.view.frame.height), configuration: configuration)
        popupView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupView?.uiDelegate = self
      
        self.view.addSubview(popupView!)
            
        return popupView
    }
        
    func webViewDidClose(_ webView: WKWebView) {
        if webView == popupView {
            popupView?.removeFromSuperview()
            popupView = nil
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        let loadedSessid = UserDefaults.standard.value(forKey: "PHPSESSID") as! String?
        
        if let temp = loadedSessid {
            print("@@@ PHPSESSID 저장~~: \(temp)") // 이게 정상동작하는듯.. 자동로그인 됨
            let cookieString : String = "document.cookie='PHPSESSID=\(temp);path=/;domain=\(String(describing: urlStr));'"
            webView.evaluateJavaScript(cookieString)
        }
        
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        print("@@@ decidePolicyFor navigationAction")
        guard let requestURL = navigationAction.request.url else { return }
        
        let url = requestURL.absoluteString
        let hostAddress = navigationAction.request.url?.host
        // To connnect app store
        if hostAddress == "itunes.apple.com" {
            if UIApplication.shared.canOpenURL(requestURL) {
                UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
                
            }
            
        }
        
        #if DEBUG
        print("url = \(url), host = \(hostAddress?.description ?? "")")
        #endif
        
        let url_elements = url.components(separatedBy: ":")
        
        if url_elements[0].contains("http") == false && url_elements[0].contains("https") == false {
            
            if UIApplication.shared.canOpenURL(requestURL) {
                
                UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
                
            } else {
                // 만약 Info.plist의 white list에 등록되지 않은 앱 스키마가 있는 경우를 위해 사용, 신용카드 결제화면등을 위해 필요, 해당 결제앱 스키마 호출
                if url.contains("about:blank") == true {
                    print("@@@ Browser can't be opened, about:blank !! @@@")
                    
                }else{
                    print("@@@ Browser can't be opened, but Scheme try to call !! @@@")
                    UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
                    
                }
                
            }
            decisionHandler(.cancel)
            return
            
        }
        decisionHandler(.allow)
        
    }

}

// MARK: - javascript -> app callBack
extension Payment: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            
        case "scriptHandler":
            
            if let dictionary: [String: String] = message.body as? Dictionary {
                
                if let code = dictionary["code"] {
                    
                    store.ordNo = dictionary["ordNo"]
                    
                    if code == "3001" {
                        
                        self.navigationController?.popToRootViewController(animated: true)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "결제실패", message: dictionary["msg"], preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                            
                            self.navigationController?.popToRootViewController(animated: true)
                            
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
            }
            
            break
            
        default:
            break
            
        }
        
    }
    
}
