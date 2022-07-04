//
//  MyInfo.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/20.
//

import UIKit
import PhotosUI
import AVFoundation

class MyInfo: UIViewController {
    
    var fetchResult:PHFetchResult<PHAsset>?

    @IBOutlet var userImg: UIImageView!{
        didSet{
            userImg.layer.cornerRadius = 5
            userImg.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var btn_image: UIButton!{
        didSet{
            btn_image.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            btn_image.layer.borderWidth = 1
            btn_image.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_image.layer.cornerRadius = 5
            btn_image.titleLabel?.textAlignment = .center
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var id_input: UITextField!
    @IBOutlet weak var pw_input: UITextField!
    @IBOutlet weak var pwCheck_input: UITextField!
    @IBOutlet weak var email_input: UITextField!
    @IBOutlet weak var nick_input: UITextField!
    @IBOutlet weak var name_input: UITextField!
    @IBOutlet weak var phone_input: UITextField!
    @IBOutlet weak var birth_input: UITextField!
    @IBOutlet weak var btn_join: UIButton!
    
    @IBOutlet var phoneView: UIView!
    @IBOutlet var authToggle: UISwitch!
    
    var networkUtil = NetworkUtil()
    var textFieldComp = TextFieldComp()
    var alertUtil = AlertUtil()
    var modModel: ApiDefaultModel?
    var imageModel: ImageModel?
    var isCheck: Bool = false
    var infoModel: NSDictionary?
    
    
    @IBOutlet var categoryGroup: [UIButton]!
    @IBOutlet var keywordGroup: [UIButton]!
    @IBOutlet var brandGroup: [UIButton]!
    
    @IBOutlet var starbucks: [UIButton]!
    @IBOutlet var twosome: [UIButton]!
    @IBOutlet var paulbassett: [UIButton]!
    @IBOutlet var ediya: [UIButton]!
    @IBOutlet var mega: [UIButton]!
    @IBOutlet var paik: [UIButton]!
    @IBOutlet var gongcha: [UIButton]!
    @IBOutlet var coffeebean: [UIButton]!
    
    @IBOutlet var brandViews: [UIView]!
    
    var selectedCate: [Int] = []
    var selectedKeyword: [Int] = []
    var selectedBrand: [Int] = []
    
    var selectedStarbucks: [Int] = []
    var selectedTwosome: [Int] = []
    var selectedPaul: [Int] = []
    var selectedEdiay: [Int] = []
    var selectedMega: [Int] = []
    var selectedPaik: [Int] = []
    var selectedGongcha: [Int] = []
    var selectedBean: [Int] = []
    
    let categoryArr = ["커피", "Non-커피", "밀크티", "티&티 블랜딩", "에이드", "스무디&프라페", "프로마쥬", "빙수&파르페"]
    let keywordArr = ["달달한", "상큼한", "청량한", "고소한", "단짠", "건강한", "당충전", "과일류", "대용량", "인기메뉴"]
    let brandArr = ["스타벅스", "투썸플레이스", "폴바셋", "이디야", "메가커피", "빽다방", "공차", "커피빈"]
    let starbucksArr = ["카페모카", "초콜릿크림칩프라푸치노", "카라멜 마끼아또", "돌체 콜드 브루", "허니자몽블랙티", "더블샷바닐라", "토피넛라떼", "블론드바닐라더블샷마키아또", "쿨라임피지오"]
    let twosomeArr = ["로얄밀크티", "스트로베리피치프라페", "허니레몬티", "스페니쉬연유라떼", "상그리아에이드", "쑥라떼", "자몽시트러스프라페", "제주말차프라페", "시그니처뱅쇼"]
    let paulArr = ["돌체라떼", "제주 한라봉에이드", "바닐라라떼", "카라멜마끼아토", "스윗밀크티", "스트로베리요거트", "제주말차라떼", "망고바나나프라페", "밀크초콜릿"]
    let ediayArr = ["복숭아아이스티", "달고나라떼", "연유카페라떼", "바닐라라떼", "민트초콜릿칩 플랫치노", "토피넛라떼", "자몽에이드", "꿀복숭아플랫치노", "아인슈패너"]
    let megaArr = ["아이스밀크티", "딸기라떼", "허니자몽블랙티", "사과유자티", "메가에이드(레몬/자몽/라임)", "플레인 퐁크러쉬", "코코넛커피스무디", "연유라떼", "복숭아아이스티"]
    let paikArr = ["돌체라떼", "바닐라라떼", "카라멜마끼아토", "스윗밀크티", "완전딸기빽스치노", "완전수박", "레몬에이드", "피치우롱티", "퐁당치노"]
    let gongchaArr = ["블랙밀크티", "브라운슈가쥬얼리밀크티", "타로밀크티", "망고스무디", "민트초코스무디", "딸기쿠키스무디", "초코멜로스무디", "리얼초콜릿밀크티", "초코쿠앤크스무디"]
    let beanArr = ["잉글리쉬라떼", "빈슈페너", "달고나크림라떼", "카페수아", "레몬유자캐모마일티", "스파클링스웨디쉬레몬티", "화이트포레스트", "베리베리IB", "망고바나나IB"]
    
    var cArr: [String] = []
    var dArr: [String] = []
    var bArr: [String] = []
    var arr: [String] = []
    var b_drinkArr: [Array<String>] = [[], [], [], [], [], [], [], []]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueVC = segue.destination as? AgreementCon {
            
            if segue.identifier == "agreenment5" {
                segueVC.agreeMentTag = 4
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setEndEdting()
        getInfoApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "내 정보")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.contentInset.bottom = 0
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height - 150
    }

    @objc private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    func setEndEdting() {
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MyTapMethod))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        
    }
    
    @objc func MyTapMethod(sender: UITapGestureRecognizer) {
        
        self.view.endEditing(true)

    }
    
    func setInput() {
        
        let obj = self.infoModel!
        let id = obj["id"] as! String
        let sns = obj["sns"] as! String
        let name = obj["name"] as! String
        let birth = obj["birth"] as! String
        let hp = obj["hp"] as! String
        let nick = obj["nick"] as! String
        let email = obj["email"] as! String
        let marketing = obj["marketing"] as! String
        
        let cata = obj["cata"] as! String
        let drink = obj["drink"] as! String
        let brand = obj["brand"] as! String
        let b_drink = obj["b_drink"] as! String
        
//        let cata = "커피"
//        let drink = "달달한,인기메뉴"
//        let brand = "스타벅스,이디야"
//        let b_drink = "카페모카,허니자몽블랙티|달고나라떼"

        if cata != "" {
            cArr = cata.components(separatedBy: ",")//.map({ (value : String) -> Int in return Int(value)! })
        }

        if drink != "" {
            dArr = drink.components(separatedBy: ",")//.map({ (value : String) -> Int in return Int(value)! })
        }

        if brand != "" {
            bArr = brand.components(separatedBy: ",")//.map({ (value : String) -> Int in return Int(value)! })
        }
        
        if b_drink != "" {
            arr = b_drink.components(separatedBy: "|")
            
            var array: [Int] = []
            for str in bArr {
                
                for (ind, ite) in brandArr.enumerated() {
                    
                    if str == ite {
                        array.append(ind)
                    }
                    
                }
                
            }
            
            
            for (index, item) in arr.enumerated() {
                
                b_drinkArr.insert(item.components(separatedBy: ","), at: array[index])
                
            }
            
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail

        let attributedString = NSMutableAttributedString(string: id)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))

        id_input.attributedText = attributedString
        
        textFieldComp.setUnableInput(tf: id_input)
//        id_input.text = id
        
        if sns != "자체가입" || sns != "S" {
            
            textFieldComp.setUnableInput(tf: pw_input)
            textFieldComp.setUnableInput(tf: pwCheck_input)
            
            pw_input.placeholder = "SNS 로그인을 사용 하셨습니다."
            pwCheck_input.placeholder = "SNS 로그인을 사용 하셨습니다."
            
        } else {
            
            textFieldComp.setInput(tf: pw_input)
            textFieldComp.setInput(tf: pwCheck_input)
            
            pw_input.placeholder = "새로운 비밀번호를 입력해 주세요."
            pwCheck_input.placeholder = "새로운 비밀번호를 한번 더 입력해 주세요."
            
            pw_input.inputAccessoryView = toolbar
            pwCheck_input.inputAccessoryView = toolbar
            
        }
        
        textFieldComp.setInput(tf: email_input)
        email_input.text = email
        email_input.inputAccessoryView = toolbar
        
        textFieldComp.setInput(tf: nick_input)
        nick_input.text = nick
        nick_input.inputAccessoryView = toolbar
        
        textFieldComp.setUnableInput(tf: name_input)
        name_input.text = name
        
        textFieldComp.setUnableInput(tf: birth_input)
        birth_input.text = birth
        
        if hp == "" {
            textFieldComp.setInput(tf: phone_input)
            phone_input.isUserInteractionEnabled = false
            phone_input.text = ""
            phone_input.inputAccessoryView = toolbar
            
            let gesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goAuth(_:)))
            phoneView.addGestureRecognizer(gesture)
            
        } else {
            textFieldComp.setUnableInput(tf: phone_input)
            phone_input.text = hp
        }
        
        authToggle.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        authToggle.addTarget(self, action: #selector(onClickSwitch(sender:)), for: .valueChanged)
        print(marketing)
        if marketing == "Y" {
            authToggle.isOn = true
            authToggle.thumbTintColor = .black
            authToggle.onTintColor = UIColorFromRGB.colorInit(0.2, rgbValue: 0x1C1C1C)
        } else {
            authToggle.isOn = false
            authToggle.thumbTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xc9c9c9)
            authToggle.onTintColor = UIColorFromRGB.colorInit(0.1, rgbValue: 0xE1E1E1)
        }
        
        if let imgPath = store.userImg {
            
            self.loadImage(urlString: imgPath) { image in

                DispatchQueue.main.async {
                    self.userImg.image = image
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
    
    @objc func onClickSwitch(sender: UISwitch) {
        
        if sender.isOn {
            sender.thumbTintColor = .black
            sender.onTintColor = UIColorFromRGB.colorInit(0.2, rgbValue: 0x1C1C1C)
        } else {
            sender.thumbTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xc9c9c9)
            sender.onTintColor = UIColorFromRGB.colorInit(0.1, rgbValue: 0xE1E1E1)
        }
        
    }
    
    @objc func goAuth(_ gesture: UITapGestureRecognizer) {
        performSegue(withIdentifier: "authSegue", sender: self)
    }
    
    @objc func done() {
        self.view.endEditing(true)
    }
    
    @IBAction func joinHandler(_ sender: Any) {
        
        let obj = self.infoModel!
        let sns = obj["sns"] as! String
        
        if sns == "" {
            
            if let pw = pw_input.text {
                if !validpassword(mypassword: pw) {
                    alertHandler("비밀번호는 영문+숫자 조합 8자 이상 입니다")
                    return
                }
            }
            
            if pw_input.text != "" && pwCheck_input.text == "" {
                alertHandler("비밀번호 확인을 해주세요")
                return
            }
            
            if pw_input.text != pwCheck_input.text {
                alertHandler("비밀번호가 일치하지 않습니다")
                return
            }
            
        }
        
        if email_input.text != "" {
            
            if let em = email_input.text {
                if !isValidEmail(emailStr: em) {
                    alertHandler("이메일 형식이 맞지 않습니다")
                    return
                }
            }
            
        }
        
        let dummyArr = [selectedStarbucks, selectedTwosome, selectedPaul, selectedEdiay, selectedMega, selectedPaik, selectedGongcha, selectedBean]
        for (index,item) in brandViews.enumerated() {
            
            if !item.isHidden {
                
                if dummyArr[index].count == 0 {
                    alertHandler("선택하신 브랜드의 음료를 선택해 주세요")
                    return
                }
                
            }
            
        }
        
        joinApi()
        
    }
    
    func alertHandler(_ str: String) {
        
        self.alertUtil.oneItem(self, title: "정보입력", message: str)
        
    }
    
    func validpassword(mypassword : String) -> Bool {
        //숫자+문자 포함해서 8
        let passwordreg = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,}")
        let passwordtesting = NSPredicate(format: "SELF MATCHES %@", passwordreg)
        
        return passwordtesting.evaluate(with: mypassword)
        
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
       return emailTest.evaluate(with: emailStr)
        
    }
    
    func joinApi() {
        
//        let sessionConfig = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfig)
        
        let cmd = "mem_mod"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let name = name_input.text!
        let phone = phone_input.text!
        let birth = birth_input.text!
        let marketing = authToggle.isOn ? "Y" : "N"
        
        let pwd = pw_input.text!
        let email = email_input.text!
        let nick = nick_input.text!
        
        var cate = ""
        var drink = ""
        var brand = ""
        var b_drink = ""
        
        for (index, i) in selectedCate.enumerated() {
            
            if index == selectedCate.count - 1 {
                cate = "\(cate)\(categoryArr[i])"
            } else {
                cate = "\(cate)\(categoryArr[i]),"
            }
            
        }
        
        for (index, i) in selectedKeyword.enumerated() {
            
            if index == selectedKeyword.count - 1 {
                drink = "\(drink)\(keywordArr[i])"
            } else {
                drink = "\(drink)\(keywordArr[i]),"
            }
            
        }
        
        for (index, i) in selectedBrand.enumerated() {
            
            if index == selectedBrand.count - 1 {
                brand = "\(brand)\(brandArr[i])"
            } else {
                brand = "\(brand)\(brandArr[i]),"
            }
            
            if i == 0 {
                
                for (index, i) in selectedStarbucks.enumerated() {
                    
                    if index == selectedStarbucks.count - 1 {
                        b_drink = "\(b_drink)\(starbucksArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(starbucksArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 1 {
                
                for (index, i) in selectedTwosome.enumerated() {
                    
                    if index == selectedTwosome.count - 1 {
                        b_drink = "\(b_drink)\(twosomeArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(twosomeArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 2 {
                
                for (index, i) in selectedPaul.enumerated() {
                    
                    if index == selectedPaul.count - 1 {
                        b_drink = "\(b_drink)\(paulArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(paulArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 3 {
                
                for (index, i) in selectedEdiay.enumerated() {
                    
                    if index == selectedEdiay.count - 1 {
                        b_drink = "\(b_drink)\(ediayArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(ediayArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 4 {
                
                for (index, i) in selectedMega.enumerated() {
                    
                    if index == selectedMega.count - 1 {
                        b_drink = "\(b_drink)\(megaArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(megaArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 5 {
                
                for (index, i) in selectedPaik.enumerated() {
                    
                    if index == selectedPaik.count - 1 {
                        b_drink = "\(b_drink)\(paikArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(paikArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 6 {
                
                for (index, i) in selectedGongcha.enumerated() {
                    
                    if index == selectedGongcha.count - 1 {
                        b_drink = "\(b_drink)\(gongchaArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(gongchaArr[i]),"
                    }
                    
                }
                
            }
            
            if i == 7 {
                
                for (index, i) in selectedBean.enumerated() {
                    
                    if index == selectedBean.count - 1 {
                        b_drink = "\(b_drink)\(beanArr[i])|"
                    } else {
                        b_drink = "\(b_drink)\(beanArr[i]),"
                    }
                    
                }
                
            }
            
        }
        
        if b_drink != "" {
            b_drink.removeLast()
        }
        
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NAME>\(name)</NAME><PHONE>\(phone)</PHONE><BIRTH>\(birth)</BIRTH><MARKETING>\(marketing)</MARKETING><PWD>\(pwd)</PWD><EMAIL>\(email)</EMAIL><NICK>\(nick)</NICK><CATA>\(cate)</CATA><DRINK>\(drink)</DRINK><BRAND>\(brand)</BRAND><B_DRINK>\(b_drink)</B_DRINK></DATA>"
        
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.modModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)
                    
                    DispatchQueue.main.async {
                        
                        if self.modModel!.errCode == "0000" {
                            
                            let alert = UIAlertController(title: "내정보 수정", message: "변경된 내용이 저장 되었습니다", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                
                                self.navigationController?.popToRootViewController(animated: true)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
//        let boundary = "Boundary-\(UUID().uuidString)"
//        var request = URLRequest(url: URL(string: store.configUrl)!)
//        request.httpMethod = "POST"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        let httpBody = NSMutableData()
//
//        httpBody.appendString(convertFormField(named: "code", value: urlString, using: boundary))
//
//        if let imageData = store.cameraImage?.jpegData(compressionQuality: 1) {
//            httpBody.append(convertFileData(fieldName: "CARDIMG", fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "multipart/form-data", fileData: imageData, using: boundary))
//        }
//
//        httpBody.appendString("--\(boundary)--")
//
//        request.httpBody = httpBody as Data
//
//        session.dataTask(with: request) { data, response, error in
//            print("status : \((response as! HTTPURLResponse).statusCode)")
//
//            if let hasData = data {
//                do {
//
//                    let dataStr = String(decoding: hasData, as: UTF8.self)
//                    let decryped = AES256CBC.decryptString(dataStr)!
//                    let decrypedData = decryped.data(using: .utf8)!
//
//                    self.modModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)
//                    print(self.modModel)
//                    DispatchQueue.main.async {
//
//                        if self.modModel!.errCode == "0000" {
//                            //
//                        }
//
//                    }
//
//
//                } catch {
//                    print("JSONDecoder Error : \(error)")
//                }
//            }
//
//        }.resume()
//        session.finishTasksAndInvalidate()
        
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        
        let mimeType = "application/json"
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: \(mimeType)\r\n\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
        
    }

    func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
      
        let data = NSMutableData()
                
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
        
    }
    
    func getInfoApi() {
        
        let cmd = "get_member_info"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN></DATA>"
        
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.infoModel = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if self.infoModel!["errCode"] as! String == "0000" {
                            
                            self.setInput()
                            self.setBtn()
                            self.registerNotifications()
                            
                        }
                        
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    @IBAction func changeImg(_ sender: Any) {
        
        let alert = UIAlertController(title: "카드선택", message: "Custom Design 미디어를 선택하세요", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "사진앨범", style: .default) { (action) in
            self.checkPermission()
        }
        let camera = UIAlertAction(title: "카메라", style: .default) { (action) in
            self.checkCameraPermission()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func checkPermission() {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .limited {
            DispatchQueue.main.async {
                self.showGallery()
            }
        } else if PHPhotoLibrary.authorizationStatus() == .denied {
            DispatchQueue.main.async {
                self.showAuthoriaztionDeninedAlert()
            }
        } else if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                self.checkPermission()
            }
        }
        
    }
    
    func showAuthoriaztionDeninedAlert() {
        
        let alert = UIAlertController(title: "접근권한을 설정해 주세요.", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "설정으로 가기", style: .default, handler: { action in
            
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showGallery() {
        
        let library = PHPhotoLibrary.shared()
        var configuration = PHPickerConfiguration(photoLibrary: library)
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    func checkCameraPermission(){
        
       AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
           if granted {
               DispatchQueue.main.async {
                   self.openCamera()
               }
           } else {
               DispatchQueue.main.async {
                   self.showAuthoriaztionDeninedAlert()
               }
           }
       })
        
    }
    
    func openCamera(){
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
    }
    
    func setBtn() {
        
        btn_join.layer.cornerRadius = btn_join.frame.height / 2
        
        for (index, item) in categoryGroup.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in cArr {
                
                for (ind, ite) in categoryArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedCate.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in keywordGroup.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in dArr {
                
                for (ind, ite) in keywordArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedKeyword.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in brandGroup.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in bArr {
                
                for (ind, ite) in brandArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedBrand.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in starbucks.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[0] {
                
                for (ind, ite) in starbucksArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedStarbucks.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in twosome.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[1] {
                
                for (ind, ite) in twosomeArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedTwosome.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in paulbassett.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[2] {
                
                for (ind, ite) in paulArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedPaul.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in ediya.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[3] {
                
                for (ind, ite) in ediayArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedEdiay.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in mega.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            
            for str in b_drinkArr[4] {
                
                for (ind, ite) in megaArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedMega.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in paik.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[5] {
                
                for (ind, ite) in paikArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedPaik.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in gongcha.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[6] {
                
                for (ind, ite) in gongchaArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedGongcha.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index, item) in coffeebean.enumerated() {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
            for str in b_drinkArr[7] {
                
                for (ind, ite) in beanArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                            item.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                            selectedBean.append(ind)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        for (index,item) in brandViews.enumerated() {
            
            item.isHidden = true
            
            for str in bArr {
                
                for (ind, ite) in brandArr.enumerated() {
                    
                    if str == ite {
                        
                        if index == ind {
                            item.isHidden = false
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @IBAction func touchCategory(_ sender: UIButton) {
        
        if selectedCate.count > 0 {
            
            for (index, item) in selectedCate.enumerated() {
                
                if categoryGroup[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedCate.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedCate.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedCate.append(categoryGroup.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedCate.append(categoryGroup.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchKeyword(_ sender: UIButton) {
        
        if selectedKeyword.count > 0 {
            
            for (index, item) in selectedKeyword.enumerated() {
                
                if keywordGroup[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedKeyword.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedKeyword.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedKeyword.append(keywordGroup.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedKeyword.append(keywordGroup.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchBrand(_ sender: UIButton) {
        
        if selectedBrand.count > 0 {
            
            for (index, item) in selectedBrand.enumerated() {
                
                if brandGroup[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedBrand.remove(at: index)
                    brandViews[item].isHidden = true
                    return
                    
                } else {
                    
                    if selectedBrand.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedBrand.append(brandGroup.firstIndex(of: sender)!)
                        brandViews[brandGroup.firstIndex(of: sender)!].isHidden = false
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedBrand.append(brandGroup.firstIndex(of: sender)!)
            brandViews[brandGroup.firstIndex(of: sender)!].isHidden = false
            
        }
        
    }
    
    @IBAction func touchStarbucks(_ sender: UIButton) {
        
        if selectedStarbucks.count > 0 {
            
            for (index, item) in selectedStarbucks.enumerated() {
                
                if starbucks[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedStarbucks.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedStarbucks.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedStarbucks.append(starbucks.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedStarbucks.append(starbucks.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchTwosome(_ sender: UIButton) {
        
        if selectedTwosome.count > 0 {
            
            for (index, item) in selectedTwosome.enumerated() {
                
                if twosome[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedTwosome.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedTwosome.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedTwosome.append(twosome.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedTwosome.append(twosome.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchPaulbassett(_ sender: UIButton) {
        
        if selectedPaul.count > 0 {
            
            for (index, item) in selectedPaul.enumerated() {
                
                if paulbassett[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedPaul.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedPaul.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedPaul.append(paulbassett.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedPaul.append(paulbassett.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchEdiya(_ sender: UIButton) {
        
        if selectedEdiay.count > 0 {
            
            for (index, item) in selectedEdiay.enumerated() {
                
                if ediya[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedEdiay.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedEdiay.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedEdiay.append(ediya.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedEdiay.append(ediya.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchMega(_ sender: UIButton) {
        
        if selectedMega.count > 0 {
            
            for (index, item) in selectedMega.enumerated() {
                
                if mega[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedMega.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedMega.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedMega.append(mega.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedMega.append(mega.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchPaik(_ sender: UIButton) {
        
        if selectedPaik.count > 0 {
            
            for (index, item) in selectedPaik.enumerated() {
                
                if paik[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedPaik.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedPaik.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedPaik.append(paik.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedPaik.append(paik.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchGongcha(_ sender: UIButton) {
        
        if selectedGongcha.count > 0 {
            
            for (index, item) in selectedGongcha.enumerated() {
                
                if gongcha[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedGongcha.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedGongcha.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedGongcha.append(gongcha.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedGongcha.append(gongcha.firstIndex(of: sender)!)
            
        }
        
    }
    
    @IBAction func touchCoffeeBean(_ sender: UIButton) {
        
        if selectedBean.count > 0 {
            
            for (index, item) in selectedBean.enumerated() {
                
                if coffeebean[item] == sender {
                    // 선택 취소
                    sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
                    sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x2c2c2c), for: .normal)
                    selectedBean.remove(at: index)
                    return
                    
                } else {
                    
                    if selectedBean.count < 3 {
                        
                        sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
                        sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
                        selectedBean.append(coffeebean.firstIndex(of: sender)!)
                        
                    }
                    
                }
                
            }
            
        } else {
            
            sender.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000)
            sender.setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff), for: .normal)
            selectedBean.append(coffeebean.firstIndex(of: sender)!)
            
        }
        
    }
    
    func imageApi() {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let cmd = "set_user_img"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(encryped)"
//        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: URL(string: store.configUrl)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()
        
        httpBody.appendString(convertFormField(named: "code", value: urlString, using: boundary))

        if let imageData = store.cameraImage?.jpegData(compressionQuality: 1) {
            httpBody.append(convertFileData(fieldName: "USERIMG", fileName: "\(Date().timeIntervalSince1970).jpg", mimeType: "multipart/form-data", fileData: imageData, using: boundary))
        }

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        
        session.dataTask(with: request) { data, response, error in
            print("status : \((response as! HTTPURLResponse).statusCode)")
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!

                    self.imageModel = try JSONDecoder().decode(ImageModel.self, from: decrypedData)
                    
                    DispatchQueue.main.async {

                        if self.imageModel!.errCode == "0000" {
                            store.userImg = self.imageModel!.userImg
                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
        
        }.resume()
        session.finishTasksAndInvalidate()
        
    }
    
}


extension MyInfo: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let identifires = results.map{ $0.assetIdentifier ?? "" }
        
        self.fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifires, options: nil)
        
        if self.fetchResult?.count != 0 {
            
            let asset = self.fetchResult?[0]
            let imageManager = PHImageManager()
            let scale = UIScreen.main.scale
            let imageSize = CGSize(width: 150 * scale, height: 150 * scale)
            
            imageManager.requestImage(for: asset!, targetSize: imageSize, contentMode: .aspectFill, options: nil) { image, info in
                store.cameraImage = image
            }
            
            self.dismiss(animated: true) {
                self.userImg.image = store.cameraImage
                self.userImg.clipsToBounds = true
                self.userImg.layer.cornerRadius = 5
                self.imageApi()
            }
            
        } else {
            self.dismiss(animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            store.cameraImage = image
        }
        
        picker.dismiss(animated: true) {
            self.userImg.image = store.cameraImage
            self.userImg.clipsToBounds = true
            self.userImg.layer.cornerRadius = 5
            self.imageApi()
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
}

