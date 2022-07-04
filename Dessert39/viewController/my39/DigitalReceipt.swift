//
//  DigitalReceipt.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit

class DigitalReceipt: UIViewController {

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
    
    
    var selected: Int = 0
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var recepiModel: NSArray?
    var selectedCountry: String?
//    var countryList = ["전체", "충전", "결제", "취소"]
//    var sendArr = ["", "0", "1", "2"]
    var countryList = ["전체", "결제", "취소"]
    var sendArr = ["", "1", "2"]
    var startDate: String?
    var endDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        createPickerView()
        dismissPickerView()
        store.orderListSetDate = 0
        
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
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "전자영수증")
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
        
        let cmd = "get_receipt_list"
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
                    self.recepiModel = jsonResult["receiptList"] as? NSArray
                    
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
    
}

extension DigitalReceipt: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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

extension DigitalReceipt: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.recepiModel?.count ?? 0
        
        if total == 0 {
            tableView.setEmptyView(title: "", message: "영수증 내역이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .singleLine
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let receiptNav = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "ReceiptNavigation")
        let obj = self.recepiModel![indexPath.row] as! NSDictionary
        let orderNo = obj["orderNo"] as! String
        let strType = obj["strType"] as! String
        
        if strType != "* 결제취소 *" {
            store.receiptNo = orderNo
            self.present(receiptNav, animated: true)
        } else {
            AlertUtil().oneItem(self, title: "취소된 주문건입니다.", message: "")
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DigitalReceiptCell", for: indexPath) as! DigitalReceiptCell
        let obj = self.recepiModel![indexPath.row] as! NSDictionary
        let storeName = obj["storeName"] as! String
        let orderDate = obj["orderDate"] as! String
        let orderTotalPrice = obj["orderTotalPrice"] as! String
        let strType = obj["strType"] as! String
        
        cell.label_name.text = storeName
        cell.label_date.text = "\(orderDate.prefix(10)) | \(strType)"
        cell.label_price.text = currncyStr(str: orderTotalPrice)
        
//        if strType != "* 결제취소 *" {
//            cell.arrow.isHidden = false
//        } else {
//            cell.arrow.isHidden = true
//        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}

