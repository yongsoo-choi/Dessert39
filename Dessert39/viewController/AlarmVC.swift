//
//  AlarmVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit

class AlarmVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btn_remove: UIButton!
    @IBOutlet weak var image_empty: UIImageView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var alarmModel: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundView = image_empty
        
        initRefresh()
    }
    
    func initRefresh() {
        
        refresh.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        self.tableView.refreshControl = refresh
        
    }
     
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        print("refreshTable")
        getListApi()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "알림")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
        
        store.alarmBage = false
        tabBar.items![1].badgeValue = ""
        tabBar.items![1].badgeColor = .clear
        tabBar.items![1].setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
        
//        store.alarmBageCheck(chk: false)
        
        let settingItem = UIBarButtonItem(image: UIImage(named: "icon_setting"), style: .done, target: self, action: #selector(setAlarm(sender:)))
        settingItem.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        self.navigationItem.rightBarButtonItem = settingItem
        
        btn_remove.layer.borderWidth = 1
        btn_remove.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
        btn_remove.layer.cornerRadius = 3
        btn_remove.isHidden = true
        
        getListApi()
        
        if store.ordNo != nil {
            
            let orderPop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "OrderListDetail") as! OrderListDetail
            orderPop.orderNo = store.ordNo
            
            self.present(orderPop, animated: true)
            
        }
        
    }
    
    @objc func setAlarm(sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "alarmSetting", sender: self)
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_push_history"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let page = ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><PAGE>\(page)</PAGE></DATA>"
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
                    self.alarmModel = jsonResult["pushList"] as? NSArray
                    
                    DispatchQueue.main.async {
                        
                        if !self.refresh.isRefreshing {
                            ShowLoading.loadingStop()
                        }

                        if jsonResult["errCode"] as? String == "0000" {

                            self.tableView.reloadData()
                            self.refresh.endRefreshing()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    @objc func goPayment(sender: UIButton) {
        
        store.orderNo = String(sender.tag)
        getOrderApi()
        
    }
    
    @objc func goOrder(sender: UIButton) {
        
        guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
        tabBar.orderButton.setBackgroundImage(UIImage(named: "tb_basket"), for: .normal)
        self.tabBarController?.selectedIndex = 3
        
    }
    
    @objc func goReview(sender: UIButton) {
        
        store.goMyOrder = 1
        self.tabBarController?.selectedIndex = 2
        
    }
    
    @objc func goNotice(sender: UIButton) {
        
        store.goNotice = 1
        self.tabBarController?.selectedIndex = 2
        
    }
    
    @objc func goEvent(sender: UIButton) {
        
        store.goEvent = 1
        self.tabBarController?.selectedIndex = 2
        
    }
    
    func findOrderNo(_ str: String) -> String{
        
        let arr =  str.components(separatedBy: "]")
        let arrStr = arr[0].replacingOccurrences(of: " ", with: "")
        var orderNo: String = ""
        
        if let range0 = arrStr.range(of: "주문번호") {
            
            let endWord = arrStr[range0].endIndex
            orderNo = String(arrStr[endWord ..< arrStr.endIndex])
            
        }
        
        return orderNo
        
    }
    
    func getOrderApi() {
        
        let cmd = "get_order"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let orderno = store.orderNo!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><ORDERNO>\(orderno)</ORDERNO></DATA>"
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

                            let status = jsonResult["status"] as? String

                            if status == "결제취소" || status == "주문거절" || status == "환불신청" || status == "환불완료" {

                                AlertUtil().oneItem(self, title: "취소", message: "주문 또는 결제가 취소 되었습니다.")

                            } else {

                                if status == "매장접수&결제대기"{

                                    self.performSegue(withIdentifier: "payment", sender: self)

                                } else {

                                    AlertUtil().oneItem(self, title: "결제 완료", message: "결제가 완료된 주문 입니다.")

                                }

                            }
//                            self.performSegue(withIdentifier: "payment", sender: self)

                        }  

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

}

extension AlarmVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.alarmModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "알림이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.alarmModel![indexPath.row] as! NSDictionary
        let title = obj["title"] as! String
        let content = obj["content"] as! String
        let intPart = obj["intPart"] as! String
        
        if intPart == "3" {
            
            store.orderNo = String(Int(findOrderNo(content))!)
            getOrderApi()
            
        }
        
        if intPart == "4" || intPart == "10" {
            
            guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
            tabBar.orderButton.setBackgroundImage(UIImage(named: "tb_basket"), for: .normal)
            self.tabBarController?.selectedIndex = 3
            
        }
        
        if intPart == "8" {
            
            store.goMyOrder = 1
            self.tabBarController?.selectedIndex = 2
            
        }
        
        if intPart == "9" {
            
            if title.contains("이벤트") {
                store.goEvent = 1
                self.tabBarController?.selectedIndex = 2
            }
            
            if title.contains("공지사항") {
                store.goNotice = 1
                self.tabBarController?.selectedIndex = 2
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = self.alarmModel![indexPath.row] as! NSDictionary
        let title = obj["title"] as! String
        let content = obj["content"] as! String
        let date = obj["date"] as! String
        let intPart = obj["intPart"] as! String
        
        if intPart == "1" || intPart == "2" || intPart == "5" || intPart == "6" || intPart == "7" || intPart == "11" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmCell
            cell.label_title.text = title
            cell.label_content.text = content
            cell.label_date.text = date
            cell.image_icon.image = UIImage(named: "alarm/\(intPart)")
            
            cell.selectionStyle = .none
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmButtonCell", for: indexPath) as! AlarmButtonCell
            cell.label_title.text = title
            cell.label_content.text = content
            cell.label_date.text = date
            cell.image_icon.image = UIImage(named: "alarm/\(intPart)")
            
            UIView.setAnimationsEnabled(false)
            
            if intPart == "3" {
                cell.btn.setTitle("결제하러 가기", for: .normal)
//                cell.btn.addTarget(self, action: #selector(goPayment(sender:)), for: .touchUpInside)
//                cell.btn.tag = Int(findOrderNo(content))!
            }
            
            if intPart == "4" {
                cell.btn.setTitle("ORDER 바로가기", for: .normal)
//                cell.btn.addTarget(self, action: #selector(goOrder(sender:)), for: .touchUpInside)
            }
            
            if intPart == "8" {
                cell.btn.setTitle("리뷰 남기기", for: .normal)
//                cell.btn.addTarget(self, action: #selector(goReview(sender:)), for: .touchUpInside)
            }
            
            if intPart == "9" {
                cell.btn.setTitle("바로가기", for: .normal)
                
                if title.contains("이벤트") {
//                    cell.btn.addTarget(self, action: #selector(goEvent(sender:)), for: .touchUpInside)
                }
                
                if title.contains("공지사항") {
//                    cell.btn.addTarget(self, action: #selector(goNotice(sender:)), for: .touchUpInside)
                }
                
            }
            
            if intPart == "10" {
                cell.btn.setTitle("다시 주문하기", for: .normal)
//                cell.btn.addTarget(self, action: #selector(goOrder(sender:)), for: .touchUpInside)
            }
            
            cell.btn.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            cell.selectionStyle = .none
            return cell
            
        }
        
        
    }
    
}
