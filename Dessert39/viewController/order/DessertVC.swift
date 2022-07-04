//
//  DessertVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/05.
//

import UIKit
import SnapKit

class DessertVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
//    private let items: [String] = ["케이크", "홀케이크", "베이커리", "도쿄롤", "오믈렛", "마카롱"]
    var items: [String] = []
    var code: [String] = []
    var currentIndex : Int = 0 {
        didSet{
            changeBtn()
        }
    }
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var cateModel: NSArray?
    var cates: NSArray?
    var menuListModel: Array<NSDictionary> = []
    var storeIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        initRefresh()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        setupView()
        
        if items.count > 0 {
            getListApi()
        } else {
            getCateApi()
        }
        
        setFooter()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuListModel.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.menuListModel[indexPath.row]
        let status = obj["status"] as! String
        store.dummyItemNo = obj["no"] as? String
        
        if status == "정상" {
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
        }
//        performSegue(withIdentifier: "detailSegue", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderItemCell
        let obj = self.menuListModel[indexPath.row]
        let menuName = obj["name"] as! String
        let menuNameEn = obj["eng_name"] as! String
        let menuPrice = obj["price_dessert"] as! String
        let status = obj["status"] as! String
        var imgPath = obj["imgHot"] as! String
        
        if imgPath == "" {
            imgPath = obj["imgIce"] as! String
        }
        
        self.loadImage(urlString: imgPath) { image in

            DispatchQueue.main.async {
                cell.item_image.image = image
            }

        }
        
        cell.item_name.text = menuName
        cell.item_anme_en.text = menuNameEn
        cell.item_price.text = "\(menuPrice)원"
        
        if status != "정상" {
            cell.soldout.isHidden = false
        } else {
            cell.soldout.isHidden = true
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func setFooter() {
        
        let foot = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        tableView.tableFooterView = foot
        
    }
    
    func setupView() {
        view.backgroundColor = .white
        setupCollectionView()
    }
        
    func setupCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .init(top: 10, left: 20, bottom: 15, right: 16)
        
        collectionView.setCollectionViewLayout(flowLayout, animated: false)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        
    }
    
    
    func changeBtn() {
        
        for index in 0..<items.count {
            let cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0))
            cell?.isSelected = false
            
            if index == currentIndex {
                cell?.isSelected = true
            }
        }
        
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
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        networkUtil.request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_goods_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let cate = store.orderIndex!
        let cate2 = code[storeIndex]
        let name = ""
        let shopNo = store.storeNo ?? ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><CATE>\(cate)</CATE><CATE2>\(cate2)</CATE2><NAME>\(name)</NAME><SHOPNO>\(shopNo)</SHOPNO></DATA>"
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
                    self.menuListModel = (jsonResult["goodsList"] as? Array)!
                    
                    DispatchQueue.main.async {
                        
                        if !self.refresh.isRefreshing {
                            ShowLoading.loadingStop()
                        }

                        if jsonResult["errCode"] as? String == "0000" {
//                            self.tableView.contentOffset = .zero
                            self.setModel()
//                            self.tableView.reloadData()
                            self.refresh.endRefreshing()
                            

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func getCateApi() {
        
        let cmd = "goods_cate"

        let strCode: String = "<CMD>\(cmd)</CMD>"
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
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.cateModel = jsonResult["cateList"] as? NSArray
                            let obj = self.cateModel![0] as! NSDictionary
                            self.cates = obj["subCates"] as? NSArray
                            
                            self.makeItems()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func makeItems() {
        
        for i in 0..<self.cates!.count {
            
            let item = self.cates![i] as! NSDictionary
            let subCates = item["subName"] as! String
            let subOrder = item["subOrder"] as! String
            let subNo = item["subNo"] as! String
            
            items.insert(subCates, at: Int(subOrder)!)
            code.insert(subNo, at: Int(subOrder)!)
            
        }
       
        self.setupView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.getListApi()
        }
        
    }
    
    func setModel() {
        
        for (index,item) in menuListModel.enumerated() {
            
            let obj = item
            let hotGrande = obj["price_hot_grande"] as! String
            let hotVenti = obj["price_hot_venti"] as! String
            let hotLarge = obj["price_hot_large"] as! String
            let iceGrande = obj["price_ice_grande"] as! String
            let iceVenti = obj["price_ice_venti"] as! String
            let iceLarge = obj["price_ice_large"] as! String
            let dessert = obj["price_dessert"] as! String
            
            let arr = [hotGrande, hotVenti, hotLarge, iceGrande, iceVenti, iceLarge, dessert]
            
            var i = 0
            for item in arr {
                
                if item != "0" {
                    break
                }
                
                i += 1
                
            }
            
            if i == 7 {
                menuListModel.remove(at: index)
                setModel()
                break
            }
            
        }
        
        self.tableView.reloadData()

    }
        
}


extension DessertVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if storeIndex != indexPath.row {
            storeIndex = indexPath.row
            getListApi()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
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
        return CollectionViewCell.fittingSize(availableHeight: 30, name: items[indexPath.item])
    }
    
}

final class CollectionViewCell: UICollectionViewCell {
    
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = CollectionViewCell()
        cell.configure(name: name)
        
        let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderColor = isSelected ? UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor :UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            titleLabel.textColor = isSelected ? UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C) : UIColorFromRGB.colorInit(1.0, rgbValue: 0x4b4b4b)
            
        }
    }
    
    private func setupView() {
        
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x4b4b4b)
        titleLabel.font = UIFont(name: "Pretendard-Medium", size: 12)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(10)
        }
        
    }
    
    func configure(name: String?) {
        titleLabel.text = name
    }
    
}

