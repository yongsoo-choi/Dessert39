//
//  DetailVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/08.
//

import UIKit

class DetailVC: UIViewController {

    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var btn_bookmark: UIButton!
    @IBOutlet weak var btn_info: UIButton!
    
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_name_en: UILabel!
    @IBOutlet weak var label_price: UILabel!
    
    @IBOutlet var tempType: [UIButton]!
    @IBOutlet var sizeButtons: [UIButton]!
    @IBOutlet var cupButtons: [UIButton]!
    
    @IBOutlet weak var btn_option: UIButton!
    
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var btn_basket: UIButton!{
        didSet{
            btn_basket.layer.cornerRadius = btn_basket.frame.height / 2
        }
    }
    @IBOutlet weak var label_sum: UILabel!
    
    @IBOutlet weak var label_amount: UILabel!
    @IBOutlet weak var btn_plus: UIButton!
    @IBOutlet weak var btn_minus: UIButton!
    
    @IBOutlet weak var btn_sale: UIButton!
    
    @IBOutlet var dessertView: UIView!
    @IBOutlet var bottomLayout: NSLayoutConstraint!
    @IBOutlet var viewLine: UIView!
    
    var alertUtil = AlertUtil()
    var networkUtil = NetworkUtil()
    var menuModel: NSDictionary?
    var bookmarkModel: ApiDefaultModel?
    
    var isBookmark: Bool = false
    var selectedTemp: Int?
    var selectedSize: Int?
    var selectedCup: Int?
    var amount: Int = 1
    var tumblerSale: String = ""
    var single: String = ""
    var price: String = ""
    
    var specialArr = ["리치 복숭아 블랙티", "피치 리치 스무디", "피치 레몬 스무디", "피치 청포도 스무디"]
    var tempArr = ["HOT", "ICED"]
    var sizeArr = ["GRANDE", "VENTI", "대용량"]
    var cupArr = ["매장컵", "텀블러", "일회용컵"]
    
    var hotPrice: [String] = []
    var icePrice: [String] = []
    var dessertPrice: String = "0"
    var nutriArr: NSArray?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destination as? InfomationVC else { return }
        
        let obj = self.menuModel!
        let no = obj["no"] as! String
        let name = obj["name"] as! String
        let eng_name = obj["eng_name"] as! String
        let bookmark = obj["bookmark"] as! String
        let content = obj["content"] as! String
        let allergy = obj["allergy"] as! NSArray
        
        vc.menuNo = no
        vc.name_ko = name
        vc.name_en = eng_name
        vc.price = label_price.text!
        vc.bookmark = bookmark
        vc.allergy = allergy as! [String]
        
        let nutrition_info = obj["nutrition_info"] as! NSArray
        if nutrition_info.count > 0 {
            let dic = nutrition_info[0] as! NSDictionary
            let value = dic["value"] as! String
            vc.value = value
        }
        
        vc.value = content
        
        if selectedTemp == 0 {
            let imgHot = obj["imgHot"] as! String
            vc.imgPath = imgHot
        } else {
            let imgIce = obj["imgIce"] as! String
            vc.imgPath = imgIce
        }
        
        vc.selectedTemp = selectedTemp
        vc.dessertPrice = dessertPrice
        vc.nutriArr = nutriArr
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xE6E6E6).cgColor
        imageView.layer.borderWidth = 1
        
//        selectedTemp = 1
//        selectedSize = 0
        selectedCup = 0
        label_amount.text = "\(amount)"
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "메뉴 옵션")
        navigationController?.isNavigationBarHidden = false
        
        
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.shadowRadius = 2
        
        btnView.layer.masksToBounds = false
        btnView.layer.shadowColor = UIColor.gray.cgColor
        btnView.layer.shadowOpacity = 0.1
        btnView.layer.shadowOffset = CGSize(width: 0, height: -2)
        btnView.layer.shadowRadius = 2
        
        getListApi()
        
        btn_bookmark.addTarget(self, action: #selector(tapedBookmark(sender:)), for: .touchUpInside)
        
//        var i = 0
//        while i < 4 {
//
//            if label_name.text == specialArr[i] {
//                btn_sale.setTitle("50%", for: .normal)
//                return
//            }
//
//            i += 1
//
//            if i == 4{
//                btn_sale.setTitle("5%", for: .normal)
//            }
//        }
        
    }
    
    func getListApi() {
        
        let cmd = "get_goods_detail"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let no = store.dummyItemNo!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NO>\(no)</NO></DATA>"
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
                    self.menuModel = jsonResult
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.setting()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setting() {
        
//        selectedCup = 0
        hotPrice = []
        icePrice = []
        
        let obj = self.menuModel!
        let useOpt = obj["useOpt"] as! String
        let name = obj["name"] as! String
        let imgHot = obj["imgHot"] as! String
        let imgIce = obj["imgIce"] as! String
        let eng_name = obj["eng_name"] as! String
        let price_hot_grande = obj["price_hot_grande"] as! String
        let price_hot_venti = obj["price_hot_venti"] as! String
        let price_hot_large = obj["price_hot_large"] as! String
        let price_ice_grande = obj["price_ice_grande"] as! String
        let price_ice_venti = obj["price_ice_venti"] as! String
        let price_ice_large = obj["price_ice_large"] as! String
        let price_dessert = obj["price_dessert"] as! String
        let tumbler = obj["tumbler"]!
        let bookmark = obj["bookmark"] as! String
        nutriArr =  obj["nutrition_info"] as? NSArray
        
        if bookmark != "0" {
            btn_bookmark.isSelected = true
        } else {
            btn_bookmark.isSelected = false
        }
        
        var imgPath = ""
        
        if selectedTemp == nil {
            
            if imgHot == "" {
                
                selectedTemp = 1
                imgPath = imgIce
                tempType[0].isHidden = true
                
            } else {
                
                selectedTemp = 0
                imgPath = imgHot
                tempType[0].isHidden = false
                
                if imgIce == "" {
                    tempType[1].isHidden = true
                } else {
                    tempType[1].isHidden = false
                }
                
            }
            
        }
        
        hotPrice = [price_hot_grande, price_hot_venti, price_hot_large]
        icePrice = [price_ice_grande, price_ice_venti, price_ice_large]
        dessertPrice = price_dessert
        
        if selectedSize == nil {
            
            for i in 0..<3 {
                
                if hotPrice[i] != "0"{
                    price = hotPrice[i]
                    selectedSize = i
                    break
                }
                
                if icePrice[i] != "0"{
                    price = icePrice[i]
                    selectedSize = i
                    break
                }
                
            }
            
            if price == "" {
                price = price_dessert
                selectedSize = 0
            }
            
        } else {
            //
        }
        
        if selectedTemp == 0 {
            
            for i in 0..<3 {
                
                if hotPrice[i] == "0"{
                    sizeButtons[i].isHidden = true
                } else {
                    sizeButtons[i].isHidden = false
                }
                
            }
            
        } else {
            
            for i in 0..<3 {
                
                if icePrice[i] == "0"{
                    sizeButtons[i].isHidden = true
                } else {
                    sizeButtons[i].isHidden = false
                }
                
            }
            
        }
        
        self.loadImage(urlString: imgPath) { image in

            DispatchQueue.main.async {
                self.imageView.image = image
            }

        }
        
        label_name.text = name
        label_name_en.text = eng_name
        label_price.text = currncyStr(str: price)
        
        if useOpt == "0" {
            btn_option.isHidden = true
            viewLine.isHidden = true
        } else {
            btn_option.isHidden = false
            viewLine.isHidden = false
        }
        
        let cate1 = obj["cate1"] as! String
        if cate1 != "1" {
            
            setBtn()
            dessertView.isHidden = true
            bottomLayout.constant = 20
            
        } else {
            dessertView.isHidden = false
            bottomLayout.constant = 0
        }
        
        UIView.setAnimationsEnabled(false)
        btn_sale.setTitle("\(tumbler)%", for: .normal)
        btn_sale.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        checkPrice()
        
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
    
    @objc func tapedBookmark(sender: UIButton) {
        
        sender.isSelected.toggle()
        
        let cmd = "set_bookmark_menu"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let obj = self.menuModel!
        let no = obj["no"] as! String
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
        
        btn_option.layer.cornerRadius = btn_option.frame.height / 2
        btn_sale.layer.cornerRadius = btn_sale.frame.height / 2
        btn_basket.layer.cornerRadius = btn_basket.frame.height / 2
        
//        btn_hot.isHidden = true
        
        for (index, item) in tempType.enumerated() {
            
            if selectedTemp != nil {
                
                if index == selectedTemp {
                    
                    if index == 0 {
                        item.layer.borderWidth = 2
                        item.layer.cornerRadius = item.frame.height / 2
                        item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F), for: .normal)
                        item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F).cgColor
                    }
                    
                    if index == 1 {
                        item.layer.borderWidth = 2
                        item.layer.cornerRadius = item.frame.height / 2
                        item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1), for: .normal)
                        item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1).cgColor
                    }
                    
                } else {
                    item.layer.borderWidth = 2
                    item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                    item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                    item.layer.cornerRadius = item.frame.height / 2
                }
                
            } else {
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
            }
            
        }
        
        for (index, item) in sizeButtons.enumerated() {
            
            if index == selectedSize {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
        for (index, item) in cupButtons.enumerated() {
            
            if index == selectedCup {
                
                item.layer.borderWidth = 2
                item.layer.cornerRadius = item.frame.height / 2
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
                
            } else {
                
                item.layer.borderWidth = 2
                item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
                item.layer.cornerRadius = item.frame.height / 2
                
            }
            
        }
        
    }

    @IBAction func touchTempType(_ sender: UIButton) {
        
        if selectedTemp != nil{
            
            selectedTemp = tempType.firstIndex(of: sender)
            // 선택
            for unselectIndex in tempType {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            if selectedTemp == 0 {
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F), for: .normal)
                sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F).cgColor
            }
            
            if selectedTemp == 1 {
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1), for: .normal)
                sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1).cgColor
            }
            
        } else {
            selectedTemp = tempType.firstIndex(of: sender)
            
            if selectedTemp == 0 {
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F), for: .normal)
                sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x740F0F).cgColor
            }
            
            if selectedTemp == 1 {
                sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1), for: .normal)
                sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x283FB1).cgColor
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        checkPrice()
        print(selectedTemp ?? 0)
        
        tapedTemp()
        
    }
    
    func tapedTemp() {
        
        let obj = self.menuModel!
        let imgHot = obj["imgHot"] as! String
        let imgIce = obj["imgIce"] as! String
        var imagPath = ""
        
        if selectedTemp == 0 {
            imagPath = imgHot
            label_price.text = currncyStr(str: hotPrice[selectedSize!])
        } else {
            imagPath = imgIce
            label_price.text = currncyStr(str: icePrice[selectedSize!])
        }
        
        self.loadImage(urlString: imagPath) { image in

            DispatchQueue.main.async {
                self.imageView.image = image
            }

        }
        
        if selectedTemp == 0 {
            
            for i in 0..<3 {
                
                if hotPrice[i] == "0"{
                    sizeButtons[i].isHidden = true
                } else {
                    sizeButtons[i].isHidden = false
                }
                
            }
            
        } else {
            
            for i in 0..<3 {
                
                if icePrice[i] == "0"{
                    sizeButtons[i].isHidden = true
                } else {
                    sizeButtons[i].isHidden = false
                }
                
            }
            
        }
        
    }
    
    @IBAction func touchSizeButtons(_ sender: UIButton) {
        
        if selectedSize != nil{
            
            for unselectIndex in sizeButtons {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            selectedSize = sizeButtons.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            selectedSize = sizeButtons.firstIndex(of: sender)
        }
        
        checkPrice()
        print(selectedSize ?? 0)
        
        tapedSize()
        
    }
    
    func tapedSize() {

        if selectedTemp == 0 {
            label_price.text = currncyStr(str: hotPrice[selectedSize!])
        } else {
            label_price.text = currncyStr(str: icePrice[selectedSize!])
        }
        
    }
    
    @IBAction func touchCupButtons(_ sender: UIButton) {
        
        if selectedCup != nil{
            
            for unselectIndex in cupButtons {
                unselectIndex.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
                unselectIndex.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF), for: .normal)
            }
            
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            selectedCup = cupButtons.firstIndex(of: sender)
            
        } else {
            sender.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
            selectedCup = cupButtons.firstIndex(of: sender)
        }
        
        checkPrice()
        print(selectedCup ?? 0)
        
    }
    
    @IBAction func touchPlus(_ sender: UIButton) {
        
        amount += 1
        label_amount.text = "\(amount)"
        
        checkPrice()
    }
    
    @IBAction func touchMinus(_ sender: UIButton) {
        
        amount -= 1
        
        if amount < 1 {
            amount = 1
        }
        
        label_amount.text = "\(amount)"
        
        checkPrice()
    }
    
    func checkPrice() {
        
        var priceStr: String = ""
        
        if selectedTemp == 0 {
            priceStr = hotPrice[selectedSize!]
        } else {
            priceStr = icePrice[selectedSize!]
        }
        
        if priceStr == "0" {
            priceStr = dessertPrice
        }
        
        //amount
        let str = priceStr.replacingOccurrences(of: ",", with: "")
        priceStr = "\(Int(str)! * amount)"
        
        //tumbler sale
        if selectedCup == 1 {

            let str = priceStr.replacingOccurrences(of: ",", with: "")

            let obj = self.menuModel!
            let tumbler = obj["tumbler"] as! Int
            let dc = Double(Double(tumbler) / 100)
            
            priceStr = "\(Double(str)! - (Double(str)! * dc))"
            tumblerSale = "\(Double(str)! * dc)"
            
            
        } else {
            tumblerSale = ""
        }
        
        single = "\(floor(Double(priceStr)! / Double(amount)))"
        
        var optionPrice: Int = 0
        if store.option["shot"] != 0 {
            optionPrice = store.option["shot"]! * 500
        }
        
        if store.option["special"] != 0 {
            optionPrice = optionPrice + 1000
        }
        
        if store.option["decaffein"] != 0 {
            optionPrice = optionPrice + 300
        }
        
        if store.option["vanilla"] != 0 {
            optionPrice = optionPrice + store.option["vanilla"]! * 500
        }
        
        if store.option["hazel"] != 0 {
            optionPrice = optionPrice + store.option["hazel"]! * 500
        }
        
        if store.option["caramel"] != 0 {
            optionPrice = optionPrice + store.option["caramel"]! * 500
        }
        
        if store.option["pearl"] != 0 {
            optionPrice = optionPrice + 800
        }
        
        if store.option["coco"] != 0 {
            optionPrice = optionPrice + 500
        }
        
        priceStr = "\(Double(priceStr)! + Double(optionPrice))"
        label_sum.text = currncyStr(str: priceStr)
        single = "\(floor(Double(single)! + Double(optionPrice)))"
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
    
    @IBAction func putBasket(_ sender: UIButton) {
        
        if store.storeName != "" {
        
            if tumblerSale != "" {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.locale = Locale.current
                formatter.maximumFractionDigits = 0//소숫점은 없어요
                
                if let formattedNumber = formatter.number(from: tumblerSale),
                   let formattedString = formatter.string(from: formattedNumber) {
                    
                    tumblerSale = "\(formattedString)원"
                    
                }
                
            }
            
            let obj = self.menuModel!
            let imgHot = obj["imgHot"] as! String
            let imgIce = obj["imgIce"] as! String
            var imgPath = ""
            let tumbler = obj["tumbler"] as! Int
            
            if selectedTemp == 0 {
                imgPath = imgHot
            } else {
                imgPath = imgIce
            }
            
            var optionStr = ""
            var priceOption = 0

            if store.option["shot"] != 0 {
                priceOption = priceOption + (store.option["shot"]! * 500)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)샷추가 +\(store.option["shot"]! * 500)"
            }
            
            if store.option["strong"] != 0 {
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)연하게)"
            }
            
            if store.option["special"] != 0 {
                priceOption = priceOption + (store.option["special"]! * 1000)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)스페셜티 +\(store.option["special"]! * 1000)"
            }
            
            if store.option["decaffein"] != 0 {
                priceOption = priceOption + (store.option["decaffein"]! * 300)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)디카페인 +\(store.option["decaffein"]! * 300)"
            }
            
            if store.option["vanilla"] != 0 {
                priceOption = priceOption + (store.option["vanilla"]! * 500)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)바닐라시럽 +\(store.option["vanilla"]! * 500)"
            }
            
            if store.option["hazel"] != 0 {
                priceOption = priceOption + (store.option["hazel"]! * 500)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)헤이즐럿시럽 +\(store.option["hazel"]! * 500)"
            }
            
            if store.option["caramel"] != 0 {
                priceOption = priceOption + (store.option["caramel"]! * 500)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)카라멜시럽 +\(store.option["caramel"]! * 500)"
            }
            
            if store.option["pearl"] != 0 {
                priceOption = priceOption + (store.option["pearl"]! * 800)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)펄추가 +\(store.option["pearl"]! * 800)"
            }
            
            if store.option["coco"] != 0 {
                priceOption = priceOption + (store.option["coco"]! * 800)
                
                var str = ""
                if optionStr != "" {
                    str = " | "
                }
                
                optionStr = "\(optionStr)\(str)나타드코코추가 +\(store.option["coco"]! * 800)"
            }
            
            let intStr = label_sum.text!.replacingOccurrences(of: ",", with: "")
            let strInt: Int = Int(intStr.replacingOccurrences(of: " 원", with: ""))!
            
            let intStr1 = label_price.text!.replacingOccurrences(of: ",", with: "")
            let strInt1: Int = Int(intStr1.replacingOccurrences(of: " 원", with: ""))!
            
            var tempStr = tempArr[selectedTemp!]
            var sizeStr = sizeArr[selectedSize!]
            var cupStr = cupArr[selectedCup!]
            
            if dessertPrice != "0" {
                
                tempStr = ""
                sizeStr = ""
                cupStr = ""
                
            }
            
            let basketModel = BasketModel(name: label_name.text!,
                                          no: store.dummyItemNo!,
                                          goodsPath: imgPath,
                                          price: "\(strInt1)",
                                          option: "\(priceOption)",
                                          hot_ice: tempStr,
                                          size: sizeStr,
                                          cup: cupStr,
                                          result: "\(strInt)",
                                          count: label_amount.text!,
                                          discount: tumblerSale,
                                          discountPer: tumbler,
                                          singleResult: single,
                                          optionStr: optionStr,
                                          shot: store.option["shot"]!,
                                          decaf: store.option["decaffein"]!,
                                          weak: store.option["strong"]!,
                                          vanilla: store.option["vanilla"]!,
                                          hazelnut: store.option["hazel"]!,
                                          caramel: store.option["caramel"]!,
                                          pearl: store.option["pearl"]!,
                                          coco: store.option["coco"]!)
            
            if store.basketArr.count > 0 {

                let curName: String = label_name.text!
                let curHotIce: String = tempStr
                let curSize: String = sizeStr
                let curCup: String = cupStr
                let curOption: String = optionStr

                for (index, _) in store.basketArr.enumerated() {

                   let saveName: String = store.basketArr[index].name
                   let saveHotIce: String = store.basketArr[index].hot_ice
                   let saveSize: String = store.basketArr[index].size
                   let saveCup: String = store.basketArr[index].cup
                   let saveOption: String = store.basketArr[index].optionStr
                   
                   if curName == saveName {
                       
                       if curHotIce == saveHotIce {
                           
                           if curSize == saveSize {
                               
                               if curCup == saveCup {
                                   
                                   if curOption == saveOption {
                                       
                                       let saveCount: Int = Int(store.basketArr[index].count)!
                                       let currentCount: Int = Int(label_amount.text!)!
                                       
                                       let saveResult: Int = Int(store.basketArr[index].result)!
                                       let currentResult: Int = strInt
                                       
                                       store.basketArr[index].count = String(saveCount + currentCount)
                                       store.basketArr[index].result = String(saveResult + currentResult)
                                       
                                       UserDefaults.standard.setValue(try? PropertyListEncoder().encode(store.basketArr), forKey: "basket")
                                       UserDefaults.standard.setValue(store.storeName, forKey: "storeName")
                                       
                                       let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "PutBasket") as! PutBasket
                                       pop.modalPresentationStyle = .overFullScreen
                                       self.present(pop, animated: false, completion: nil)
                                       
                                       return
                                       
                                   }
                                   
                               }
                               
                           }
                           
                       }
                       
                   }

                }

            }
            
            store.basketArr.append(basketModel)
            UserDefaults.standard.setValue(try? PropertyListEncoder().encode(store.basketArr), forKey: "basket")
            UserDefaults.standard.setValue(store.storeName, forKey: "storeName")
            
            let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "PutBasket") as! PutBasket
            pop.modalPresentationStyle = .overFullScreen
            self.present(pop, animated: false, completion: nil)
            
        } else {
            
            self.alertUtil.oneItem(self, title: "메뉴 옵션", message: "주문 하실 매장을 먼저 선택해 주세요.")
            
        }
        
    }
    
    @IBAction func touchOption(_ sender: Any) {
        
        let obj = self.menuModel!
        let useOpt = obj["useOpt"] as! String
        let opt_syrup = obj["opt_syrup"] as! Int
        let opt_shot = obj["opt_shot"] as! Int
        let opt_special = obj["opt_special"] as! Int
        let opt_decaffeine = obj["opt_decaffeine"] as! Int
        let opt_hard = obj["opt_hard"] as! Int
        let opt_pearl = obj["opt_pearl"] as! Int
        let opt_natadcoco = obj["opt_natadcoco"] as! Int
        
        if useOpt == "1" {
            
            store.dummySyrup = opt_syrup
            store.dummySpecial = opt_special
            store.dummyShot = opt_shot
            store.dummyDecaffeine = opt_decaffeine
            store.dummyHard = opt_hard
            store.dummyPearl = opt_pearl
            store.dummyNatadcoco = opt_natadcoco
            
            let optionPop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "CustomOption") as! CustomOption
            optionPop.modalPresentationStyle = .overFullScreen
            self.present(optionPop, animated: false, completion: nil)
            
        }
        
    }
    
}

@available(iOS 11, *)
private extension Data {

    static func equal(json1: Data, json2: Data) -> Bool {
        return json1.serialized == json2.serialized
    }

    var serialized: Data? {
        guard let json = try? JSONSerialization.jsonObject(with: self) else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .prettyPrinted]) else {
            return nil
        }
        return data
    }
}
