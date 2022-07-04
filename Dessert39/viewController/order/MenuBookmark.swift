//
//  MenuDefaultVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/09.
//

import UIKit

class MenuBookmark: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var menuListModel: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        initRefresh()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getListApi()
        setFooter()
    }
    
    func setFooter() {
        
        let foot = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        tableView.tableFooterView = foot
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.menuListModel?.count ?? 0
        
        if total == 0 {
            tableView.setEmptyView(title: "즐겨찾기한 메뉴가 없습니다.", message: "즐겨찾기에 등록하시면 편리하게 이용 가능합니다 :)", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.menuListModel![indexPath.row] as! NSDictionary
        let status = obj["status"] as! String
        store.dummyItemNo = obj["no"] as? String
        
        if status == "정상" {
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
        }
        
//        performSegue(withIdentifier: "detailSegue", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderItemCell
        let obj = self.menuListModel![indexPath.row] as! NSDictionary
        let menuName = obj["name"] as! String
        let menuNameEn = obj["eng_name"] as! String
        let status = obj["status"] as! String
        
        var menuPrice = obj["price_hot_grande"] as! String
        
        if menuPrice == "0" {
            
            menuPrice = obj["price_ice_grande"] as! String
            if menuPrice == "0" {
                
                menuPrice = obj["price_hot_venti"] as! String
                if menuPrice == "0" {
                    
                    menuPrice = obj["price_ice_venti"] as! String
                    if menuPrice == "0" {
                        
                        menuPrice = obj["price_hot_large"] as! String
                        if menuPrice == "0" {
                            
                            menuPrice = obj["price_ice_large"] as! String
                            if menuPrice == "0" {
                                
                                menuPrice = obj["price_dessert"] as! String
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        var imgPath = obj["imgHot"] as! String
        
        if imgPath == "" {
            imgPath = obj["imgIce"] as! String
        }
        
        self.loadImage(urlString: imgPath) { image in

            DispatchQueue.main.async {
                cell.item_image.image = image
            }

        }
        
        cell.item_name.text = menuName
        cell.item_anme_en.text = menuNameEn
        cell.item_price.text = "\(menuPrice)원"
        
        if status != "정상" {
            cell.soldout.isHidden = false
        } else {
            cell.soldout.isHidden = true
        }
        
        cell.selectionStyle = .none
        return cell
        
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
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_bookmark_menu"
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
                    self.menuListModel = jsonResult["goodsList"] as? NSArray
                    
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

