//
//  Event.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit

class Event: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var eventModel: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset.left = 0
        
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
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "이벤트")
        navigationController?.isNavigationBarHidden = false
        
        getListApi()
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_board_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let part = "event"
        let page = ""
        let category = ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><PART>\(part)</PART><PAGE>\(page)</PAGE><CATEGORY>\(category)</CATEGORY></DATA>"
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
                    self.eventModel = jsonResult["boardList"] as? NSArray
                    
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

}


extension Event: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.eventModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "진행중인 이벤트가 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .singleLine
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.eventModel![indexPath.row] as! NSDictionary
        let idx = obj["idx"] as! String
        
        store.dummyBoardNo = idx
        performSegue(withIdentifier: "eventDetail", sender: self)
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        let obj = self.eventModel![indexPath.row] as! NSDictionary
        let subject = obj["subject"] as! String
        let status = obj["event_status"] as! String
        let startDate = obj["event_start_date"] as! String
        let endDate = obj["event_end_date"] as! String
//        let date = obj["write_date"] as! String
//        let arr = date.components(separatedBy: " ")
        
        cell.label_header.text = "[\(status)]"
        cell.label_title.text = subject
        cell.label_date.text = "\(startDate) ~ \(endDate)"
        
        if status == "종료" {
//            cell.isUserInteractionEnabled = false
            cell.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)
            cell.label_header.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x757575)
            cell.label_title.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x757575)
            cell.label_date.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
            
        } else {
            
            cell.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xFFFFFF)
            cell.label_header.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
            cell.label_title.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
            cell.label_date.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x3B3B3B)
            
        }
        
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
