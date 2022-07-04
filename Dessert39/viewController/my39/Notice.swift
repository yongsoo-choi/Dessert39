//
//  Notice.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit

class Notice: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var noticeModel: NSArray?
    
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
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "공지사항")
        navigationController?.isNavigationBarHidden = false
        
        getListApi()
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_board_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let part = "notice"
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
                    self.noticeModel = jsonResult["boardList"] as? NSArray
                    
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


extension Notice: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let total = self.noticeModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "공지사항이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .singleLine
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        store.dummyBoard = self.noticeModel![indexPath.row] as? NSDictionary
        performSegue(withIdentifier: "noticeDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath) as! NoticeCell
        let obj = self.noticeModel![indexPath.row] as! NSDictionary
        let subject = obj["subject"] as! String
        let date = obj["write_date"] as! String
        let arr = date.components(separatedBy: " ")
        
        cell.label_urgency.text = ""
        cell.lable_title.text = subject
        cell.label_date.text = arr[0]
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
