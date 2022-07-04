//
//  CardList.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/05.
//

import UIKit

class CardList: UIViewController {

    var billkeys = [Any]()
    var accessToken: String?
    let accessParams = [
        "password" : store.reappayPW,
        "userId" : store.reappayID
    ]
    var strIndex: String?
    var strBillkey: String?
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        if let hps = UserDefaults.standard.array(forKey: "hps") {
            
            for (index, item) in hps.enumerated() {
                
                if item as? String == store.hp {
                    strIndex = String(index)
                }
                
            }
            
            if strIndex != nil {
                strBillkey = "billkeys" + strIndex!
            } else {
                strBillkey = "billkeys\(hps.count)"
            }
            
            billkeys = UserDefaults.standard.array(forKey: strBillkey!)!
            
        }
        
//        billkeys = UserDefaults.standard.array(forKey: "billkeys")!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "결제카드 관리")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    @objc func deleteHandler(sender: UIButton) {
        
        let alert = UIAlertController(title: "선택하신 카드를 삭제하시겠습니까?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in

            ShowLoading.loadingStart(uiView: self.view)
            self.getAccessToken(ind: sender.tag)

        }))

        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getAccessToken(ind: Int) {
        
        let url = URL(string: "\(store.reappayUrl)auth/login")
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        let jsonData = try? JSONSerialization.data(withJSONObject: accessParams)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            if data != nil{
                do{
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    if jsonResult["status"] as! Int == 200 {
                        
                        let result:NSDictionary? = jsonResult["content"] as? NSDictionary
                        
                        self.accessToken = result!["access_token"] as? String
                        
                        DispatchQueue.main.sync {
                            
                            self.deleteCard(ind: ind)
                            
                        }
                        
                    }
                    
                } catch {
                    print("RequestError : \(error)")
                }

            }

        }

        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    func deleteCard(ind: Int) {
        
        let obj = self.billkeys[ind] as? NSDictionary
        let billingToken = obj!["billkeybillingToken"] as! String
    
        let params = [
            "billingToken": billingToken
        ]
        
        let url = URL(string: "\(store.reappayUrl)pay/billkeycancel")
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url!)
        let jsonData = try? JSONSerialization.data(withJSONObject: params)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest) {(data, response, error) in
            
            if data != nil{
                do{
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    if jsonResult["status"] as! Int == 200 {

                        DispatchQueue.main.sync {
                         
                            ShowLoading.loadingStop()
                            self.billkeys.remove(at: ind)
                            UserDefaults.standard.set(self.billkeys, forKey: self.strBillkey!)
                            self.tableView.reloadData()
                            
                            if self.billkeys.count == 0 {
                                
                                if var hps = UserDefaults.standard.array(forKey: "hps") {
                                    
                                    if self.strIndex != nil {
                                        hps.remove(at: Int(self.strIndex!)!)
                                        UserDefaults.standard.set(hps, forKey: "hps")
                                    } else {
                                        UserDefaults.standard.removeObject(forKey: "hps")
                                    }

                                }
                                
                                UserDefaults.standard.removeObject(forKey: self.strBillkey!)
                                
                                let alert = UIAlertController(title: "등록된 카드가 없습니다", message: "", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in

                                    self.navigationController?.popToRootViewController(animated: true)

                                }))

                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }

                    } else {
                        
                        //
                        
                    }
                    
                } catch {
                    print("RequestError : \(error)")
                }

            }

        }

        task.resume()
        session.finishTasksAndInvalidate()
        
    }
    
    @objc func cardRegist(sender: UIButton) {
        
        performSegue(withIdentifier: "regist", sender: self)
        
    }

}

extension CardList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return billkeys.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as! CardListCell
        let obj = self.billkeys[indexPath.row] as? NSDictionary
        let cardName = obj!["billkeyissuerCardName"] as! String
        let cardNumber = obj!["billkeymaskedCardNumb"] as! String
        
        cell.label_name.text = cardName
        cell.label_num.text = cardNumber
        cell.btn_delete.tag = indexPath.row
        cell.btn_delete.addTarget(self, action: #selector(deleteHandler(sender:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           
        let icon = UIImageView()
        icon.image = UIImage(named: "icon_store_section")
        icon.frame = CGRect(x: 20, y: 18, width: 10, height: 15)
        
        let btn = UIButton()
        btn.frame = CGRect(x: 20, y: 20, width: tableView.frame.size.width - 40, height: 75)
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE).cgColor
        btn.layer.cornerRadius = 10
        btn.setImage(UIImage(named: "add_card"), for: .normal)
        btn.addTarget(self, action: #selector(cardRegist(sender:)), for: .touchUpInside)
        
        let footerView = UIView()
        footerView.backgroundColor = .white
        
        if billkeys.count < 10 {
            footerView.addSubview(btn)
        }

        return footerView
    }
    
}
