//
//  PersonalAuthVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/19.
//

import UIKit
import WebKit

class PersonalAuthVC: UIViewController {
    
    
    @IBOutlet var backView: UIView!
    var webView: WKWebView!
    var popupView: WKWebView?
    var parentView: String?
    var urlStr: String?
    var alertUtil = AlertUtil()
    var networkUtil = NetworkUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "본인인증")
        setWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        popupView?.removeFromSuperview()
        popupView = nil
        
        if parentView == "fromJoin" || parentView == "snsSegue"  {
            urlStr = store.authRegUrl
        } else {
            urlStr = store.authPwUrl
        }
        
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
    
    func snsLogin() {
        
        let cmd = "sns_login"
        let id = store.id ?? ""
        let name = store.name ?? ""
        let phone = store.hp ?? ""
        let birthday = store.birth ?? ""
        let uuid  = store.fcmToken
        let os = "ios"
        let sns = store.sns ?? ""
        let email = store.email ?? ""
        let marketing = store.isMarketing
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id)</ID><NAME>\(name)</NAME><PHONE>\(phone)</PHONE><BIRTH>\(birthday)</BIRTH><UUID>\(uuid)</UUID><OS>\(os)</OS><SNS>\(sns)</SNS><EMAIL>\(email)</EMAIL><MARKETING>\(marketing)</MARKETING></DATA>"

        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")

        self.networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in

          ShowLoading.loadingStop()

          if let hasData = data {
              do {

                  let dataStr = String(decoding: hasData, as: UTF8.self)
                  let decryped = AES256CBC.decryptString(dataStr)!
                  let decrypedData = decryped.data(using: .utf8)!

                  store.login = try JSONDecoder().decode(LoginModel.self, from: decrypedData)
//                  print(store.login)
                  DispatchQueue.main.async {

                      if store.login!.errCode == "0000" {
                          
                          if store.login!.isFirstLogin == "N" {
                              UserDefaults.standard.set(true, forKey: "isTaste")
                          } else {
                              UserDefaults.standard.set(false, forKey: "isTaste")
                          }

                          UserDefaults.standard.set(store.login?.strToken, forKey: "loginToken")
                          UserDefaults.standard.set(store.id, forKey: "id")
                          UserDefaults.standard.set(store.name, forKey: "name")
                          UserDefaults.standard.set(store.hp, forKey: "hp")
                          UserDefaults.standard.set(store.birth, forKey: "birth")
                          UserDefaults.standard.set(store.sns, forKey: "sns")
                          UserDefaults.standard.set(store.email, forKey: "email")

                          Switcher.updateRootVC()
//                          let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarVC")
//                          mainVC.modalPresentationStyle = .fullScreen
//                          self.present(mainVC, animated: false)

                      }

                  }


              } catch {
                  print("JSONDecoder Error : \(error)")
              }
          }

      }
        
    }

}

// MARK: - WKWebview extension
extension PersonalAuthVC: WKUIDelegate, WKNavigationDelegate {
    
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
extension PersonalAuthVC: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            
        case "scriptHandler":
            
            if let dictionary: [String: String] = message.body as? Dictionary {
                
                if let exist = dictionary["exist"] {
                    
                    store.name = dictionary["name"]
                    store.birth = dictionary["birth"]
                    store.hp = dictionary["hp"]
                    store.regPart = dictionary["regPart"]
                    store.leave = dictionary["leave"]
                    
                    if store.id == "" {
                        store.id = store.name
                    }
                    
                    if exist == "1" {
                        
                        if parentView == "fromJoin" || parentView == "snsSegue" {
                            
                            if store.sns == store.regPart {
                                snsLogin()
                            } else {
                                
                                if store.leave == "" {
                                    performSegue(withIdentifier: "joined", sender: self)
                                } else {
                                    
                                    let alert = UIAlertController(title: "탈퇴한 회원 입니다.", message: "탈퇴한 회원은 7일간 재가입이 불가합니다.", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                        
                                        self.navigationController?.popViewController(animated: true)
                                        
                                    }))
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                }
                                
                            }
                            
                        } else {
                            
                            if store.regPart == "S" {
                                performSegue(withIdentifier: "passwordSegue", sender: self)
                            } else {
                                
                                var sns = ""
                                
                                if store.regPart == "K" {
                                    sns = "kakao"
                                }
                                
                                if store.regPart == "N" {
                                    sns = "naver"
                                }
                                
                                if store.regPart == "A" {
                                    sns = "apple"
                                }
                                
                                let alert = UIAlertController(title: "Use Social Login", message: "고객님은 \(sns) 로그인을 하셨습니다.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                    
                                    self.navigationController?.popViewController(animated: true)
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                        
                    } else {
                        
                        if parentView == "fromJoin" {
                            
                            performSegue(withIdentifier: "infoSegue", sender: self)
                            
                        } else if parentView == "snsSegue" {
                            
                            snsLogin()
                            
                        } else {
                            
                            let alert = UIAlertController(title: "등록된 회원이 아닙니다", message: "회원으로 등록 되어 있지 않습니다.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                
                                self.navigationController?.popViewController(animated: true)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            break
            
        default:
            break
            
        }
        
    }
    
}
