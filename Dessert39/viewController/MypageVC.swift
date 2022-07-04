//
//  MypageVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit

class MypageVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var networkUtil = NetworkUtil()
    
    let titleRow = [
        ["내정보", "결제카드 관리", "메테라 코인", "쿠폰"],
        ["주문내역", "전자영수증"],
        ["공지사항", "자주 묻는 질문", "고객의 소리", "매장 정보", "이벤트"],
        ["이용약관 및 개인정보처리방침"],
        ["알림 설정", "로그 아웃"]
    ]
    
    let titleSection = ["회원정보", "서비스", "고객지원", "약관 및 정책", ""]
    let iconSection = ["my_member", "my_service", "my_support", "my_terms", "my_etc"]
    let segueName = [
        ["myInfo", "card", "coin", "coupon"],
//        ["orderList", "cardChargeList", "digitalReceipt"],
        ["orderList", "digitalReceipt"],
        ["notice", "qna", "userSound", "storeInfo", "event"],
        ["agreement"],
        ["setAlarm", "logout"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
//        UserDefaults.standard.removeObject(forKey: "billkeys")
//        UserDefaults.standard.removeObject(forKey: "hps")
//        UserDefaults.standard.set(["01033499687"], forKey: "hps")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "ORDER")
        navigationController?.isNavigationBarHidden = true
        
        getListApi()
        
        if store.goEvent == 1 {
            store.goEvent = 0
            performSegue(withIdentifier: "event", sender: self)
        }
        
        if store.goNotice == 1 {
            store.goNotice = 0
            performSegue(withIdentifier: "notice", sender: self)
        }
        
        if store.goMyOrder == 1 {
            store.goMyOrder = 0
            performSegue(withIdentifier: "orderList", sender: self)
        }
        
        if store.isAsk {
            store.isAsk = false
            performSegue(withIdentifier: "userSound", sender: self)
        }
        
    }
    
    func setHeader() {
        
        let header = MyHeader()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 157)
        
        if store.nick != "" {
            
            let nick: String = store.nick!
            header.label_name.text = "\(nick)님"
            
        } else if store.name != "" {
            
            let name: String = store.name!
            header.label_name.text = "\(name)님"
            
        } else {
            
            let id: String = store.nick!
           header.label_name.text = "\(id)님"
            
        }
        
        if let imgPath = store.userImg {
            
            self.loadImage(urlString: imgPath) { image in

                DispatchQueue.main.async {
                    header.image_profile.image = image
                    header.image_profile.layer.cornerRadius = 5
                }

            }
            
        }
        
//        var btnImage = UIImage()
        
        if Int(store.userReward!)! < 10 {
            header.btn_grade.setTitle(" 씨앗", for: .normal)
            header.gradeImage.image = UIImage(named: "reward/0")
//            btnImage = UIImage(named: "reward/0")!.resize(newWidth: 22)
        }
        
        if Int(store.userReward!)! > 9 {
            header.btn_grade.setTitle(" 새싹", for: .normal)
            header.gradeImage.image = UIImage(named: "reward/1")
        }
        
        if Int(store.userReward!)! > 29 {
            header.btn_grade.setTitle(" 나무", for: .normal)
            header.gradeImage.image = UIImage(named: "reward/2")
        }
        
        if Int(store.userReward!)! > 49 {
            header.btn_grade.setTitle(" 열매", for: .normal)
            header.gradeImage.image = UIImage(named: "reward/3")
        }
        
        if Int(store.userReward!)! > 99 {
            header.btn_grade.setTitle(" 지구", for: .normal)
            header.gradeImage.image = UIImage(named: "reward/4")
        }
        
//        header.btn_grade.setImage(btnImage, for: .normal)
//        header.btn_grade.setTitle(store.userLevelName, for: .normal)

        
        self.loadImage(urlString: store.userLevelName!) { image in

            DispatchQueue.main.async {
                header.btn_grade.setImage(image, for: .normal)
            }

        }
        
        header.btn_grade.addTarget(self, action: #selector(goReward(sender:)), for: .touchUpInside)
        header.btn_gradeInfo.addTarget(self, action: #selector(goGradeInfo(sender:)), for: .touchUpInside)
        
        tableView.tableHeaderView = header
        
        let footer = MyFooter()
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        tableView.tableFooterView = footer
        
    }
    
    @objc func goReward(sender: UIButton) {
        performSegue(withIdentifier: "reward", sender: self)
    }
    
    @objc func goGradeInfo(sender: UIButton) {
        performSegue(withIdentifier: "gradeInfo", sender: self)
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        networkUtil.request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }
    
    func getListApi() {
        
        let cmd = "get_reward"
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

                            store.userReward = jsonResult["userReward"] as? String
                            store.userLevelName = jsonResult["userLevelName"] as? String
                            store.userLevelImg = jsonResult["userLevelImg"] as? String

                        }
                        
                        self.getMemberApi()

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func getMemberApi() {
        
        let cmd = "get_member_info"
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

                            store.id = jsonResult["id"] as? String
                            store.name = jsonResult["name"] as? String
                            store.nick = jsonResult["nick"] as? String
                            store.userImg = jsonResult["userImg"] as? String
                            store.hp = jsonResult["hp"] as? String
                            
                        }
                        
                        self.setHeader()

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

}

extension MypageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let returnedView: UIView?
        if section == titleSection.count - 1 {
            
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0))
            
        } else {
            
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 10))
            
            let footer = UIView(frame: CGRect(x: 0, y: 5, width: view.frame.size.width, height: 5))
            footer.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)
            returnedView!.addSubview(footer)
            
        }
         
        returnedView!.backgroundColor = .white
        return returnedView
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView: UIView?
        if self.titleSection[section] == "" {
            
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0))
            
        } else {
            
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
            
            let label = UILabel(frame: CGRect(x: 20, y: 20, width: view.frame.size.width, height: 20))
            label.font = UIFont(name: "Pretendard-Bold", size: 18)
            label.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
            label.text = self.titleSection[section]
            returnedView!.addSubview(label)
            
        }

        returnedView!.backgroundColor = .white
        return returnedView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if self.titleSection[section] == "" {
            return 0
        } else {
            return 50
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == titleSection.count - 1{
            return 0
        } else {
            return 10
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleRow[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segueName[indexPath.section][indexPath.row] == "logout" {
            
            let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                
                UserDefaults.standard.removeObject(forKey: "loginToken")
                Switcher.updateRootVC()
//                let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//                let navigationController = UINavigationController(rootViewController: vc)
//
//                navigationController.modalPresentationStyle = .fullScreen
//                self.present(navigationController, animated: false)
                
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else if segueName[indexPath.section][indexPath.row] == "card" {
            
            if let hps = UserDefaults.standard.array(forKey: "hps") {
                
                for item in hps {
                    
                    if item as? String == store.hp {
                        performSegue(withIdentifier: "cardList", sender: self)
                        return
                    }
                    
                }
                
                performSegue(withIdentifier: "card", sender: self)
                
            } else {
                performSegue(withIdentifier: "card", sender: self)
            }
            
            
//            if UserDefaults.standard.array(forKey: "billkeys") != nil {
//                performSegue(withIdentifier: "cardList", sender: self)
//            } else {
//                performSegue(withIdentifier: "card", sender: self)
//            }
            
        } else {
            performSegue(withIdentifier: segueName[indexPath.section][indexPath.row], sender: self)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "My39Cell", for: indexPath) as! My39Cell
        
        cell.icon.image = UIImage(named: "\(self.iconSection[indexPath.section])/\(indexPath.row)")
        cell.title.text = titleRow[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}
