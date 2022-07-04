//
//  SetDatePop.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/25.
//

import UIKit

class SetDatePop: UIViewController {

    @IBOutlet weak var warpView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var label_start: UILabel!
    @IBOutlet weak var label_end: UILabel!
    @IBOutlet weak var btn_start: UIButton!
    @IBOutlet weak var btn_end: UIButton!
    
    @IBOutlet weak var btn_cancel: UIButton!{
        didSet{
            btn_cancel.layer.cornerRadius = btn_cancel.frame.height / 2
            btn_cancel.layer.borderWidth = 1
            btn_cancel.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        }
    }
    @IBOutlet weak var btn_ok: UIButton!{
        didSet{
            btn_ok.layer.cornerRadius = btn_ok.frame.height / 2
        }
    }
    
    let datePicker = UIDatePicker()
    var isPicker: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        store.isPop = true
        setting()
    }
    
    func setting() {
        
        warpView.layer.cornerRadius = 20
        titleView.clipsToBounds = true
        titleView.layer.cornerRadius = 20
        titleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        segment.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Pretendard-Regular", size: 12)!, NSAttributedString.Key.foregroundColor :  UIColor.black], for: .normal)

        segment.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Pretendard-Regular", size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.white], for: .selected)

        segment.selectedSegmentTintColor = .black
        segment.selectedSegmentIndex = store.orderListSetDate!
        
        label_start.text = store.startDate!
        label_end.text = store.endDate!
        
        segment.addTarget(self, action: #selector(segconChanged(segcon:)), for: .valueChanged)
        
        if segment.selectedSegmentIndex == 4 {
            btn_start.isHidden = false
            btn_end.isHidden = false
        } else {
            btn_start.isHidden = true
            btn_end.isHidden = true
        }
        
    }
    
    @objc func segconChanged(segcon: UISegmentedControl) {

        switch segcon.selectedSegmentIndex {
         
        case 0:
            setDate(num: -30)
            btn_start.isHidden = true
            btn_end.isHidden = true
            break
            
        case 1:
            setDate(num: -91)
            btn_start.isHidden = true
            btn_end.isHidden = true
            break
            
        case 2:
            setDate(num: -365)
            btn_start.isHidden = true
            btn_end.isHidden = true
            break
            
        case 3:
            btn_start.isHidden = false
            btn_end.isHidden = false
            break
            
        default:
            break
            
        }
        
    }
    
    func setDate(num: Int) {
        
        var startDate: String?
        var endDate: String?
        
        let nowDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"

        endDate = dateFormatter.string(from: nowDate)
        
        let date = Calendar.current.date(byAdding: .day, value: num, to: nowDate)
        startDate = dateFormatter.string(from: date!)
        
        label_start.text = startDate
        label_end.text = endDate
        
    }
    
    @IBAction func calendarHandler(_ sender: UIButton) {
        
        isPicker = sender
        
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
        
        datePicker.setValue(UIColor.white, forKey: "backgroundColor")
        datePicker.layer.cornerRadius = 10
        datePicker.layer.masksToBounds = true
        
        var components = DateComponents()
        let minDate: Date?
        let maxDate: Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if isPicker == btn_start {
            
            let dateStr = label_start.text!
            let convertDate = dateFormatter.date(from: dateStr)
            
            datePicker.date = convertDate!
            
            components.day = 0
            let str = label_end.text!
            let date:Date = dateFormatter.date(from: str)!
            maxDate = Calendar.autoupdatingCurrent.date(byAdding: components, to: date)
            
            components.day = -365
            minDate = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
            
        } else {
            
            let dateStr = label_end.text!
            let convertDate = dateFormatter.date(from: dateStr)
            
            datePicker.date = convertDate!
            
            components.day = 0
            maxDate = Calendar.autoupdatingCurrent.date(byAdding: components, to: Date())
            
            let str = label_start.text!
            let date:Date = dateFormatter.date(from: str)!
            minDate = Calendar.autoupdatingCurrent.date(byAdding: components, to: date)
            
        }

        datePicker.maximumDate = maxDate
        datePicker.minimumDate = minDate
        
        self.view.addSubview(datePicker)
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        datePicker.layer.cornerRadius = 10
        
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if isPicker == btn_start {
            label_start.text = dateFormatter.string(from: sender.date)
        } else {
            label_end.text = dateFormatter.string(from: sender.date)
        }
        
        datePicker.removeFromSuperview()
        
    }
    
    @IBAction func cancelHandler(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func okHandler(_ sender: Any) {
        
        store.startDate = label_start.text!
        store.endDate = label_end.text!
        
        if self.presentingViewController != nil {
            if let tvc = self.presentingViewController as? UITabBarController {
                if let nvc = tvc.selectedViewController as? UINavigationController {
                    if let pvc = nvc.topViewController {
                        self.dismiss(animated: false) {
                            pvc.viewWillAppear(false)
                        }
                    }
                }
            }
        }
        
    }
}
