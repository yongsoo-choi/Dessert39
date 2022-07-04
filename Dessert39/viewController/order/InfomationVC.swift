//
//  InfomationVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/09.
//

import UIKit

class InfomationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var tempType: [UIButton]!
    @IBOutlet weak var btn_hot: UIButton!
    @IBOutlet weak var btn_iced: UIButton!
    @IBOutlet weak var btn_bookmark: UIButton!
    
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_name_en: UILabel!
    @IBOutlet weak var label_info: UILabel!
    @IBOutlet weak var label_price: UILabel!
    @IBOutlet weak var label_allergy: UILabel!
    @IBOutlet var nutriView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var nutriHei: NSLayoutConstraint!
    @IBOutlet var allergyView: UIView!
    
    
    var networkUtil = NetworkUtil()
    var bookmarkModel: ApiDefaultModel?
    
    var selectedTemp: Int?
    var dessertPrice: String?
    var nutriArr: NSArray?
    
    var name_ko: String = ""
    var name_en: String = ""
    var value: String = ""
    var price: String = ""
    var allergy: [String] = []
    var bookmark: String = "0"
    var menuNo: String = ""
    var imgPath: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xE6E6E6).cgColor
        imageView.layer.borderWidth = 1
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "메뉴 정보")
        navigationController?.isNavigationBarHidden = false
        
//        selectedTemp = 1
        setBtn()
        setString()
    }
    
    func setString() {
//        nutriArr = [["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"],["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"], ["title" : "test", "value" : "test"]]
        label_name.text = name_ko
        label_name_en.text = name_en
        label_info.text = value
        label_price.text = price
        
        var str: String = ""
        for item in allergy {
            
            if str == "" {
                str = item
            } else {
                str = "\(str), \(item)"
            }
            
        }
        
        if str == "" {
            allergyView.isHidden = true
        } else {
            allergyView.isHidden = false
        }
        
        label_allergy.text = str
        
        if bookmark != "0" {
            btn_bookmark.isSelected = true
        } else {
            btn_bookmark.isSelected = false
        }
        
        self.loadImage(urlString: imgPath) { image in

            DispatchQueue.main.async {
                self.imageView.image = image
            }

        }
        
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
    
    @IBAction func tapBookmark(_ sender: UIButton) {
        
        sender.isSelected.toggle()
        
        let cmd = "set_bookmark_menu"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let no = menuNo
        var part: String = ""
        
        if sender.isSelected {
            part = "A"
        } else {
            part = "D"
        }
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NO>\(no)</NO><PART>\(part)</PART></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.bookmarkModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)

                    DispatchQueue.main.async {

                        print(self.bookmarkModel!.errCode)

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setBtn() {
        
        if dessertPrice != "0" {
         
            for (_, item) in tempType.enumerated() {
                
                item.isHidden = true
                 
            }
            
        } else {
         
            for (index, item) in tempType.enumerated() {
                
                if selectedTemp != nil {
                    
                    if index == selectedTemp {
                        
                        if index == 0 {
                            item.layer.borderWidth = 2
                            item.layer.cornerRadius = item.frame.height / 2
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F), for: .normal)
                            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F).cgColor
                            item.isHidden = false
                            btn_iced.isHidden = true
                        }
                        
                        if index == 1 {
                            item.layer.borderWidth = 2
                            item.layer.cornerRadius = item.frame.height / 2
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1), for: .normal)
                            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1).cgColor
                            item.isHidden = false
                            btn_hot.isHidden = true
                        }
                        
                    } else {
                        item.layer.borderWidth = 2
                        item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                        item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                        item.layer.cornerRadius = item.frame.height / 2
                        item.isHidden = true
                    }
                    
                } else {
                    item.layer.borderWidth = 2
                    item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                    item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                    item.layer.cornerRadius = item.frame.height / 2
                }
                
            }
            
        }
        
    }
    
    func setNutriView() {
        
        if nutriArr!.count == 0 {
            
            nutriHei.constant = 0
            
        } else {
            
            nutriHei.constant = CGFloat(45 + (40 * nutriArr!.count))
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var total = 0
        
        if self.nutriArr != nil {
            total  = self.nutriArr!.count
        }
        
        setNutriView()
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "nutriCell", for: indexPath) as! nutriCell
        let obj = self.nutriArr![indexPath.row] as! NSDictionary
        let title = obj["title"] as! String
        let value = obj["value"] as! String
        
        cell.label_title.text = title
        cell.label_value.text = value
        
        cell.selectionStyle = .none
        return cell
        
    }

}
