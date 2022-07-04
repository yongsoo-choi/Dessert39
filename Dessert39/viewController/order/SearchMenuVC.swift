//
//  SearchMenuVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/15.
//

import UIKit

class SearchMenuVC: UIViewController {

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var resultText: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var menuListModel: Array<NSDictionary> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "메뉴 검색")
        
//        let settingItem = UIBarButtonItem(image: UIImage(named: "close"), style: .done, target: self, action: #selector(setClose(sender:)))
//        settingItem.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
//        self.navigationItem.rightBarButtonItem = settingItem
        
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowRadius = 2
        
        searchBar.text = ""
        resultText.text = "⌵ 검색결과"
        
        setFooter()
        
    }
    
    func setFooter() {
        
        let foot = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        tableView.tableFooterView = foot
        
    }

    
    @objc func setClose(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func touchSearchIcon(_ sender: Any) {
        
        self.view.endEditing(true)
        searchApi()
        
    }
    
    func searchApi() {
        
        if searchBar.text != "" {
            getListApi()
        }
        
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
        
        let cmd = "get_goods_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let cate = ""
        let cate2 = ""
        let name = searchBar.text!
        let shopNo = store.storeNo ?? ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><CATE>\(cate)</CATE><CATE2>\(cate2)</CATE2><NAME>\(name)</NAME><SHOPNO>\(shopNo)</SHOPNO></DATA>"
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
                    self.menuListModel = (jsonResult["goodsList"] as? Array)!
                    
                    DispatchQueue.main.async {
                        
                        if !self.refresh.isRefreshing {
                            ShowLoading.loadingStop()
                        }

                        if jsonResult["errCode"] as? String == "0000" {
                            
                            self.setModel()
//                            self.tableView.reloadData()
                            self.refresh.endRefreshing()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setModel() {
        
        for (index,item) in menuListModel.enumerated() {
            
            let obj = item
            let hotGrande = obj["price_hot_grande"] as! String
            let hotVenti = obj["price_hot_venti"] as! String
            let hotLarge = obj["price_hot_large"] as! String
            let iceGrande = obj["price_ice_grande"] as! String
            let iceVenti = obj["price_ice_venti"] as! String
            let iceLarge = obj["price_ice_large"] as! String
            let dessert = obj["price_dessert"] as! String
            
            let arr = [hotGrande, hotVenti, hotLarge, iceGrande, iceVenti, iceLarge, dessert]
            
            var i = 0
            for item in arr {
                
                if item != "0" {
                    break
                }
                
                i += 1
                
            }
            
            if i == 7 {
                menuListModel.remove(at: index)
                setModel()
                break
            }
            
        }
        
        self.tableView.reloadData()

    }

}

extension SearchMenuVC: UITextFieldDelegate {
    
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      searchApi()
    return true
  }
    
}

extension SearchMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.menuListModel.count
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "", imageStr: "empty_menu", imageW: 120, imageH: 153)
            resultText.text = "⌵ 검색결과"
        } else {
            let result = searchBar.text!
            resultText.text = "⌵ \(result)에 대한 검색결과가 \(total)건 있습니다."
            
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.menuListModel[indexPath.row]
        let status = obj["status"] as! String
        store.dummyItemNo = obj["no"] as? String
        
        if status == "정상" {
            performSegue(withIdentifier: "detailSegue", sender: self)
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderItemCell
        let obj = self.menuListModel[indexPath.row]
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
        
        if menuPrice == "" {
            menuPrice = obj["price_ice_grande"] as! String
        }
        
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

}

