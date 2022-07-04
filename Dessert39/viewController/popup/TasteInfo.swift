//
//  TasteInfo.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/27.
//

import UIKit

class TasteInfo: UIViewController {

    @IBOutlet weak var boxView: UIView!
    
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
    
    @IBOutlet weak var btn_skip: UIButton!
    @IBOutlet weak var btn_done: UIButton!
    
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
    
    var alertUtil = AlertUtil()
    var networkUtil = NetworkUtil()
    var likeModel: ApiDefaultModel?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        boxView.layer.cornerRadius = 20
        setBtn()
        
    }
    
    @IBAction func touchSkip(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "isTaste")
        
        
        guard let pvc = self.presentingViewController else { return }

        self.dismiss(animated: false) {
           let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "TasteAlert")
            pop.modalPresentationStyle = .overCurrentContext
            pvc.present(pop, animated: false)
        }
        
    }
    
    @IBAction func touchDone(_ sender: Any) {
        
        if selectedCate.count == 0 {
            self.alertUtil.oneItem(self, title: "취향정보", message: "카테고리를 선택해 주세요.")
            return
        }
        
        if selectedKeyword.count == 0 {
            self.alertUtil.oneItem(self, title: "취향정보", message: "카워드를 선택해 주세요.")
            return
        }
        
        if selectedBrand.count == 0 {
            self.alertUtil.oneItem(self, title: "취향정보", message: "브랜드를 선택해 주세요.")
            return
        }
        
        for i in selectedBrand {
            
            switch i {
                
            case 0:
                if selectedStarbucks.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 1:
                if selectedTwosome.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 2:
                if selectedPaul.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 3:
                if selectedEdiay.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 4:
                if selectedMega.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 5:
                if selectedPaik.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 6:
                if selectedGongcha.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            case 7:
                if selectedBean.count == 0 {
                    self.alertUtil.oneItem(self, title: "취향정보", message: "음료를 선택해 주세요.")
                    return
                }
                break
                
            default :
                break
                
            }
            
        }
        
        likeApi()
        
    }
    
    func setBtn() {
        
        btn_skip.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        btn_skip.layer.borderWidth = 1
        btn_skip.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
        btn_skip.layer.cornerRadius = 5
        
        btn_done.layer.cornerRadius = btn_done.frame.height / 2
        
        for item in categoryGroup {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in keywordGroup {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in brandGroup {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in starbucks {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in twosome {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in paulbassett {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in ediya {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in mega {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            
        }
        
        for item in paik {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in gongcha {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in coffeebean {
            
            item.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            item.layer.cornerRadius = 5
            item.titleLabel?.textAlignment = .center
            
        }
        
        for item in brandViews {
            
            item.isHidden = true
            
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
    
    func likeApi() {
        
        let cmd = "liking"
        var cate = ""
        var drink = ""
        var brand = ""
        var b_drink = ""
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        
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
        
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><CATA>\(cate)</CATA><DRINK>\(drink)</DRINK><BRAND>\(brand)</BRAND><B_DRINK>\(b_drink)</B_DRINK><TOKEN>\(token)</TOKEN></DATA>"
        
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")

        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in

            if let hasData = data {
                do {

                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!

                    self.likeModel = try JSONDecoder().decode(ApiDefaultModel.self, from: decrypedData)

                    DispatchQueue.main.async {

                        if self.likeModel!.errCode == "0000" {

                            UserDefaults.standard.set(true, forKey: "isTaste")

                        }
                        
                        self.dismiss(animated: true, completion: nil)

                    }


                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }

        }
        
    }
    
}
