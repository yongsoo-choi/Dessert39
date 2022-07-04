//
//  OrderVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit

class OrderVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var storBoxH: NSLayoutConstraint!
    
    private let items: [String] = ["추천", "디저트", "커피", "Non-커피", "밀크티", "티 & 티 블랜딩", "에이드", "스무디 & 프라페", "프로마쥬", "빙수 & 파르페", "즐겨찾기"]
    var currentIndex : Int = 0 {
        didSet{
            changeBtn()
        }
    }
    var pageViewController : PagesVC!
    
    var copyView = ActivityView()
    
    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var btn_storeChange: UIButton!
    @IBOutlet weak var btn_addressCopy: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeView.clipsToBounds = true
        storeView.layer.cornerRadius = 30
        storeView.layer.maskedCorners = [.layerMaxXMinYCorner]
        btn_storeChange.layer.cornerRadius = btn_storeChange.frame.height / 2
        btn_addressCopy.layer.cornerRadius = btn_addressCopy.frame.height / 2
        btn_addressCopy.isHidden = true
        
        storBoxH.constant = 50 + (self.tabBarController?.tabBar.frame.height)!
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "ORDER")
        
        let settingItem = UIBarButtonItem(image: UIImage(named: "icon_search"), style: .done, target: self, action: #selector(setSearch(sender:)))
        settingItem.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        self.navigationItem.rightBarButtonItem = settingItem
        
        store.option.removeAll()
        store.option = ["shot":0, "special":0, "decaffein":0, "strong":0, "vanilla":0, "hazel":0, "caramel":0, "pearl":0, "coco":0]
        
        setupCollectionView()
//        UserDefaults.standard.removeObject(forKey: "basket")
        
        if store.storeName == "" {
            label_store.text = "매장 선택 후 주문 가능합니다."
        } else {
            
            label_store.text = store.storeName
            
            if let saveStore = UserDefaults.standard.string(forKey: "storeName") {
                
                if store.storeName == saveStore {
                    
                    if let data = UserDefaults.standard.value(forKey: "basket") as? Data {
                        store.basketArr = try! PropertyListDecoder().decode(Array<BasketModel>.self,from: data)
                        store.storeName = UserDefaults.standard.string(forKey: "storeName")!
                    }
                    
                }
                
            }
            
            btn_addressCopy.isHidden = false
        }
        
        if !store.isStore {
            
            if label_store.text == "매장 선택 후 주문 가능합니다." {
                
                let nearStore = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "NearStore") as! NearStore
                nearStore.modalPresentationStyle = .overFullScreen
                self.present(nearStore, animated: false, completion: nil)
                
            }
            
        }
        
        store.isStore = true
        setBasketBadge()
        
        if store.isPay {
            
            store.isPay = false
            
            let payInfo = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "OrderListDetail") as! OrderListDetail
            payInfo.orderNo = store.orderNo
            self.present(payInfo, animated: true)
            
        }
        
        let currentVC = pageViewController.viewControllers?.first
        currentVC?.viewWillAppear(false)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PageViewController" {
            guard let vc = segue.destination as? PagesVC else {return}
            pageViewController = vc
            
            pageViewController.completeHandler = { (result) in
                self.currentIndex = result
            }
            
        }
        
    }
    
    func setBasketBadge() {
        
        if store.basketArr.count != 0 {
         
            DispatchQueue.main.async {
                
                guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
                
                tabBar.badgeView.isHidden = false
                
                UIView.setAnimationsEnabled(false)
                tabBar.badgeView.setTitle("\(store.basketArr.count)", for: .normal)
                tabBar.badgeView.layoutIfNeeded()
                UIView.setAnimationsEnabled(true)
                
                tabBar.bringSubviewToFront(tabBar.badgeView)
                tabBar.layoutIfNeeded()
                
            }
            
        } else {
            
            DispatchQueue.main.async {
                
                guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
                
                tabBar.badgeView.isHidden = true
                tabBar.bringSubviewToFront(tabBar.badgeView)
                tabBar.layoutIfNeeded()
                
            }
            
        }
        
    }
    
    private func setupCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 5, left: 0, bottom: 5, right: 16)
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(OrderMenuCell.self, forCellWithReuseIdentifier: "OrderMenuCell")
        
        collectionView.layer.masksToBounds = false
        collectionView.layer.shadowColor = UIColor.gray.cgColor
        collectionView.layer.shadowOpacity = 0.1
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowRadius = 2
        
    }
    
    func changeBtn() {
        
        for index in 0..<items.count {
            
            let cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))
            cell?.isSelected = false
            
            if index == currentIndex {
                cell?.isSelected = true
            }
            
//            collectionView.selectItem(at: IndexPath(row: currentIndex, section: 0), animated: true, scrollPosition: .init(rawValue: 100))
        }
        
    }
    
    @objc func setSearch(sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "seachSegue", sender: self)
//        let searchVC = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(identifier: "searchNavigation")
//        searchVC.modalPresentationStyle = .fullScreen
//        self.present(searchVC, animated: true, completion: nil)
        
    }
    
    @IBAction func copyAddress(_ sender: Any) {
        
        UIPasteboard.general.string = store.storeAddress
        AlertUtil().oneItem(self, title: "주소가 복사 되었습니다.", message: store.storeAddress)
//        copyView.copy(self)
//        let activityViewController = UIActivityViewController(activityItems: [store.storeAddress], applicationActivities: nil)
//        present(activityViewController, animated: true, completion: nil)
        
    }
    
}


extension OrderVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        store.orderIndex = indexPath.row
        
        if currentIndex < indexPath.row {
            pageViewController.setViewControllers([pageViewController.VCArray[indexPath.row]], direction: .forward, animated: true, completion: nil)
        } else {
            pageViewController.setViewControllers([pageViewController.VCArray[indexPath.row]], direction: .reverse, animated: true, completion: nil)
        }
        
        currentIndex = indexPath.row
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderMenuCell", for: indexPath) as! OrderMenuCell
        cell.configure(name: items[indexPath.item])
        
        if indexPath.item == currentIndex {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init())
        } else {
            cell.isSelected = false
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return OrderMenuCell.fittingSize(availableHeight: 25, name: items[indexPath.item])
    }
    
}


