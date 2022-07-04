//
//  Review.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/30.
//

import UIKit
import SnapKit

class Review: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetY: NSLayoutConstraint!
    @IBOutlet weak var bottomSheetTop: NSLayoutConstraint!
    @IBOutlet weak var iconView: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    
    var sectionRow = [[], ["친절도", "메뉴 제조 시간", "매장 위생"]]
    let titleSection = ["주문하신 메뉴는 어떠셨나요?", "주문하신 매장은 어떠셨나요?"]
    let imageSection = ["review_menu", "review_store"]
    
    var goods: NSArray?
    var orderNo: String?
    var shopNo: String?
    
    var GOODS: String = ""
    var points: String = ""
    var kind: String?
    var time: String?
    var sanitation: String?
    
    var alert = AlertUtil()
    var networkUtil = NetworkUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bottomSheetView.layer.cornerRadius = 30
        bottomSheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomSheetY.constant = -(self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2)
        bottomSheetTop.constant = self.view.frame.size.height + (self.iconView.frame.size.height / 2)
        backgroundView.alpha = 0
        
        for item in goods! {
            
            let obj = item as! NSDictionary
            let name = obj["name"] as! String
            let no = obj["no"] as! String
            
            sectionRow[0].append(name)
            
            if GOODS == "" {
                GOODS = no
            } else {
                GOODS = "\(GOODS),\(no)"
            }
            
        }
        
        setFooter()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.bottomSheetTop.constant = 179
            self.bottomSheetY.constant = 0
            self.backgroundView.alpha = 0.7
            self.view.layoutIfNeeded()
        }
        
    }
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    func setFooter() {
        
        let footer = ReviewFooter()
        footer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 220)
        footer.btn_ok.addTarget(self, action: #selector(reviewDone(sender:)), for: .touchUpInside)

        tableView.tableFooterView = footer
        
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.view.frame.origin.y = CGFloat(-(keyboardHeight))
            
        }
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func reviewDone(sender: UIButton) {
        
        for index in 0..<sectionRow[0].count {
            
            let cell = tableView.cellForRow(at: IndexPath.init(row: index, section: 0)) as! ReviewCell
            
            if cell.selectedNum != nil{
                
                if points == "" {
                    points = String(cell.selectedNum! + 1)
                } else {
                    points = "\(points),\(String(cell.selectedNum! + 1))"
                }
                
            } else {
                points = ""
                alert.oneItem(self, title: "항목을 모두 체크해 주세요.", message: "")
                return
            }
            
        }
        
        for index in 0..<sectionRow[1].count {
            
            let cell = tableView.cellForRow(at: IndexPath.init(row: index, section: 1)) as! ReviewCell
            
            if cell.selectedNum != nil{
                
                if index == 0 {
                    kind = String(cell.selectedNum! + 1)
                }
                
                if index == 1 {
                    time = String(cell.selectedNum! + 1)
                }
                
                if index == 2 {
                    sanitation = String(cell.selectedNum! + 1)
                }
                
            } else {
                
                alert.oneItem(self, title: "항목을 모두 체크해 주세요.", message: "")
                return
                
            }
            
        }
        
        setReview()
        
    }
    
    func setReview() {
        
        let cmd = "set_grade_point"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let goods = self.GOODS
        let points = self.points
        let shopNo = self.shopNo!
        let kind = self.kind!
        let time = self.time!
        let sanitation = self.sanitation!
        let orderNo = self.orderNo!
        
        let footer = tableView.tableFooterView as! ReviewFooter
        let desc = footer.textView.text!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><GOODS>\(goods)</GOODS><POINTS>\(points)</POINTS><SHOPNO>\(shopNo)</SHOPNO><KIND>\(kind)</KIND><TIME>\(time)</TIME><SANITATION>\(sanitation)</SANITATION><DESC>\(desc)</DESC><ORDERNO>\(orderNo)</ORDERNO></DATA>"
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
                        
                        print(jsonResult["errCode"] as! String)

                        UIView.animate(withDuration: 0.25, animations: {
                            self.bottomSheetTop.constant = self.view.frame.size.height + (self.iconView.frame.size.height / 2)
                            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
                            self.backgroundView.alpha = 0
                            self.view.layoutIfNeeded()
                        }) { _ in
                            if self.presentingViewController != nil {
                                
                                if let tvc = self.presentingViewController as? UITabBarController {
                                    if let nvc = tvc.selectedViewController as? UINavigationController {
                                        if let pvc = nvc.topViewController {
                                            self.dismiss(animated: false) {
                                                
                                                let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "ReviewDone") as! ReviewDone
                                                pop.modalPresentationStyle = .overFullScreen
                                                pvc.present(pop, animated: false, completion: nil)
                                                
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    @IBAction func cancelHandler(_ sender: Any) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomSheetTop.constant = self.view.frame.size.height + (self.iconView.frame.size.height / 2)
            self.bottomSheetY.constant = -((self.bottomSheetView.frame.size.height) + (self.iconView.frame.size.height / 2))
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
        
    }

}

extension Review: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRow[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 5))
        
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 5))
        footer.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)
        returnedView.addSubview(footer)
         
        return returnedView
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView()
        returnedView.backgroundColor = .white
        
        let image = UIImageView()
        image.image = UIImage(named: self.imageSection[section])
        image.contentMode = .scaleAspectFit
        
        returnedView.addSubview(image)
        image.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
        }
        
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
        label.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
        label.textAlignment = .center
        label.text = self.titleSection[section]
        
        returnedView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.top.equalTo(image.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
        
        returnedView.addSubview(lineView)
        lineView.snp.makeConstraints { (make) in
            make.top.equalTo(label.snp.bottom).offset(30)
            make.height.equalTo(2)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            
        }

        return returnedView
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewCell
        cell.label_name.text = sectionRow[indexPath.section][indexPath.row]
        cell.selectionStyle = .none
        
        if sectionRow[indexPath.section].count - 1 == indexPath.row {
            cell.lineView.isHidden = true
        }
        
        return cell
        
    }
    
}
