//
//  StoreDetail.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/06.
//

import UIKit
import CoreLocation

class StoreDetail: UIViewController, MTMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let header = StoreInfoHeader()
    var networkUtil = NetworkUtil()
    var bookmarkModel: ApiDefaultModel?
    var shopModel: NSDictionary?
    var storyModel: NSDictionary?
    var storys: NSArray?
    var couponModel: NSArray?
    var shop: String?
    var eventArr: [Int] = []
    
    var mapView: MTMapView?
    var currentIndex = 5
    var colorArr = [UIColor.gray, UIColor.blue, UIColor.cyan]
    var collectionTotal: Int = 0
    var locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
//        let StoreInfoCell = UINib(nibName: "StoreInfoCell", bundle: nil)
//       tableView.register(StoreInfoCell, forCellReuseIdentifier: "StoreInfoCell")
        
        currentIndex = 5
        getLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "매장정보")
        navigationController?.isNavigationBarHidden = false
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        getListApi()
        
    }
    
    func getListApi() {
        
        ShowLoading.loadingStart(uiView: self.view)
        
        let cmd = "get_shop_detail"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let lat = latitude!
        let long = longitude!
        let no = store.dummyStroe!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><LATITUDE>\(lat)</LATITUDE><LONGITUDE>\(long)</LONGITUDE><NO>\(no)</NO></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.shopModel = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        ShowLoading.loadingStop()

                        if self.shopModel!["errCode"] as? String == "0000" {

                            if self.currentIndex == 5 {
                                self.currentIndex = 0
                                self.setHeader()
                            }
                            
                            self.tableView.reloadData()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func getStoryApi() {
        
        ShowLoading.loadingStart(uiView: self.view)
        
        let cmd = "get_shop_story"
        let no = store.dummyStroe!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><NO>\(no)</NO></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.storyModel = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    self.storys = self.storyModel!["storyList"] as? NSArray
                    
                    DispatchQueue.main.async {
                        
                        ShowLoading.loadingStop()

                        if self.shopModel!["errCode"] as? String == "0000" {

                            self.tableView.reloadData()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func getCouponApi() {
        
        let cmd = "get_coupon_list"
        let no = store.dummyStroe!
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><NO>\(no)</NO></DATA>"
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
                    self.couponModel = jsonResult["couponList"] as? NSArray
//                    print(self.couponModel)
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            self.tableView.reloadData()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func setHeader() {
        
        header.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: ((355 * view.frame.size.width) / 375) + header.stackView.frame.size.height - 7)
        
        for i in 0..<4 {
            header.buttons[i].addTarget(self, action: #selector(tapedHandler(sender:)), for: .touchUpInside)
        }
        
        header.btn_bookmark.addTarget(self, action: #selector(tapedBookmark(sender:)), for: .touchUpInside)
        header.btn_order.addTarget(self, action: #selector(goOrder(sender:)), for: .touchUpInside)
        
        let shopName = shopModel!["name"] as! String
        let shopAddress1 = shopModel!["addr1"] as! String
        let shopAddress2 = shopModel!["addr2"] as! String
        let shopAddress3 = shopModel!["addr3"] as! String
        let shopTime = shopModel!["time"] as! String
        let shopDist = shopModel!["distance"] as! String
        let shopBookmark = shopModel!["bookmark"] as! String
        let averageAll = shopModel!["average_all"] as! String
        
        let imgs = shopModel!["imgs"] as! NSArray
        
        if imgs.count != 0 {
            
            if let images = imgs[0] as? NSDictionary {
                
                let imgPath = images["imgPath"] as! String
                
                self.loadImage(urlString: imgPath) { image in

                    DispatchQueue.main.async {
                        self.header.image_profile.image = image
                    }

                }
                
            }
            
        } else {
            header.image_profile.image = UIImage(named: "storeProfile")
        }
        
        shop = shopName
        header.label_store.text = shopName
        header.lable_address.text = "\(shopAddress1) \(shopAddress2) \(shopAddress3)"
        header.label_time.text = shopTime
        header.label_dist.text = distanceHandler(dist: shopDist)
        let average = String(format: "%.1f", Float(averageAll)!)
        header.label_star.text = "★ \(average)"

        if shopBookmark == "1" {
            header.btn_bookmark.isSelected = true
        } else {
            header.btn_bookmark.isSelected = false
        }
        
        header.btn_bookmark.tag = Int(store.dummyStroe!)!
        
        tableView.tableHeaderView = header
        
    }
    
    @objc func goOrder(sender: UIButton) {
        guard let tabBar = self.tabBarController?.tabBar as? TabBarVC else { return }
        tabBar.orderButton.setBackgroundImage(UIImage(named: "tb_basket"), for: .normal)
        self.tabBarController?.selectedIndex = 3
    }
    
    @objc func tapedHandler(sender: UIButton) {
        
        header.selectedIndex = sender.tag
        header.setBtns()
        
        self.currentIndex = sender.tag
        
        if currentIndex == 1 {
            getStoryApi()
        } else if currentIndex == 2 {
            getCouponApi()
        }else {
            tableView.reloadData()
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
    
    @objc func downCoupon(sender: UIButton) {
        
        let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "CouponPop") as! CouponPop
        pop.isUser = true
        pop.storeno = store.dummyStroe!
        pop.modalPresentationStyle = .overFullScreen
        self.present(pop, animated: false, completion: nil)
        
    }
    
    
}

extension StoreDetail: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch currentIndex {
         
        case 0:
            return 1
            
        case 1:
            
            var total = 0
            
            if self.storys != nil {
                total  = self.storys!.count
            }
            
//            if total == 0 {
//                tableView.setEmptyView(title: "", message: "스토리가 없습니다.", imageStr: "", imageW: 0, imageH: 0)
//            } else {
//                tableView.restore()
//                tableView.separatorStyle = .none
//            }
            tableView.restore()
            tableView.separatorStyle = .none
            
            return total
            
        case 2:
            
            var total = 0
            
            if couponModel != nil {
                
                var i = 0
                for (index, item) in couponModel!.enumerated() {
                    
                    let obj = item as! NSDictionary
                    let name = obj["menuName"] as! String
                    
                    if name != "" {
                        i += 1
                        eventArr.append(index)
                    }
                    
                }
                
                if i > 2 {
                    total  = i
                }
                
            }
            
//            if total == 0 {
//                tableView.setEmptyView(title: "", message: "이벤트가 없습니다.", imageStr: "", imageW: 0, imageH: 0)
//            } else {
//                tableView.restore()
//                tableView.separatorStyle = .none
//            }
            tableView.restore()
            tableView.separatorStyle = .none

            return total
            
        case 3:
            return 1
            
        case 5:
            return 0
            
        default :
            return 0
            
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentIndex {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreInfoCell", for: indexPath) as! StoreInfoCell
            
            cell.imageArr = shopModel!["imgs"] as? NSArray
            cell.collectionView.reloadData()
            
            mapView = MTMapView(frame: cell.mapView.bounds)
            if let mapView = mapView {
                mapView.delegate = self
                mapView.baseMapType = .standard
                
                let lat = shopModel!["latitude"]!
                let myLat = (lat as! NSString).doubleValue
                let long = shopModel!["longitude"]!
                let myLong = (long as! NSString).doubleValue
                // 지도 중심점, 레벨
                mapView.setMapCenter(MTMapPoint(geoCoord: MTMapPointGeo(latitude: myLat, longitude: myLong)), zoomLevel: 1, animated: true)
                // 마커 추가
                let poiItem = MTMapPOIItem()
                poiItem.markerType = .bluePin
                poiItem.mapPoint = MTMapPoint(geoCoord: MTMapPointGeo(latitude: myLat, longitude: myLong))
                poiItem.itemName = shopModel!["addr1"] as? String
                poiItem.showAnimationType = .noAnimation
                mapView.add(poiItem)
                
                cell.mapView.addSubview(mapView)
            }
            
            cell.total = 3
            cell.collectionView.reloadData()
            
            cell.selectionStyle = .none
            return cell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreStory", for: indexPath) as! StoreStory
            let obj = self.storys![indexPath.row] as! NSDictionary
            let date = obj["date"] as! String
            let content = obj["content"] as! String
            let imgs = obj["imgs"] as! NSArray
            
            cell.imgArr = imgs
            
            if imgs.count > 0 {
                cell.collectionView.isHidden = false
            } else {
                cell.collectionView.isHidden = true
            }
            
            cell.label_name.text = shop
            cell.label_date.text = date
            cell.label_content.text = content
            
            cell.selectionStyle = .none
            return cell
            
        case 2:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreEvent", for: indexPath) as! StoreEvent
            let obj = self.couponModel![eventArr[indexPath.row]] as! NSDictionary
            let menuImgPath = obj["menuImgPath"] as! String
            let menuName = obj["menuName"] as! String
            let menuEngName = obj["menuEngName"] as! String
            let discountPart = obj["discountPart"] as! String
            let discountPercent = obj["discountPercent"] as! String
            let discountPrice = obj["discountPrice"] as! String
            
            cell.label_name.text = menuName
            cell.label_name_en.text = menuEngName
            
            self.loadImage(urlString: menuImgPath) { image in

                DispatchQueue.main.async {
                    cell.image_thum.image = image
                }

            }
            
            if discountPart == "0" {
                cell.label_event.text = "\(discountPercent)%"
            } else {
                cell.label_event.text = "\(discountPrice)원 ↓"
            }
            
            cell.selectionStyle = .none
            return cell
            
        case 3:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoreStarpoint", for: indexPath) as! StoreStarpoint
            let averageKind = shopModel!["average_kind"] as! String
            let averageTime = shopModel!["average_time"] as! String
            let averageSanitation = shopModel!["average_sanitation"] as! String
            let averageAll = shopModel!["average_all"] as! String
            let averageCnt = shopModel!["average_cnt"] as! String
            let arr = [averageKind, averageTime, averageSanitation]
            
            for i in 0..<3 {
                cell.progress[i].progress = Float(arr[i])! / 5
                cell.labels[i].text = String(format: "%.1f", Float(arr[i])!)
            }
            
            cell.label_total.text = "[ 참여 \(averageCnt)명 ]"
            cell.label_totalStarpoint.text = String(format: "%.1f", Float(averageAll)!)
            
            cell.selectionStyle = .none
            return cell
            
        default :
            break
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoreInfoCell", for: indexPath) as! StoreInfoCell
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var returnedView: UIView?
        
        switch currentIndex {
            
        case 0:
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0))
            return returnedView
            
        case 1:
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
            
            let label = UILabel(frame: CGRect(x: 20, y: 15, width: view.frame.size.width, height: 14))
            label.font = UIFont(name: "Pretendard-Medium", size: 12)
            label.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
            
            let attributedString = NSMutableAttributedString(string: "")
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(named: "icon_story")
            attributedString.append(NSAttributedString(attachment: imageAttachment))
            attributedString.append(NSAttributedString(string: "  매장 스토리를 확인해 보세요."))
            label.attributedText = attributedString
            
            returnedView!.addSubview(label)
            
            return returnedView
            
        case 2:
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 117))
            
            let btn = UIButton(frame: CGRect(x: 20, y: 20, width: view.frame.size.width - 40, height: 40))
            btn.setImage(UIImage(named: "btn_coupon"), for: .normal)
            btn.addTarget(self, action: #selector(downCoupon(sender:)), for: .touchUpInside)
            returnedView!.addSubview(btn)
            
            let label = UILabel(frame: CGRect(x: 20, y: 80, width: view.frame.size.width, height: 20))
            label.font = UIFont(name: "Pretendard-SemiBold", size: 18)
            label.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
            label.textAlignment = .left
            label.text = "이벤트 메뉴"
            
            returnedView!.addSubview(label)
            
            return returnedView
            
        case 3:
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0))
            return returnedView
            
        default :
            returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0))
            return returnedView
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch currentIndex {
            
        case 0:
            return 0
            
        case 1:
            return 25
            
        case 2:
            return 117
            
        case 3:
            return 0
            
        default :
            return 0
            
        }
        
    }
    
}



