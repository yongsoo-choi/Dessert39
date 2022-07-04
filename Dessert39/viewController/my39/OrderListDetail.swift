//
//  OrderListDetail.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/29.
//

import UIKit

class OrderListDetail: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var networkUtil = NetworkUtil()
    var jsonResult: NSDictionary?
    var goods: NSArray?
    var count: Int = 0
    
    var orderNo: String?
    var shopNo: String?
    var isExpend: Bool = true
    var num = 2
    
    var statusArr = ["주문완료", "결제완료&매장확인중", "제품준비중", "제품준비완료", "제품픽업완료"]
    
    var copyView = ActivityView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset.right = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "주문내역")
        navigationController?.isNavigationBarHidden = false
        
        getOrder()
        
    }
    
    func setHeader() {
        
        store.ordNo = nil
        
        let header = OrderListDetailHeader()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 355)
        header.btn_copyAddress.addTarget(self, action: #selector(copyAddress(sender:)), for: .touchUpInside)
        header.btn_expended.addTarget(self, action: #selector(expendAction(sender:)), for: .touchUpInside)
        
        let jr = jsonResult!
        let shopName = jr["shopName"] as! String
        let obj = goods![0] as! NSDictionary
        let name = obj["name"] as! String
        let goodsCnt = jr["goodsCnt"] as! String
        let cnt = Int(goodsCnt)! - 1
        let status = jr["status"] as! String
        
        header.label_orderNum.text = orderNo        
        header.label_store.text = shopName
        
        if cnt == 0 {
            header.label_menu.text = name
        } else {
            header.label_menu.text = "\(name) 외 \(cnt)건"
        }
        
        for(index, item) in statusArr.enumerated() {
            
            header.label_status[index].textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
            header.icon_status[index].image = UIImage(named: "icon_status")
            
            if item == status {
                header.label_status[index].textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
                header.icon_status[index].image = UIImage(named: "icon_status_cur")
            }
            
        }
        
        let footer = OrderListDetailFooter()
        footer.frame = CGRect(x: 0, y: -1, width: view.frame.size.width, height: 95)
        footer.btn_review.addTarget(self, action: #selector(goReview(sender:)), for: .touchUpInside)
        footer.btn_review.isHidden = true
        
        if status == "제품픽업완료" {
            
            footer.btn_review.isHidden = false
            
            if jsonResult!["isReview"] as? Int == 0 {
             
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                
                let startDate = formatter.date(from:(jsonResult!["orderDate"] as? String)!)!
                let endDate = Date()
                let interval = endDate.timeIntervalSince(startDate)
                let days = Int(interval / 86400)
                
                if days > 3 {
                    footer.btn_review.isEnabled = false
                    footer.btn_review.backgroundColor = .lightGray
                    footer.btn_review.setTitle("후기 작성기간이 지났습니다", for: .normal)
                } else {
                    footer.btn_review.isEnabled = true
                    footer.btn_review.backgroundColor = .black
                    footer.btn_review.setTitle("후기 작성하기 (3일 이내)", for: .normal)
                }
                
            } else {
                footer.btn_review.isEnabled = false
                footer.btn_review.backgroundColor = .lightGray
                footer.btn_review.setTitle("후기 작성 완료", for: .normal)
            }
            
        }
        
        tableView.tableHeaderView = header
        tableView.tableFooterView = footer
        
    }
    
    @objc func expendAction(sender: UIButton) {
        
        UIView.animate(withDuration: 0.2) {
            if self.isExpend {
                
                UIView.setAnimationsEnabled(false)
                sender.setTitle("⌵ 펴기", for: .normal)
                sender.layoutIfNeeded()
                UIView.setAnimationsEnabled(true)
                
                self.count = 0
            } else {
                
                UIView.setAnimationsEnabled(false)
                sender.setTitle("⌃ 접기", for: .normal)
                sender.layoutIfNeeded()
                UIView.setAnimationsEnabled(true)
                
                self.count = self.goods!.count
            }
        }
        
        isExpend = !isExpend
        tableView.reloadData()
        
    }
    
    @objc func copyAddress(sender: UIButton) {
        
        let jr = jsonResult!
        let shopAddr = jr["shopAddr"] as! String
        
        UIPasteboard.general.string = shopAddr
        AlertUtil().oneItem(self, title: "주소가 복사 되었습니다.", message: shopAddr)
//        let activityViewController = UIActivityViewController(activityItems: [store.storeAddress], applicationActivities: nil)
//        present(activityViewController, animated: true, completion: nil)
        
    }
    
    @objc func goReview(sender: UIButton) {
        
        let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "Review") as! Review
        pop.modalPresentationStyle = .overFullScreen
        
        pop.orderNo = self.orderNo
        pop.goods = self.goods
        pop.shopNo = self.shopNo
        
        self.present(pop, animated: false, completion: nil)
        
    }
    
    func currncyStr(str: String) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 0//소숫점은 없어요
        
        if (str.first == "0" && str == "") {
            return "\(str) 원"
        } else {
            
            if let formattedNumber = formatter.number(from: str),
               let formattedString = formatter.string(from: formattedNumber) {
                
                return "\(formattedString) 원"
            }
        }
        
        return "\(str) 원"
        
    }
    
    func getOrder() {
        
        let cmd = "get_order"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let orderno = orderNo!
        
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
                    
                    self.jsonResult = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    self.goods = self.jsonResult!["goodsList"] as? NSArray
                    self.count = self.goods!.count
                    self.shopNo = self.jsonResult!["shopNo"] as? String
                    
                    DispatchQueue.main.async {
                        
                        if self.jsonResult!["errCode"] as? String == "0000" {

                            self.tableView.reloadData()
                            self.setHeader()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }

}

extension OrderListDetail: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListDetailCell", for: indexPath) as! OrderListDetailCell
        let obj = self.goods![indexPath.row] as! NSDictionary
        
        let name = obj["name"] as! String
        let count = obj["count"] as! String
        let hot_ice = obj["hot_ice"] as! String
        let size = obj["size"] as! String
        let cup = obj["cup"] as! String
        let price = obj["price"] as! String
        let option = obj["option"] as! String
        let result = obj["result"] as! String
        
        let shot = obj["shot"] as! String
        let decaf = obj["decaf"] as! String
        let weak = obj["weak"] as! String
        let vanilla = obj["vanilla"] as! String
        let hazelnut = obj["hazelnut"] as! String
        let caramel = obj["caramel"] as! String
        let pearl = obj["pearl"] as! String
        let coco = obj["coco"] as! String
        
        cell.Lbael_menu.text = name
        cell.label_default.text = "\(hot_ice) | \(size) | \(cup)"
        
        if size == ""  && cup == "" {
            cell.label_default.text = ""
        }
        
        cell.label_defaultPrice.text = currncyStr(str: String(price))
        cell.label_optionPrice.text = currncyStr(str: String(option))
        cell.label_totalPrice.text = currncyStr(str: String(result))
        cell.label_cnt.text = "\(count)건"
        
        if shot == "0" && decaf == "0" && weak == "0" && vanilla == "0" && hazelnut == "0" && caramel == "0" && pearl == "0" && coco == "0" {
            cell.label_optionPrice.text = ""
            cell.label_option.text = ""
        } else {
            
            var str = ""
            
            if shot != "0" {
                
                if str == "" {
                    str = "shot +\(shot)"
                } else {
                    str = "\(str) | shot +\(shot)"
                }
                
            }
            
            if decaf != "0" {
                
                if str == "" {
                    str = "디카페인 변경"
                } else {
                    str = "\(str) | 디카페인 변경"
                }
                
            }
            
            if weak != "0" {
                
                if str == "" {
                    str = "연하게"
                } else {
                    str = "\(str) | 연하게"
                }
                
            }
            
            if vanilla != "0" {
                
                if str == "" {
                    str = "바닐라시럽 +\(vanilla)"
                } else {
                    str = "\(str) | 바닐라시럽 +\(vanilla)"
                }
                
            }
            
            if hazelnut != "0" {
                
                if str == "" {
                    str = "헤이즐럿시럽 +\(hazelnut)"
                } else {
                    str = "\(str) | 헤이즐럿시럽 +\(hazelnut)"
                }
                
            }
            
            if caramel != "0" {
                
                if str == "" {
                    str = "카라멜 +\(caramel)"
                } else {
                    str = "\(str) | 카라멜 +\(caramel)"
                }
                
            }
            
            if pearl != "0" {
                
                if str == "" {
                    str = "펄추가"
                } else {
                    str = "\(str) | 펄추가"
                }
                
            }
            
            if coco != "0" {
                
                if str == "" {
                    str = "나타드코코추가"
                } else {
                    str = "\(str) | 나타드코코추가"
                }
                
            }
            
            cell.label_option.text = str
            
        }
        
        
        if self.goods!.count - 1 == indexPath.row {
            cell.lineView.isHidden = true
        } else {
            cell.lineView.isHidden = false
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
