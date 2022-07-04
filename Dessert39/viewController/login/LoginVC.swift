//
//  LoginVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/14.
//

import UIKit
import NaverThirdPartyLogin
import Alamofire
import KakaoSDKCommon
import KakaoSDKUser
import KakaoSDKAuth
import AuthenticationServices
import SnapKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var id_input: UITextField!
    @IBOutlet weak var pw_input: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var btn_join: UIButton!
    @IBOutlet weak var btn_kakao: UIButton!
    @IBOutlet weak var btn_naver: UIButton!
    @IBOutlet var btn_apple: UIButton!
    
    @IBOutlet var icon_kakao: UIImageView!
    @IBOutlet var icon_naver: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    private let fontSize: CGFloat = 24, margin: CGFloat = 5
    private let numberOfLines: CGFloat = 2

    var networkUtil = NetworkUtil()
    var textFieldComp = TextFieldComp()
    var alertUtil = AlertUtil()
    var loginModel: LoginModel?
    var idText: String = ""
    var pwText: String = ""
    var isSns: Bool = false
    
    let naverLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? PersonalAuthVC {
            if segue.identifier == "findPwSegue"{
                segueVC.parentView = "fromFindPw"
            }
            
        }
        
        if let segueVC = segue.destination as? JoinVC {
            if segue.identifier == "joinSegue"{
                segueVC.isSns = isSns
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.numberOfLines = 2
        titleLabel.text = "오늘도 디저트39와 \n함께해요 :)"
        
        naverLoginInstance?.delegate = self
        
//        naverLoginInstance?.requestDeleteToken()
//        UserApi.shared.unlink {(error) in
//            if let error = error {
//                print(error)
//            }
//            else {
//                print("unlink() success.")
//            }
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        UserDefaults.standard.removeObject(forKey: "loginToken")
//        UserDefaults.standard.removeObject(forKey: "id")
//        UserDefaults.standard.removeObject(forKey: "name")
//        UserDefaults.standard.removeObject(forKey: "hp")
//        UserDefaults.standard.removeObject(forKey: "birth")
//        UserDefaults.standard.removeObject(forKey: "id")
//        UserDefaults.standard.removeObject(forKey: "sns")
//        UserDefaults.standard.removeObject(forKey: "email")
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "")
        
//        UserDefaults.standard.removeObject(forKey: "isFirst")
        let status = UserDefaults.standard.bool(forKey: "isFirst")

        if !status {
            let boardingVC = OnBoardingPageVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: .none)
            boardingVC.modalPresentationStyle = .fullScreen
            self.present(boardingVC, animated: false)
        }
        
        if store.isJoin {
            store.isJoin = false
            isSns = false
            self.performSegue(withIdentifier: "joinSegue", sender: self)
        }
        
        if store.isFindId {
            store.isFindId = false
            self.performSegue(withIdentifier: "findIdSegue", sender: self)
        }
        
        if store.isFindPw {
            store.isFindPw = false
            self.performSegue(withIdentifier: "findPwSegue", sender: self)
      }
        
        setInput()
        setBtn()
        
    }
    
    func setInput() {
        
        id_input.text = idText
        pw_input.text = pwText
        
        textFieldComp.setInput(tf: id_input)
        textFieldComp.setInput(tf: pw_input)
        
        id_input.addTarget(self, action: #selector(checkLoginActive(sender:)), for: .editingChanged)
        pw_input.addTarget(self, action: #selector(checkLoginActive(sender:)), for: .editingChanged)
        
    }
    
    func setBtn() {
        
        btn_login.layer.cornerRadius = btn_login.frame.height / 2
        btn_join.layer.cornerRadius = btn_join.frame.height / 2
        btn_kakao.layer.cornerRadius = btn_kakao.frame.height / 2
        btn_naver.layer.cornerRadius = btn_naver.frame.height / 2
        btn_apple.layer.cornerRadius = btn_apple.frame.height / 2
        
        btn_login.isUserInteractionEnabled = false
        btn_login.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
        btn_login.addTarget(self, action: #selector(loginHandler(sender:)), for: .touchUpInside)
        
        btn_apple.layer.borderColor = UIColor.black.cgColor
        btn_apple.layer.borderWidth = 1
        
    }
    
    @objc func checkLoginActive(sender: UITextField) {
        
        if id_input.text != "" && pw_input.text != "" {
            
            btn_login.isUserInteractionEnabled = true
            btn_login.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            
        } else {
            
            btn_login.isUserInteractionEnabled = false
            btn_login.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xd5d5d5)
            
        }
        
        idText = id_input.text ?? ""
        pwText = pw_input.text ?? ""
        
    }
    
    @objc func loginHandler(sender: UIButton) {
        
        self.view.endEditing(true)
        
        ShowLoading.loadingStart(uiView: self.view)
        
        if id_input.text == "" {
            alertHandler("아이디를 입력해 주세요")
            return
        }
        
        if pw_input.text == "" {
            alertHandler("비밀번호를 입력해 주세요")
            return
        }
        
        let cmd = "login"
        let id = id_input.text!
        let pw = pw_input.text!
        let uuid  = store.fcmToken
        let os = "ios"
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><USER_ID>\(id)</USER_ID><USER_PWD>\(pw)</USER_PWD><UUID>\(uuid)</UUID><OS>\(os)</OS></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
//        let strUrl = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        store.id = id
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            ShowLoading.loadingStop()
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    store.login = try JSONDecoder().decode(LoginModel.self, from: decrypedData)

                    DispatchQueue.main.async {
                        
                        if store.login!.errCode == "0000" {
                            
                            UserDefaults.standard.set(store.login?.strToken, forKey: "loginToken")
                            store.userCardPath = store.login!.cardImg
                            
                            if store.login!.isFirstLogin == "N" {
                                UserDefaults.standard.set(true, forKey: "isTaste")
                            } else {
                                UserDefaults.standard.set(false, forKey: "isTaste")
                            }
                            
                            Switcher.updateRootVC()
                            
//                            let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarVC")
//                            mainVC.modalPresentationStyle = .fullScreen
//                            self.present(mainVC, animated: false)
                            
                        } else {
                            self.alertUtil.oneItem(self, title: store.login!.errMsg, message: "")
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "비밀번호 재설정", message: str)
        
    }
    
    @IBAction func appleSignInButtonPress() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    
    @IBAction func naverLogin(_ sender: Any) {
        
        naverLoginInstance?.requestThirdPartyLogin()
        
    }
    
    @IBAction func kakaoLogin(_ sender: Any) {
        
        UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
            if let error = error {
                print(error)
            } else {
                print("loginWithKakaoAccount() success.")

                //do something
                _ = oauthToken
                
                self.getKakaoUserInfo()
            }
        }
        
//        ShowLoading.loadingStart(uiView: self.view)
        
    }
    
    func getKakaoUserInfo() {
        
        UserApi.shared.me() {(user, error) in
            if let error = error {
                print(error)
            } else {
                print("me() success.")

//                let cmd = "sns_login"
                let id = user?.id ?? 0
//                let id = user?.kakaoAccount?.profile?.nickname ?? ""
//                let name = user?.properties!["nickname"] ?? ""
//                let phone = user?.kakaoAccount?.phoneNumber ?? ""
//                let birthday = user?.kakaoAccount?.birthday ?? ""
//                let birthyear = user?.kakaoAccount?.birthyear ?? ""
//                let uuid  = store.fcmToken
//                let os = "ios"
                let sns = "K"
                let email = user?.kakaoAccount?.email ?? ""
                
                self.snsAuth(id: "kakao_\(id)", sns: sns, email: email)
                
//                UserApi.shared.logout {(error) in
//                    if let error = error {
//                        print(error)
//                    }
//                    else {
//                        print("logout() success.")
//
//                        self.snsAuth(id: id, sns: sns, email: email)
//                    }
//                }
               
                
//                let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id)</ID><NAME>\(name)</NAME><PHONE>\(phone)</PHONE><BIRTH>\(birthyear)\(birthday)</BIRTH><UUID>\(uuid)</UUID><OS>\(os)</OS><SNS>\(sns)</SNS><EMAIL>\(email)</EMAIL></DATA>"
//
//                let encryped: String = AES256CBC.encryptString(strCode)!
//                let urlString: String = "\(store.configUrl)?code=\(encryped)"
//                let str = urlString.replacingOccurrences(of: "+", with: "%2B")
//
//                store.id = id
//
//                self.networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
//
//                  ShowLoading.loadingStop()
//
//                  if let hasData = data {
//                      do {
//
//                          let dataStr = String(decoding: hasData, as: UTF8.self)
//                          let decryped = AES256CBC.decryptString(dataStr)!
//                          let decrypedData = decryped.data(using: .utf8)!
//
//                          store.login = try JSONDecoder().decode(LoginModel.self, from: decrypedData)
//
//                          DispatchQueue.main.async {
//
//                              if store.login!.errCode == "0000" {
//
//                                  UserDefaults.standard.set(store.login?.strToken, forKey: "loginToken")
//
//                                  UserApi.shared.logout {(error) in
//                                      if let error = error {
//                                          print(error)
//                                      }
//                                      else {
//                                          print("logout() success.")
//
//                                          let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarVC")
//                                          mainVC.modalPresentationStyle = .fullScreen
//                                          self.present(mainVC, animated: false)
//                                      }
//                                  }
//
//                              }
//
//                          }
//
//
//                      } catch {
//                          print("JSONDecoder Error : \(error)")
//                      }
//                  }
//
//              }
            
          }
                
        }
    }
    
    func snsAuth(id: String, sns: String, email: String) {
        
        let s = UserDefaults.standard.string(forKey: "sns")
       
        if s != nil && s == sns {
            
            snsLogin()
            
        } else {
            
            ShowLoading.loadingStop()
            
            store.id = id
            store.sns = sns
            store.email = email
            
            if store.id == "" {
                
                if store.email != "" {
                    let emailId = store.email!.components(separatedBy: "@")
                    store.id = emailId[0]
                }
                
            }
            
//            self.performSegue(withIdentifier: "snsSegue", sender: self)
            isSns = true
            self.performSegue(withIdentifier: "joinSegue", sender: self)
            
        }
        
    }
    
    func snsLogin() {
        
        let cmd = "sns_login"
        let id = UserDefaults.standard.string(forKey: "id")!
        let name = UserDefaults.standard.string(forKey: "name")!
        let phone = UserDefaults.standard.string(forKey: "hp")!
        let birthday = UserDefaults.standard.string(forKey: "birth")!
        let uuid  = store.fcmToken
        let os = "ios"
        let sns = UserDefaults.standard.string(forKey: "sns")!
        let email = UserDefaults.standard.string(forKey: "email")!
        let marketing = ""
        
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

                  DispatchQueue.main.async {

                      if store.login!.errCode == "0000" {

                          UserDefaults.standard.set(store.login?.strToken, forKey: "loginToken")
                          
                          if store.login!.isFirstLogin == "N" {
                              UserDefaults.standard.set(true, forKey: "isTaste")
                          } else {
                              UserDefaults.standard.set(false, forKey: "isTaste")
                          }
                          
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

extension LoginVC: NaverThirdPartyLoginConnectionDelegate {
    
    
//    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
//        //
//    }
    
    // naver login
    // 로그인에 성공한 경우 호출
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        print("Success login")
        
        guard let isValidAccessToken = naverLoginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        
              
        if !isValidAccessToken {
            return
        }
      
        guard let tokenType = naverLoginInstance?.tokenType else { return }
        guard let accessToken = naverLoginInstance?.accessToken else { return }

        ShowLoading.loadingStart(uiView: self.view)
        
        let urlStr = "https://openapi.naver.com/v1/nid/me"
        let url = URL(string: urlStr)!
      
        let authorization = "\(tokenType) \(accessToken)"
      
        let req = AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: ["Authorization": authorization])
      
        req.responseJSON { response in
            
            guard let result = response.value as? [String: Any] else { return }
            guard let object = result["response"] as? [String: Any] else { return }
          
          
//            let cmd = "sns_login"
            let id = object["id"] as? String ?? ""
//            let name = object["name"] as! String
//            let phone = object["mobile"] as? String ?? ""
//            var birthday = object["birthday"] as! String
//            birthday = birthday.components(separatedBy: ["-"]).joined()
//            let birthyear = object["birthyear"] as! String
//            let uuid  = store.fcmToken
//            let os = "ios"
            let sns = "N"
            let email = object["email"] as? String ?? ""
            
//            let id = email.components(separatedBy: "@")
            
            self.snsAuth(id: "naver_\(id)", sns: sns, email: email)
            self.naverLoginInstance?.requestDeleteToken()
            
//            let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id[0])</ID><NAME>\(name)</NAME><PHONE>\(phone)</PHONE><BIRTH>\(birthyear)\(birthday)</BIRTH><UUID>\(uuid)</UUID><OS>\(os)</OS><SNS>\(sns)</SNS><EMAIL>\(email)</EMAIL></DATA>"
//
//            let encryped: String = AES256CBC.encryptString(strCode)!
//            let urlString: String = "\(store.configUrl)?code=\(encryped)"
//            let str = urlString.replacingOccurrences(of: "+", with: "%2B")
//
//            store.id = id[0]
//
//            self.networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
//
//              ShowLoading.loadingStop()
//
//              if let hasData = data {
//                  do {
//
//                      let dataStr = String(decoding: hasData, as: UTF8.self)
//                      let decryped = AES256CBC.decryptString(dataStr)!
//                      let decrypedData = decryped.data(using: .utf8)!
//
//                      store.login = try JSONDecoder().decode(LoginModel.self, from: decrypedData)
//
//                      DispatchQueue.main.async {
//
//                          if store.login!.errCode == "0000" {
//
//                              UserDefaults.standard.set(store.login?.strToken, forKey: "loginToken")
//                              self.naverLoginInstance?.requestDeleteToken()
//
//                              let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarVC")
//                              mainVC.modalPresentationStyle = .fullScreen
//                              self.present(mainVC, animated: false)
//
//                          }
//
//                      }
//
//
//                  } catch {
//                      print("JSONDecoder Error : \(error)")
//                  }
//              }
//
//          }
        
      }
        
    }
    
    // referesh token
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        //naverLoginInstance?.accessToken
    }
    
    // 로그아웃
    func oauth20ConnectionDidFinishDeleteToken() {
        print("log out")
    }
    
    // 모든 error
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("error = \(error.localizedDescription)")
    }
    
}

@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate {
    
    // login success
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        print("AppleID Credential userID : \(appleIDCredential.user), \(String(describing: appleIDCredential.email))")
        
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let mail = appleIDCredential.email
            
        print("User ID : \(userIdentifier)")
        print("User Email : \(mail ?? "")")
        print("User Name : \((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))")
        
//        let cmd = "sns_login"
//        let id = "\(userIdentifier)"
//        let name = "\((fullName?.givenName ?? "") + (fullName?.familyName ?? ""))"
//        let phone = ""
//        let birthday = ""
//        let birthyear = ""
//        let uuid  = store.fcmToken
//        let os = "ios"
        let id = userIdentifier
        let sns = "A"
        let email = "\(mail ?? "")"
        
        self.snsAuth(id: "apple_\(id)", sns: sns, email: email)
        
//        let strCode: String = "<CMD>\(cmd)</CMD><DATA><ID>\(id)</ID><NAME>\(name)</NAME><PHONE>\(phone)</PHONE><BIRTH>\(birthyear)\(birthday)</BIRTH><UUID>\(uuid)</UUID><OS>\(os)</OS><SNS>\(sns)</SNS><EMAIL>\(email)</EMAIL></DATA>"
//
//        let encryped: String = AES256CBC.encryptString(strCode)!
//        let urlString: String = "\(store.configUrl)?code=\(encryped)"
//        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
//
//        store.id = id
//
//        self.networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
//
//          ShowLoading.loadingStop()
//
//          if let hasData = data {
//              do {
//
//                  let dataStr = String(decoding: hasData, as: UTF8.self)
//                  let decryped = AES256CBC.decryptString(dataStr)!
//                  let decrypedData = decryped.data(using: .utf8)!
//
//                  store.login = try JSONDecoder().decode(LoginModel.self, from: decrypedData)
//
//                  DispatchQueue.main.async {
//
//                      if store.login!.errCode == "0000" {
//
//                          UserDefaults.standard.set(store.login?.strToken, forKey: "loginToken")
//
//                          let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarVC")
//                          mainVC.modalPresentationStyle = .fullScreen
//                          self.present(mainVC, animated: false)
//
//                      }
//
//                  }
//
//
//              } catch {
//                  print("JSONDecoder Error : \(error)")
//              }
//          }
//
//      }
        
    }
    
    // login error
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Login Error : \(error.localizedDescription)")
    }
    
}

@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

