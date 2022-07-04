//
//  OrderList.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/24.
//

import UIKit

class OrderList: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btn_setDate: UIButton!{
        didSet{
            btn_setDate.layer.borderWidth = 1
            btn_setDate.layer.borderColor = UIColorFromRGB.colorInit(0.5, rgbValue: 0xCFCFCF).cgColor
            btn_setDate.backgroundColor = .white
            btn_setDate.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var label_date: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var alertUtil = AlertUtil()
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var orderModel: NSArray?
    
    var selected: Int = 0
    var selectedCountry: String?
    var countryList = ["전체", "주문완료", "결제완료", "픽업완료", "결제취소", "주문거절"]
    var sendArr = ["", "0", "1", "6", "2", "8"]
    var startDate: String?
    var endDate: String?
    
    var row: Int?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let detailVC = segue.destination as? OrderListDetail else { return }
        
        let obj = self.orderModel![row!] as! NSDictionary
        let orderNo = obj["orderNo"] as! String
        detailVC.orderNo = orderNo
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        createPickerView()
        dismissPickerView()
        store.orderListSetDate = 0
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "주문내역")
        navigationController?.isNavigationBarHidden = false
        
        if !store.isPop {
            setDate()
        } else {
            store.isPop = false
            setChangeDate()
        }
        
    }
    
    func setDate() {
        
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        endDate = dateFormatter.string(from: nowDate)
        
        let date = Calendar.current.date(byAdding: .day, value: -30, to: nowDate)
        startDate = dateFormatter.string(from: date!)
        
        label_date.text = "\(startDate!) ~ \(endDate!)"
        
        store.startDate = startDate!
        store.endDate = endDate!
        
        getListApi()
        
    }
    
    func setChangeDate() {
        
        endDate = store.endDate!
        startDate = store.startDate!
        
        label_date.text = "\(startDate!) ~ \(endDate!)"
        
        getListApi()
        
    }
    
    func createPickerView() {
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        textField.inputView = pickerView
        
    }
    
    func dismissPickerView() {
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    @objc func action() {
        view.endEditing(true)
        getListApi()
    }

    @IBAction func setDateHandler(_ sender: Any) {
        
        let pop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "SetDatePop") as! SetDatePop
        pop.modalPresentationStyle = .overFullScreen
        self.present(pop, animated: false, completion: nil)
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_order_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let status = sendArr[selected]
        let sdate = store.startDate!
        let edate = store.endDate!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><STATUS>\(status)</STATUS><SDATE>\(sdate)</SDATE><EDATE>\(edate)</EDATE></DATA>"
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
                    self.orderModel = jsonResult["orderList"] as? NSArray
                    
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
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        networkUtil.request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }
    
}

extension OrderList: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = row
        selectedCountry = countryList[selected]
        textField.text = selectedCountry
    }
    
}

extension OrderList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.orderModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "주문 내역이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.orderModel![indexPath.row] as! NSDictionary
        let status = obj["status"] as! String
        let arr = ["결제취소", "주문거절", "환불신청", "환불완료", "매장 무응답 취소"]
        
        for item in arr {
            
            if status.lowercased().contains(item) {
                return
            }
            
        }
        
        row = indexPath.row
        performSegue(withIdentifier: "orderListDetail", sender: self)
        
//        if status == "주문완료" || status == "결제완료" || status == "결제완료&매장확인중" || status == "제품준비중" || status == "제품준비완료" || status == "제품픽업완료" {
//
//            row = indexPath.row
//            performSegue(withIdentifier: "orderListDetail", sender: self)
//
//        } else {
//
//            self.alertUtil.oneItem(self, title: "결제를 완료해 주세요.", message: "")
//
//        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderListCell", for: indexPath) as! OrderListCell
        let obj = self.orderModel![indexPath.row] as! NSDictionary
        let orderDate = obj["orderDate"] as! String
        let menuName = obj["menuName"] as! String
        let goodsCnt = obj["goodsCnt"] as! String
        let cnt = Int(goodsCnt)! - 1
        let shopName = obj["shopName"] as! String
        let status = obj["status"] as! String
        let menuImg = obj["menuImg"] as! String
        
        cell.label_date.text = "\(orderDate.prefix(10))"
        cell.label_store.text = shopName
        cell.label_status.text = status
        
        if cnt == 0 {
            cell.label_menu.text = menuName
        } else {
            cell.label_menu.text = "\(menuName) 외 \(cnt)건"
        }
        
        self.loadImage(urlString: menuImg) { image in

            DispatchQueue.main.async {
                cell.image_menu.image = image
            }

        }
        
        let arr = ["결제취소", "주문거절", "환불신청", "환불완료", "매장 무응답 취소"]
        cell.arrow.isHidden = false
        for item in arr {
            
            if status.lowercased().contains(item) {
                cell.arrow.isHidden = true
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
