//
//  AskList.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/01.
//

import UIKit
import SnapKit

class AskList: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var askModel: NSArray?
    
    var selectedCell: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        initRefresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        selectedCell = nil
        getListApi()
        
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
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_board_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let part = "custom"
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
                    self.askModel = jsonResult["boardList"] as? NSArray
                    
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

extension AskList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.askModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "문의 내역이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AskListCell", for: indexPath) as! AskListCell
        let obj = self.askModel![indexPath.row] as! NSDictionary
        let subject = obj["subject"] as! String
        let category = obj["category"] as! String
        let date = obj["write_date"] as! String
        let content = obj["content"] as! String
        let arr = date.components(separatedBy: " ")
        
        cell.label_askTitle.text = subject
        cell.label_askType.text = category
        cell.label_askDate.text = arr[0]
        cell.label_askContents.text = content
        
        if obj["answer_subject"] as! String == "" {
            
            UIView.setAnimationsEnabled(false)
            cell.box_answer.setTitle("답변대기", for: .normal)
            cell.box_answer.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            cell.box_answer.setTitleColor(.black, for: .normal)
            cell.box_answer.backgroundColor = .white
            
            cell.view_answer.snp.makeConstraints { (make) in
                make.height.equalTo(0)
            }
            
        } else {
            
            UIView.setAnimationsEnabled(false)
            cell.box_answer.setTitle("답변완료", for: .normal)
            cell.box_answer.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            cell.box_answer.setTitleColor(.white, for: .normal)
            cell.box_answer.backgroundColor = .black
            
            let ansContent = obj["answer_content"] as! String
            let ansDate = obj["answer_date"] as! String
            let ansArr = ansDate.components(separatedBy: " ")
            
            cell.label_answerDate.text = ansArr[0]
            cell.label_answerContents.text = ansContent
            
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCell = indexPath.row
//        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == selectedCell {
            return UITableView.automaticDimension
        }
        
        return 97
        
    }
    
}
