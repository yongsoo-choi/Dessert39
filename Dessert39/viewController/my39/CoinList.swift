//
//  CoinList.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/13.
//

import UIKit

class CoinList: UIViewController {
    
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
    var countryList = ["전체", "송금받기", "송금하기", "코인결제"]
    var sendArr = ["", "2", "1", "0"]
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
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "메테라 코인 이용내역")
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
        
        let cmd = "get_coin_history"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let status = sendArr[selected]
        let sdate = store.startDate!
        let edate = store.endDate!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><PART>\(status)</PART><SDATE>\(sdate)</SDATE><EDATE>\(edate)</EDATE></DATA>"
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
                    self.orderModel = jsonResult["coinHistory"] as? NSArray
                    
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

extension CoinList: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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

extension CoinList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.orderModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "코인 이용 내역이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinListCell", for: indexPath) as! CoinListCell
        let obj = self.orderModel![indexPath.row] as! NSDictionary
        let modDate = obj["modDate"] as! String
        let strPart = obj["strPart"] as! String // 디저트39결제, 송금, 입금
        let strStatus = obj["strStatus"] as! String // pendig, complete, cancel
        let amout = obj["amout"] as! String
        let fee = obj["fee"] as! String
        let strFee = String(Double(fee)! / store.metr)

        cell.label_date.text = modDate
        cell.label_coin.text = String(Double(amout)! / store.metr)
        cell.label_title.text = strPart
        cell.label_fee.text = "(수수료 \(strFee) METR)"
        
        if strPart == "입금" {
            
            cell.label_type.text = "+"
            cell.label_type.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1)
            
            cell.image_type.image = UIImage(named: "coin_recive")
            
        } else {
            
            cell.label_type.text = "-"
            cell.label_type.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xB80F0F)
            
            if strPart == "송금" {
                cell.image_type.image = UIImage(named: "coin_send")
            } else {
                cell.image_type.image = UIImage(named: "coin_used")
            }
            
            if strStatus == "cancel" {
                cell.label_type.text = "+"
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
