//
//  StoreSelectVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/12.
//

import UIKit
import CoreLocation

class StoreSelectVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private let items: [String] = ["가까운매장", "전체매장", "자주가는매장"]
    let emptyTitle: [String] = ["근처에 가까운 매장이 없습니다.", "검색된 매장이 없습니다.", "등록된 매장이 없습니다."]
    let emptyMessage: [String] = ["다른 매장을 선택해 주새요 :)", "다른 매장을 선택해 주새요 :)", "자주 가는 매장으로 등록하시면 편리하게 이용 가능합니다 :)"]
    
    var isSearch: Bool = false
    var currentIndex : Int = 0 {
        didSet{
            isSearch = false
//            searchBar.text = ""
            changeBtn()
        }
    }
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var shopListModel: NSArray?
    var locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    var strPart: String = "S"
    var strShop: String = ""
    
    var bookmarkModel: ApiDefaultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        searchBar.delegate = self
        
        initRefresh()
    }
    
    func initRefresh() {
        
        refresh.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        self.tableView.refreshControl = refresh
        
    }
     
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        print("refreshTable")
        getLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultTheme(self.navigationController, selfView: self, title: "주문 매장 선택")

        setupCollectionView()
        getLocation()
        setBasketBadge()
    }
    
    func getLocation() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        switch authorizationStatus {
            
            case .authorizedAlways, .authorizedWhenInUse:
                break
            case .restricted, .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                locationManager.requestWhenInUseAuthorization()
            @unknown default:
                return
            
        }
        
        locationManager.startUpdatingLocation()
        let coor = locationManager.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude
        
        getListApi(part: strPart)
        
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
            
            if index == currentIndex && !isSearch {
                cell?.isSelected = true
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

    @IBAction func touchSearchIcon(_ sender: Any) {
        
        self.view.endEditing(true)
        searchApi()
    }
    
    func searchApi() {
        
//        if searchBar.text != "" {
//            isSearch = true
//            changeBtn()
//        }
        
        if searchBar.text != "" {
            strPart = "A"
            strShop = searchBar.text!
            currentIndex = 1
        } else {
            strShop = ""
        }
        
        getLocation()
        
    }
    
    func getListApi(part: String) {
        
        locationManager.stopUpdatingLocation()
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_shop_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let lat = latitude!
        let long = longitude!
        let shop = strShop
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><LATITUDE>\(lat)</LATITUDE><LONGITUDE>\(long)</LONGITUDE><SHOPNAME>\(shop)</SHOPNAME><PART>\(part)</PART></DATA>"
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
                    self.shopListModel = jsonResult["shopList"] as? NSArray
                    
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
    
    func distanceHandler(dist: String) -> String {
        
        var strDist = ""
        
        let intDist = Double(dist)
        let dist = round(intDist! * 10) / 10
        
        if dist < 1 {
            strDist = "\(Int(dist * 1000))m"
        } else if dist == 0.0 {
            strDist = "100m 이내"
        } else {
            strDist = "\(dist)km"
        }
        
        return strDist
        
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
        
        let cmd = "set_bookmark_shop"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let no = String(sender.tag)
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
    
}

extension StoreSelectVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        currentIndex = indexPath.row
        
        switch currentIndex {
            
        case 0:
            strPart = "S"
            break
            
        case 1:
            strPart = "A"
            break
            
        case 2:
            strPart = "B"
            break
            
        default :
            break
            
        }
        
        searchBar.text = ""
        strShop = ""
        getLocation()
        
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

extension StoreSelectVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.shopListModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: emptyTitle[currentIndex], message: emptyMessage[currentIndex], imageStr: "icon_location_L", imageW: 32, imageH: 42)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = self.shopListModel![indexPath.row] as! NSDictionary
        let shopAddress1 = obj["addr1"] as! String
        let shopAddress2 = obj["addr2"] as! String
        let shopAddress3 = obj["addr3"] as! String
        
        store.dummyName = obj["name"] as? String
        store.dummyAddress = "\(shopAddress1) \(shopAddress2) \(shopAddress3)"
        store.dummyTime = obj["time"] as? String
        store.dummyDist = obj["distance"] as? String
        store.dummyDist = distanceHandler(dist: store.dummyDist!)
        store.dummyImg = obj["imgs"] as? NSArray
        store.dummyNo = obj["idx"] as? String
        store.dummybillpayId = obj["billPayID"] as? String
        store.dummybillpayPW = obj["billPayPWD"] as? String
        
        let detailPop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "DetailStore") as! DetailStore
        detailPop.modalPresentationStyle = .overFullScreen
        self.present(detailPop, animated: false, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreCell", for: indexPath) as! StoreCell
        let obj = self.shopListModel![indexPath.row] as! NSDictionary
        let shopName = obj["name"] as! String
        let shopAddress = obj["addr1"] as! String
        let shopTime = obj["time"] as! String
        let shopDist = obj["distance"] as! String
        let shopBookmark = obj["bookmark"] as! String
        let shopNo = obj["idx"] as! String
        let imgs = obj["imgs"] as! NSArray
        
        if imgs.count != 0 {
            
            if let images = imgs[0] as? NSDictionary {
                
                let imgPath = images["imgPath"] as! String
                
                self.loadImage(urlString: imgPath) { image in

                    DispatchQueue.main.async {
                        cell.store_image.image = image
                    }

                }
                
            }
            
        } else {
            cell.store_image.image = UIImage(named: "default")
        }
        
        cell.store_name.text = shopName
        cell.store_address.text = shopAddress
        cell.store_time.text = shopTime
        cell.store_dist.text = distanceHandler(dist: shopDist)

        if shopBookmark == "1" {
            cell.btn_pin.isSelected = true
        } else {
            cell.btn_pin.isSelected = false
        }
        
        cell.btn_pin.addTarget(self, action: #selector(tapedBookmark(sender:)), for: .touchUpInside)
        cell.btn_pin.tag = Int(shopNo)!
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "주문 시 매장 위치를 확인해 주세요 :)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           
        let icon = UIImageView()
        icon.image = UIImage(named: "icon_store_section")
        icon.frame = CGRect(x: 20, y: 18, width: 11, height: 14)
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 32, y: 15, width: 320, height: 20)
        myLabel.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x4B4B4B)
        myLabel.font = UIFont(name: "Pretendard-Regular", size: 14)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)

        let headerView = UIView()
        headerView.backgroundColor = .white
        
        headerView.addSubview(icon)
        headerView.addSubview(myLabel)

        return headerView
    }
    
}

extension StoreSelectVC: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      searchApi()
    return true
  }
}

