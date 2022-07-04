//
//  HomeVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/27.
//

import UIKit
import CoreLocation
import SnapKit

struct Slice {
    var percent: CGFloat
    var color: UIColor
}

class HomeVC: UIViewController, CLLocationManagerDelegate {

// MARK: - personal area Variable
    @IBOutlet var personalView: UIView!
    @IBOutlet weak var perWeatherImage: UIImageView!
    @IBOutlet weak var perWeatherIconView: UIView!{
        didSet{
            perWeatherIconView.isHidden = true
        }
    }
    @IBOutlet weak var perWeatherIcon: UIImageView!
    @IBOutlet weak var perWeatherTop: NSLayoutConstraint!
    @IBOutlet weak var perBoxView: UIView!
    @IBOutlet weak var perNameLabel: UILabel!
    @IBOutlet weak var perRecommendlabel: UILabel!
    @IBOutlet weak var perCouponLabel: UILabel!
    @IBOutlet weak var perPointLabel: UILabel!
    @IBOutlet weak var perRewardLabel: UILabel!
    @IBOutlet var perRewardTotal: UILabel!
    @IBOutlet weak var perLineDrawView: UIView!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet var gradientView: UIView!
    var gradientLayer: CAGradientLayer!
    @IBOutlet var couponImage: UIImageView!
    @IBOutlet var pointImage: UIImageView!
    
// MARK: - User recommend area Variable
    @IBOutlet weak var userReTitle: UILabel!
    @IBOutlet weak var userReCollectionView: UICollectionView!
    @IBOutlet weak var userReBanner: UIImageView!
    
    @IBOutlet var eventTop: NSLayoutConstraint!
    @IBOutlet var realTimeView: UIView!
    
    // MARK: - Real time popularity Variable
    @IBOutlet weak var tableView: UITableView!
    
    struct ExpendModel {
        var isExpend: Bool
    }
    
    var dataModels = [ExpendModel]()
    var selected: IndexPath = IndexPath(row: 0, section: 0)
    var timer: Timer?

    var jsonResult: NSDictionary?
    var recommendModel: NSArray?
    var bannerModel: NSArray?
    var dayModel: NSArray?
    var weekModel: NSArray?
    var monthModel: NSArray?
    var eventModel: NSArray?
    var weatherModel: NSArray?
    
    let eventEmptyText = ["진행중인 이벤트&캠페인이 없습니다", "즐거운 이벤트&캠페인으로 만나요!"]
    let realArr = ["TODAY", "WEEK", "MONTH"]
    let weatherArr = ["Clear", "Cloudy", "Rain", "Snow"]
    let weatherIcon = ["icon_clear", "icon_cloudy", "icon_rain", "icon_snow"]
    let weatherStr = ["디저트39와 함께 즐거운 하루 보내세요!", "구름이 많은 오후엔 구름을 닮은 카푸치노 한잔 어떠세요?", "비오는 오후, 따뜻한 커피 한잔 어떠세요?", "눈내리는 오후, 따뜻한 커피 한잔 어떠세요?"]
    var weatherInt: Int = 0
    
    var isRe: Bool = false
    
// MARK: - Event & campaign Variable
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
    
    @IBOutlet weak var drCollectionView: UICollectionView!
    @IBOutlet weak var drView: UIView!
    var pageControl = UIPageControl()
    var curIndex = 0 {
        didSet{
            pageControl.currentPage = curIndex
        }
    }
    
    let ANIMATION_DURATION: CGFloat = 1.4
    
    var slices: [Slice]?
    var sliceIndex: Int = 0
    var currentPercent: CGFloat = 0.0
    
    var rewardNum: CGFloat = 50
    var rewardTotal: Int = 10
    var user: String = "고객"
    var drawTimer:Timer?
    var timeLeft = 0
    
    var locationManager: CLLocationManager!
    var latitude: Double?
    var longitude: Double?
    
    
    @IBOutlet weak var userRecommendView: UIView!
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet var scrollviewTop: NSLayoutConstraint!
    
//    var userRecommendXib: HomeUserRecommendView?
    
    let refresh = UIRefreshControl()
    var isRefresh: Bool = false
    
    var loginType: String?
    var scrollY: CGFloat?
    var networkUtil = NetworkUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollview.delegate = self
        initRefresh()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
//        tableView.delegate = self
//        tableView.dataSource = self
//
//        tableView.separatorInset.left = 0
        
        pointImage.isHidden = true

    }
    
    func initRefresh() {
        
        refresh.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        self.scrollview.refreshControl = refresh
        
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        print("refreshTable")
        isRefresh = true
        setLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "ORDER")
        navigationController?.isNavigationBarHidden = true
        
        
        
//        latitude = 37.53399658203125
//        longitude = 126.63675651362709
//        setAddress()
        
        if !isRe {
            setLocation()
        }
        
        if isRe {
            isRe = false
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollviewTop.constant = -((view.window?.windowScene?.statusBarManager?.statusBarFrame.height)!)
        
        if scrollviewTop.constant == -44 {
            scrollviewTop.constant = -50
        }
        
        scrollY = scrollviewTop.constant
        
        perWeatherTop.constant = -(scrollviewTop.constant)
        
//        UserDefaults.standard.removeObject(forKey: "isTaste")
        let status = UserDefaults.standard.bool(forKey: "isTaste")
        
        if !status {
            
            let tastePop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "TasteInfo")
            tastePop.modalPresentationStyle = .overFullScreen
            self.present(tastePop, animated: true)
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            
            case .authorizedAlways, .authorizedWhenInUse:
                break
            case .restricted, .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .denied:
                showAuthoriaztionDeninedAlert()
            @unknown default:
                return
            
        }
        
        setLocation()
        
    }
    
// MARK: - get Loaction
    func setLocation() {
        print("------------------")
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
//        locationManager.requestWhenInUseAuthorization()
//
//        let authorizationStatus: CLAuthorizationStatus
//
//        if #available(iOS 14, *) {
//            authorizationStatus = locationManager.authorizationStatus
//        } else {
//            authorizationStatus = CLLocationManager.authorizationStatus()
//        }
//
//        switch authorizationStatus {
//
//            case .authorizedAlways, .authorizedWhenInUse:
//                break
//            case .restricted, .notDetermined:
//                showAuthoriaztionDeninedAlert()
//            case .denied:
//                showAuthoriaztionDeninedAlert()
//            default:
//                return
//
//        }
        
        locationManager.startUpdatingLocation()
        let coor = locationManager.location?.coordinate
        latitude = coor?.latitude
        longitude = coor?.longitude

        setAddress()
        
    }
    
    func showAuthoriaztionDeninedAlert() {
        
        ShowLoading.loadingStop()
        
        let alert = UIAlertController(title: "내 위치 확인을 위해 권한이 필요합니다", message: nil, preferredStyle: .alert)
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
    
    func setAddress() {
        
        locationManager.stopUpdatingLocation()
        
        guard let lat = latitude else { return }
        guard let long = longitude else { return }
        
        let findLocation = CLLocation(latitude: lat, longitude: long)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        geocoder.reverseGeocodeLocation(findLocation, preferredLocale: locale, completionHandler: {(placemarks, error) in
            
            let address = placemarks![0]
            guard let city = address.administrativeArea else {
                
                self.locationError()
                return
                
            }
            guard let gugun = address.locality else {
                
                self.locationError()
                return
                
            }
            
            self.getListApi(city: city, gugun: gugun)
                    
        })
        
    }
    
    func locationError() {
        
        ShowLoading.loadingStop()
        
        let alert = UIAlertController(title: "위치를 가져오지 못했습니다.", message: "앱을 다시 실행해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
            
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getMemberApi() {
        
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
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if jsonResult["errCode"] as? String == "0000" {

                            store.hp = jsonResult["hp"] as? String
                            
                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
            }
            
        }
        
    }
    
    func getListApi(city: String, gugun: String) {
        
        let cmd = "main"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let city = city
        let gugun = gugun
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><CITY>\(city)</CITY><GUGUN>\(gugun)</GUGUN></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    self.jsonResult = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    
                    DispatchQueue.main.async {
                        
                        if self.jsonResult!["errCode"] as? String == "0000" {
                            
                            if !self.refresh.isRefreshing {
                                ShowLoading.loadingStop()
                            }
                            
                            self.refresh.endRefreshing()
                            
                            self.recommendModel = self.jsonResult!["recommendList"] as? NSArray
                            self.bannerModel = self.jsonResult!["bannerList"] as? NSArray
                            self.dayModel = self.jsonResult!["popularDayList"] as? NSArray
                            self.weekModel = self.jsonResult!["popularWeekList"] as? NSArray
                            self.monthModel = self.jsonResult!["popularMonthList"] as? NSArray
                            self.eventModel = self.jsonResult!["eventList"] as? NSArray
                            self.weatherModel = self.jsonResult!["weatherList"] as? NSArray
                            
                            self.setStore()
                            self.getMemberApi()
                            
                        } else {
                            
                            if !self.refresh.isRefreshing {
                                ShowLoading.loadingStop()
                            }
                            
                            let alert = UIAlertController(title: "토큰이 만료 되었습니다", message: "다시 로그인 해주세요.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in
                                
                                UserDefaults.standard.removeObject(forKey: "loginToken")
                                Switcher.updateRootVC()
//                                let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
//                                let navigationController = UINavigationController(rootViewController: vc)
//
//                                navigationController.modalPresentationStyle = .fullScreen
//                                self.present(navigationController, animated: false)
                                
                            }))
                            
                            self.present(alert, animated: true, completion: nil)
                            
//                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
                            
                        }
                        
                    }
                    
                } catch {
                    print("JSONDecoder Error : \(error)")
                }
            }
            
        }
        
    }
    
    func setStore() {
        
        store.id = jsonResult!["userID"] as? String
        store.name = jsonResult!["userName"] as? String
        store.nick = jsonResult!["userNick"] as? String
        store.userCardNo = jsonResult!["userCardNo"] as? String
        store.userCardPath = jsonResult!["userCardPath"] as? String
        store.userCash = jsonResult!["userCash"] as? String
        store.userPoint = jsonResult!["userPoint"] as? String
        store.userReward = jsonResult!["userReward"] as? String
        store.userLevelName = jsonResult!["userLevelName"] as? String
        store.userImg = jsonResult!["userImg"] as? String
        store.couponList = jsonResult!["couponList"] as? NSArray
        
        for i in 0..<4 {
            
            if weatherArr[i] == jsonResult!["weather"] as? String {
                self.weatherInt = i
            }
            
        }
        
        setPersonal()
        setUserRecommend()
        setRealtime()
        setEventCampaign()
        setDessertRecommend()
        
//        if isRefresh {
//            print("================")
//            scrollviewTop.constant = -((view.window?.windowScene?.statusBarManager?.statusBarFrame.height)!)
//
//            if scrollviewTop.constant == -44 {
//                scrollviewTop.constant = -50
//            }
//
//            scrollY = scrollviewTop.constant
//
//            perWeatherTop.constant = -(scrollviewTop.constant)
//
//        }
    }
    
// MARK: - personal area setting
    func setPersonal() {
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.gradientView.bounds
        gradientLayer.colors = [UIColorFromRGB.colorInit(0.0, rgbValue: 0xFFFFFF).cgColor, UIColorFromRGB.colorInit(1.0, rgbValue: 0xFFFFFF).cgColor, UIColorFromRGB.colorInit(1.0, rgbValue: 0xFFFFFF).cgColor]
        gradientView.layer.addSublayer(gradientLayer)
        
//        gradientView.isHidden = true
        
        rewardNum = CGFloat((store.userReward! as NSString).floatValue)
        self.canvasView.layer.sublayers = nil
        
        if rewardNum < 10 {
            rewardTotal = 10
            perRewardTotal.isHidden = false
            rewardImageView.image = UIImage(named: "reward/0")
        }
        
        if rewardNum > 9 {
            rewardTotal = 30
            perRewardTotal.isHidden = false
            rewardImageView.image = UIImage(named: "reward/1")
        }
        
        if rewardNum > 29 {
            rewardTotal = 50
            perRewardTotal.isHidden = false
            rewardImageView.image = UIImage(named: "reward/2")
        }
        
        if rewardNum > 49 {
            rewardTotal = 100
            perRewardTotal.isHidden = false
            rewardImageView.image = UIImage(named: "reward/3")
        }
        
        if rewardNum > 99 {
            rewardTotal = Int(rewardNum)
            perRewardTotal.isHidden = true
            rewardImageView.image = UIImage(named: "reward/4")
        }
        
        perRewardTotal.text = "/ \(rewardTotal)"
        
        slices = [Slice(percent: rewardNum / CGFloat(rewardTotal), color: UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000))]
        
        perBoxView.layer.cornerRadius = 35
        
        perWeatherImage.image = UIImage(named: weatherArr[weatherInt])
        perWeatherIconView.layer.cornerRadius = perWeatherIconView.frame.height / 2
        
        perWeatherIcon.animationImages = animatedImages(for: weatherIcon[weatherInt])
        perWeatherIcon.animationDuration = 0.8
        perWeatherIcon.animationRepeatCount = 0
        perWeatherIcon.image = perWeatherIcon.animationImages?.first
        perWeatherIcon.startAnimating()
        
        if store.nick != "" {
            
            let nick: String = store.nick!
            perNameLabel.text = "\(nick)님 반가워요"
            
        } else if store.name != "" {
            
            let name: String = store.name!
            perNameLabel.text = "\(name)님 반가워요"
            
        } else {
            
            let id: String = store.nick!
            perNameLabel.text = "\(id)님 반가워요"
            
        }
        
        perRecommendlabel.text = weatherStr[weatherInt]
        let coupon: Int = store.couponList?.count ?? 0
        perCouponLabel.text = "\(coupon)"
//        let point: String = store.userPoint ?? "0"
//        perPointLabel.text = point
        pointImage.isHidden = true
        perPointLabel.text = ""
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(couponTapped))
        couponImage.isUserInteractionEnabled = true
        couponImage.addGestureRecognizer(tapGestureRecognizer)
        
        let wid = self.perLineDrawView.frame.width
        perLineDrawView.frame.size.width = 0
        
        UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseIn) {
            
            self.perLineDrawView.frame.size.width = wid
            
        } completion: { finished in
            
            self.animateChart()
            
        }
        
    }
    
    @objc func couponTapped(sender: UITapGestureRecognizer) {
        
        let detail = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "Coupon")
        self.navigationController?.pushViewController(detail, animated: true)
        
    }
    
// MARK: - User recommend area setting
    func setUserRecommend() {
        
        if store.nick != "" {
            
            let nick: String = store.nick!
            userReTitle.text = "\(nick)님 추천 메뉴"
            
        } else if store.name != "" {
            
            let name: String = store.name!
            userReTitle.text = "\(name)님 추천 메뉴"
            
        } else {
            
            let id: String = store.nick!
            userReTitle.text = "\(id)님 추천 메뉴"
            
        }
        
        let obj = self.bannerModel![0] as! NSDictionary
        let imgs = obj["bannerPath"] as! String
        self.loadImage(urlString: imgs) { image in

            DispatchQueue.main.async {
                self.userReBanner.image = image
            }

        }
        
        if isRefresh {
            userReCollectionView.reloadData()
        } else {
        
            let wid = UIScreen.main.bounds.width / 4.0
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: wid, height: (UIScreen.main.bounds.width * 130) / 375)
            layout.minimumInteritemSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            layout.scrollDirection = .horizontal
            
            userReCollectionView.delegate = self
            userReCollectionView.collectionViewLayout = layout
            userReCollectionView.dataSource = self
            
        }

    }
    
// MARK: - Real time popularity area setting
    func setRealtime() {
        
        if monthModel!.count < 3 || weekModel!.count < 3 || dayModel!.count < 3 {
            
            eventTop.constant = -(realTimeView.frame.height - 20)
            
        } else {
//            tableView.reloadData()
            
            if isRefresh {
                tableView.reloadData()
            } else {
                
                tableView.delegate = self
                tableView.dataSource = self

                tableView.separatorInset.left = 0
                
                if dataModels.count != 3 {
                    for i in 0..<3 {
                        
                        if i == 0 {
                            dataModels.append(ExpendModel.init(isExpend: true))
                        } else {
                            dataModels.append(ExpendModel.init(isExpend: false))
                        }
                        
                    }
                }
                
//                print(dataModels)
                //          timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(callTimer), userInfo: nil, repeats: true)
                
            }
            
        }

    }
    
    @objc func callTimer() {
        
        let r = selected.row
        var ro = r + 1
        
        if ro == 3 {
            ro = 0
        }
        
        dataModels[selected.row].isExpend = false
        tableView.reloadRows(at: [selected], with: .automatic)
        
        selected.row = ro
    
        dataModels[selected.row].isExpend = true
        tableView.reloadRows(at: [selected], with: .automatic)
        
    }
   
// MARK: - Event & Campaign area setting
    func setEventCampaign() {
        
        if isRefresh {
            eventCollectionView.reloadData()
        } else {
        
            let wid = UIScreen.main.bounds.width / 1.6 - 20
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: wid, height: (wid * 108) / 197)
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            
            eventCollectionView.delegate = self
            eventCollectionView.collectionViewLayout = layout
            eventCollectionView.dataSource = self
            
        }
        
    }
    
// MARK: - Dessert39 recommend area setting
    func setDessertRecommend() {
        
        if isRefresh {
            drCollectionView.reloadData()
        } else {
            
            let wid = UIScreen.main.bounds.width - 40
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: wid, height: (wid * 335) / 169)
            layout.minimumLineSpacing = 0
            layout.scrollDirection = .horizontal
            
            drCollectionView.collectionViewLayout = layout
            drCollectionView.dataSource = self
            drCollectionView.delegate = self
            drCollectionView.layer.cornerRadius = 10
            drCollectionView.clipsToBounds = true
            
            setPageController()
            
        }
        
    }
    
    func setPageController() {
        
        if isRefresh {
           //
        } else {
            drView.addSubview(pageControl)
        }
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        pageControl.pageIndicatorTintColor = UIColorFromRGB.colorInit(0.48, rgbValue: 0xffffff)
        pageControl.numberOfPages = weatherModel?.count ?? 0
        pageControl.currentPage = 0
        pageControl.bottomAnchor.constraint(equalTo: drView.safeAreaLayoutGuide.bottomAnchor, constant: -60).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: drView.centerXAnchor).isActive = true
        
    }
    
// MARK: - Weather icon animation
    func animatedImages(for name: String) -> [UIImage] {
        var i = 0
        var images = [UIImage]()
        
        while let image = UIImage(named: "\(name)/\(i)") {
            images.append(image)
            i += 1
        }
        return images
    }
    
// MARK: - Reward line Draw
    func getDuration(_ slice: Slice) -> CFTimeInterval {
        return CFTimeInterval(slice.percent / 1.0 * self.ANIMATION_DURATION)
    }
    
    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        
        //Because angle starts wtih X positive axis, add 270 degrees to rotate it to Y positive axis.
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        
        return angle * CGFloat.pi / 180.0
        
    }
    
    func addSlice(_ slice: Slice) {
        print("draw circle")
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = self.getDuration(slice)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        
        let canvasWidth = self.canvasView.frame.width
        let path = UIBezierPath(arcCenter: CGPoint(x: self.canvasView.frame.size.width  / 2, y: self.canvasView.frame.size.height / 2),
                                radius: canvasWidth / 2,
                                startAngle: self.percentToRadian(self.currentPercent),
                                endAngle: self.percentToRadian(self.currentPercent + slice.percent),
                                clockwise: true)
        
        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = slice.color.cgColor
        sliceLayer.lineWidth = 2
        sliceLayer.strokeEnd = 1
        sliceLayer.add(animation, forKey: animation.keyPath)
        
        self.canvasView.layer.addSublayer(sliceLayer)
        
    }
    
    @objc func onTimerFires() {
        
        timeLeft += 1
        
        if timeLeft < 10 {
            self.perRewardLabel.text = "0\(timeLeft)"
        } else {
            self.perRewardLabel.text = "\(timeLeft)"
        }
        
        if timeLeft >= Int(self.slices![0].percent * CGFloat(self.rewardTotal)) {
            drawTimer?.invalidate()
            drawTimer = nil
        }
        
    }
    
    func animateChart() {
        
        self.sliceIndex = 0
        self.currentPercent = 0.0
        self.canvasView.layer.sublayers = nil
        
        if self.slices != nil && self.slices!.count > 0 {
            
            let firstSlice = self.slices![0]
            self.addSlice(firstSlice)
            
        }
        
        if drawTimer == nil {
            
            timeLeft = 0
            if rewardNum > 0 {
                drawTimer = Timer.scheduledTimer(timeInterval: (self.getDuration(self.slices![0]) / rewardNum), target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
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
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    @objc func realTimeTaped(sender: UITapGestureRecognizer) {
        
        let no = sender.view?.tag
        store.dummyItemNo = "\(no!)"
        
        let detail = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(identifier: "DetailVC")
        self.navigationController?.pushViewController(detail, animated: true)
        
    }
    
}

// MARK: - Extension
extension HomeVC: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            currentPercent += slices![sliceIndex].percent
            sliceIndex += 1
            if sliceIndex < slices!.count {
                let nextSlice = slices![sliceIndex]
                addSlice(nextSlice)
            }
        }
    }
    
}

// MARK: - Extension - collectionView
extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
            
        case userReCollectionView:
            return recommendModel!.count
            
        case eventCollectionView:
            
            if eventModel!.count == 0 {
                return 2
            }
            
            return eventModel!.count
            
        case drCollectionView:
            return weatherModel!.count
            
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        isRe = true
        
        switch collectionView {
            
        case userReCollectionView:
            let obj = self.recommendModel![indexPath.row] as! NSDictionary
            store.dummyItemNo = obj["menuNo"] as? String
            
            let detail = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(identifier: "DetailVC")
            self.navigationController?.pushViewController(detail, animated: true)
            break
            
        case eventCollectionView:
            
            if eventModel!.count != 0 {
                let obj = self.eventModel![indexPath.row] as! NSDictionary
                store.dummyBoardNo = obj["eventNo"] as? String
                
                let detail = UIStoryboard(name: "MyPage", bundle: nil).instantiateViewController(identifier: "EventDetail")
                self.navigationController?.pushViewController(detail, animated: true)
            }
            break
            
        case drCollectionView:
            let obj = self.weatherModel![indexPath.row] as! NSDictionary
            store.dummyItemNo = obj["menuNo"] as? String
            
            let detail = UIStoryboard(name: "Order", bundle: nil).instantiateViewController(identifier: "DetailVC")
            self.navigationController?.pushViewController(detail, animated: true)
            break
            
        default:
            break
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            
        case userReCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeReCell", for: indexPath) as! HomeReCell
            let obj = self.recommendModel![indexPath.row] as! NSDictionary
            let menuName = obj["menuName"] as? String
            let hotImg = obj["menuImgHot"] as! String
            let iceImg = obj["menuImgIce"] as! String
            
            if hotImg != "" {
                
                self.loadImage(urlString: hotImg) { image in

                    DispatchQueue.main.async {
                        cell.recommendImage.image = image
                    }

                }
                
            } else {
                
                self.loadImage(urlString: iceImg) { image in

                    DispatchQueue.main.async {
                        cell.recommendImage.image = image
                    }

                }
                
            }
            
            cell.recommendTitle.text = menuName
            
//            cell.recommendBest.isHidden = true
            
            return cell
            
        case eventCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeEventCell", for: indexPath) as! HomeEventCell
            
            if self.eventModel!.count == 0 {
                
                cell.label_empty.text = eventEmptyText[indexPath.row]
                return cell
                
            } else {
                
                cell.label_empty.text = ""
                let obj = self.eventModel![indexPath.row] as! NSDictionary
                let eventImgPath = obj["eventImgPath"] as! String
                
                self.loadImage(urlString: eventImgPath) { image in

                    DispatchQueue.main.async {
                        cell.image_event.image = image
                    }

                }
                
                return cell
                
            }
            
            
        case drCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDessertReCell", for: indexPath) as! HomeDessertReCell
            let obj = self.weatherModel![indexPath.row] as! NSDictionary
            let menuName = obj["menuName"] as! String
            let menuNameEn = obj["menuNameEn"] as! String
            let menuColor = obj["menuColor"] as! String
            let hotImg = obj["menuImgHot"] as! String
            let iceImg = obj["menuImgIce"] as! String
            
            if hotImg != "" {
                
                self.loadImage(urlString: hotImg) { image in

                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }

                }
                
            } else {
                
                self.loadImage(urlString: iceImg) { image in

                    DispatchQueue.main.async {
                        cell.imageView.image = image
                    }

                }
                
            }
            
            cell.label_eng.text = menuNameEn
            cell.label_kor.text = menuName
            cell.backView.backgroundColor = hexStringToUIColor(hex: menuColor)
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeReCell", for: indexPath) as! HomeReCell
            return cell
            
        }
        
    }
    
}

// MARK: - Extension - tableView
extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeRealtimeCell", for: indexPath) as! HomeRealtimeCell
        var arr: NSArray!
        
        switch indexPath.row {
            
        case 0:
            arr = self.dayModel!
            break
            
        case 1:
            arr = self.weekModel!
            break
            
        case 2:
            arr = self.monthModel!
            break
            
        default:
            break
            
        }
        
        for i in 0..<arr.count {
         
            let obj = arr![i] as! NSDictionary
            let menuName = obj["menuName"] as! String
            let menuNameEn = obj["menuNameEn"] as! String
            let menuNo = obj["menuNo"] as! String
            let hotImg = obj["menuImgHot"] as! String
            let iceImg = obj["menuImgIce"] as! String
//            print(obj)
            if hotImg != "" {
                
                self.loadImage(urlString: hotImg) { image in

                    DispatchQueue.main.async {
                        cell.images[i].image = image
                    }

                }
                
            } else {
                
                self.loadImage(urlString: iceImg) { image in

                    DispatchQueue.main.async {
                        cell.images[i].image = image
                    }

                }
                
            }
            
            cell.labelKo[i].text = menuName
            cell.lableEn[i].text = menuNameEn
            cell.views[i].tag = Int(menuNo)!
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(realTimeTaped(sender:)))
            cell.views[i].addGestureRecognizer(tap)
            
        }
        
        
        if dataModels[indexPath.row].isExpend {
            cell.cellTitle.font = UIFont(name: "LexendDeca-Bold", size: 12)
            cell.cellTitle.text = "\(realArr[indexPath.row]) ●"
            cell.contentsView.isHidden = false
        } else {
            cell.cellTitle.font = UIFont(name: "LexendDeca-Light", size: 12)
            cell.cellTitle.text = realArr[indexPath.row]
            cell.contentsView.isHidden = true
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !dataModels[indexPath.row].isExpend {
            return 45
        } else {
            return 317
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        timer.invalidate()
        tableView.beginUpdates()
        
        dataModels[selected.row].isExpend = false
        tableView.reloadRows(at: [selected], with: .automatic)
        
        dataModels[indexPath.row].isExpend = true
        tableView.reloadRows(at: [indexPath], with: .automatic)
        selected = indexPath
        
        tableView.endUpdates()
        
//        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(callTimer), userInfo: nil, repeats: true)
        
    }
    
}

// MARK: - Extension - scrollView
extension HomeVC: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print(scrollview.contentOffset.y)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        scrollY = scrollview.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y < scrollviewTop.constant {
//
//            if scrollviewTop.constant != 0 {
//                scrollView.contentOffset.y = scrollviewTop.constant
//            }
//
//        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == drCollectionView {

            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            let page = Int(ceil(x/w))
            self.pageControl.currentPage = page

        }
        
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        if scrollView == drCollectionView {
//
//            let x = scrollView.contentOffset.x
//            let w = scrollView.bounds.size.width
//            let page = Int(ceil(x/w))
//            self.pageControl.currentPage = page
//
//        }
//
//      }
    
}

