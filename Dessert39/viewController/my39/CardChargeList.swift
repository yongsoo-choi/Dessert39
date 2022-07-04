//
//  CardChargeList.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit

class CardChargeList: UIViewController {

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
    
    
    var selectedCountry: String?
    var countryList = ["전체", "일반충전", "자동충전", "취소/환불"]
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "카드 충전 내역")
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
        
    }
    
    func setChangeDate() {
        
        endDate = store.endDate!
        startDate = store.startDate!
        
        label_date.text = "\(startDate!) ~ \(endDate!)"
        
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
    }

    @IBAction func setDateHandler(_ sender: Any) {
        
        let pop = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "SetDatePop") as! SetDatePop
        pop.modalPresentationStyle = .overFullScreen
        self.present(pop, animated: false, completion: nil)
        
    }
    
}

extension CardChargeList: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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
        selectedCountry = countryList[row]
        textField.text = selectedCountry
    }
    
}

extension CardChargeList: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        tableView.setEmptyView(title: "", message: "카드 충전 내역이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardChargeListCell", for: indexPath) as! CardChargeListCell
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}
