//
//  RecommendVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/05.
//

import UIKit

class RecommendVC: UIViewController {

    @IBOutlet var scrollview: UIScrollView!
    
    @IBOutlet var bannerCV: UICollectionView!
    @IBOutlet var label_story: UILabel!
    
    @IBOutlet var eventView: UIView!
    @IBOutlet var eventCV: UICollectionView!
    @IBOutlet var label_event: UILabel!
    
    @IBOutlet var recomView: UIView!
    @IBOutlet var recomTop: NSLayoutConstraint!
    @IBOutlet var recomCV: UICollectionView!
    @IBOutlet var label_recom: UILabel!
    
    @IBOutlet var bookmarkView: UIView!
    @IBOutlet var bookmarkInner: UIView!
    @IBOutlet var bookmarkHei: NSLayoutConstraint!
    
    @IBOutlet var newView: UIView!
    @IBOutlet var newCV: UICollectionView!
    @IBOutlet var newTop: NSLayoutConstraint!
    
    @IBOutlet var seasonView: UIView!
    @IBOutlet var seasonInner: UIView!
    @IBOutlet var seasonHei: NSLayoutConstraint!
    
    @IBOutlet var dessertView: UIView!
    @IBOutlet var dessertCV: UICollectionView!
    
    var networkUtil = NetworkUtil()
    var orderModel: NSArray?

    var num: Int = 1
    var colorArr = [UIColor.gray, UIColor.blue, UIColor.cyan]
    
    var pageControl = UIPageControl()
    var curIndex = 0 {
        didSet{
            pageControl.currentPage = curIndex
        }
    }
    
    var bannerModel: NSArray?
    var storyModel: NSArray?
    var couponModel: NSArray?
    var eventArr: [Int] = []
    var recomModel: NSArray?
    var bookmarkModel: NSArray?
    var newMenuModel: NSArray?
    var seasonModel: NSArray?
    var dessertModel: NSArray?
    
    var storeName: String?
    
    let refresh = UIRefreshControl()
    var isRefresh: Bool = false
    
    
    func initRefresh() {
        
        refresh.addTarget(self, action: #selector(refreshTable(refresh:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        self.scrollview.refreshControl = refresh
        
    }
    
    @objc func refreshTable(refresh: UIRefreshControl) {
        
        print("refreshTable")
        isRefresh = true
        getApi()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBanner()
        setEvent()
        setRecom()
        setNew()
        setDessert()
        
        initRefresh()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ShowLoading.loadingStart(uiView: self.view)
        getApi()
//        if storeName != store.storeName {
//            getApi()
//        }
//
//        storeName = store.storeName
    }
    
    func setBanner() {
        
        bannerCV.delegate = self
        bannerCV.dataSource = self
        bannerCV.isPagingEnabled = true
        bannerCV.layer.cornerRadius = 15
        
        let wid = UIScreen.main.bounds.width - 40
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (wid * 335) / 198)
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        bannerCV.collectionViewLayout = layout
        
        self.view.addSubview(pageControl)
        
    }
    
    func setPageController() {
        
        var total = 0
        
        if self.bannerModel != nil {
            
            for item in bannerModel! {
                
                let obj = item as! NSDictionary
                let img = obj["img"] as! String
                
                if img != "" {
                    total += 1
                }
                
            }
            
        }
    
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
        pageControl.pageIndicatorTintColor = UIColorFromRGB.colorInit(0.48, rgbValue: 0xffffff)
        pageControl.numberOfPages = total
        pageControl.currentPage = 0
        pageControl.bottomAnchor.constraint(equalTo: bannerCV.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: bannerCV.centerXAnchor).isActive = true
        
    }
    
    func setStory() {
        
        if store.storeName != "" {
            
            if storyModel!.count > 0 {
                
                let obj = self.storyModel![0] as! NSDictionary
                let content = obj["content"] as! String
                
                label_story.text = content
                
            } else {
                label_story.text = "해당 매장의 등록된 스토리가 없습니다"
            }
            
        } else {
            label_story.text = "매장을 선택해 주세요."
        }
        
    }
    
    func setEvent() {
        
        eventCV.delegate = self
        eventCV.dataSource = self
        
        let wid = (UIScreen.main.bounds.width / 4.2) + 5
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (UIScreen.main.bounds.width * 120) / 375)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal

        eventCV.collectionViewLayout = layout
        
    }
    
    @IBAction func downCoupon(_ sender: UIButton) {
        
        let pop = UIStoryboard(name: "Popup", bundle: nil).instantiateViewController(identifier: "CouponPop") as! CouponPop
        pop.isUser = true
        pop.modalPresentationStyle = .overFullScreen
        self.present(pop, animated: false, completion: nil)
        
    }
    
    func setCoupon() {
        
        if couponModel!.count > 0 {
            
            var i = 0
            for item in couponModel! {
                
                let obj = item as! NSDictionary
                let name = obj["menuName"] as! String
                
                if name != "" {
                    i += 1
                }
                
            }
            
            if i > 0 {
                
                label_event.text = "\(store.storeName) 이벤트 메뉴"
                recomTop.constant =  0
                
            } else {
                recomTop.constant =  -(eventView.frame.height)
            }
            
        } else {
            recomTop.constant =  -(eventView.frame.height)
        }
        
        
    }
    
    func setRecom() {
        
        recomCV.delegate = self
        recomCV.dataSource = self
        
        let wid = UIScreen.main.bounds.width / 4.2
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (UIScreen.main.bounds.width * 120) / 375)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal

        recomCV.collectionViewLayout = layout
        
        if store.nick != "" {
            
            let nick: String = store.nick!
            label_recom.text = "\(nick)님을 위한 추천 메뉴"
            
        } else if store.name != "" {
            
            let name: String = store.name!
            label_recom.text = "\(name)님을 위한 추천 메뉴"
            
        } else {
            
            let id: String = store.nick!
            label_recom.text = "\(id)님을 위한 추천 메뉴"
            
        }
        
    }
    
    func setBookmark() {
        
        for subview in bookmarkInner.subviews {
            subview.removeFromSuperview()
        }
        
        if bookmarkModel != nil {
            
            if bookmarkModel!.count > 0 {
                
                let wid = UIScreen.main.bounds.width
                let hei: CGFloat = 100
                
                for (index, item) in bookmarkModel!.enumerated() {
                    
                    if index > 2 {
                        return
                    }
                    
                    let cell = GoodsDefault(frame: CGRect(x: 0, y: hei * CGFloat(index), width: wid, height: hei))
                    let obj = item as! NSDictionary
                    let menuName = obj["menuName"] as! String
                    let menuEngName = obj["menuEngName"] as! String
                    let menuImgHot = obj["menuImgHot"] as! String
                    let menuImgIce = obj["menuImgIce"] as! String
                    let menuNo = obj["menuNo"] as! String
                    
                    let hotGrande = obj["menuPriceHotGrande"] as! String
                    let hotVenti = obj["menuPriceHotVenti"] as! String
                    let hotLarge = obj["menuPriceHotLarge"] as! String
                    let iceGrande = obj["menuPriceIceGrande"] as! String
                    let iceVenti = obj["menuPriceIceVenti"] as! String
                    let iceLarge = obj["menuPriceIceLarge"] as! String
                    
                    let arr = [hotGrande, hotVenti, hotLarge, iceGrande, iceVenti, iceLarge]
                    
                    var i = 0
                    for item in arr {
                        
                        if item != "0" {
                            cell.label_price.text = currncyStr(str: item)
                            break
                        }
                        
                        i += 1
                        
                    }
                    
                    var imgPath = ""
                    if menuImgHot != "" {
                        imgPath = menuImgHot
                    } else {
                        imgPath = menuImgIce
                    }
                    
                    self.loadImage(urlString: imgPath) { image in

                        DispatchQueue.main.async {
                            cell.imageView.image = image
                        }

                    }
                    
                    cell.label_name.text = menuName
                    cell.label_name_en.text = menuEngName
                    
                    let gest: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goDetail(_:)))
                    gest.name = menuNo
                    cell.addGestureRecognizer(gest)
                    
                    bookmarkInner.addSubview(cell)
                    bookmarkHei.constant = CGFloat((index + 1) * 100)
                    
                }
                
                newTop.constant = 0
                
            } else {
                newTop.constant = -(bookmarkView.frame.height)
            }
            
        } else {
            newTop.constant = -(bookmarkView.frame.height)
        }
        
    }
    
    @objc func goDetail(_ gesture: UITapGestureRecognizer) {
        
        store.dummyItemNo = gesture.name
        UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
        
    }
    
    func setNew() {
        
        newCV.delegate = self
        newCV.dataSource = self
        
        let wid = UIScreen.main.bounds.width / 3.4
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (UIScreen.main.bounds.width * 155) / 375)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal

        newCV.collectionViewLayout = layout
        
    }
    
    func setSeason() {
        
        for subview in seasonInner.subviews {
            subview.removeFromSuperview()
        }
        
        if seasonModel != nil {
            
            if seasonModel!.count > 0 {
                
                let wid = UIScreen.main.bounds.width
                let hei: CGFloat = 100
                
                for (index, item) in seasonModel!.enumerated() {
                    
//                    if index > 2 {
//                        return
//                    }
                    
                    let cell = GoodsDefault(frame: CGRect(x: 0, y: hei * CGFloat(index), width: wid, height: hei))
                    let obj = item as! NSDictionary
                    let menuName = obj["menuName"] as! String
                    let menuEngName = obj["menuEngName"] as! String
                    let menuImgHot = obj["menuImgHot"] as! String
                    let menuImgIce = obj["menuImgIce"] as! String
                    let menuNo = obj["menuNo"] as! String
                    
                    let hotGrande = obj["menuPriceHotGrande"] as! String
                    let hotVenti = obj["menuPriceHotVenti"] as! String
                    let hotLarge = obj["menuPriceHotLarge"] as! String
                    let iceGrande = obj["menuPriceIceGrande"] as! String
                    let iceVenti = obj["menuPriceIceVenti"] as! String
                    let iceLarge = obj["menuPriceIceLarge"] as! String
                    
                    let arr = [hotGrande, hotVenti, hotLarge, iceGrande, iceVenti, iceLarge]
                    
                    var i = 0
                    for item in arr {
                        
                        if item != "0" {
                            cell.label_price.text = currncyStr(str: item)
                            break
                        }
                        
                        i += 1
                        
                    }
                    
                    var imgPath = ""
                    if menuImgHot != "" {
                        imgPath = menuImgHot
                    } else {
                        imgPath = menuImgIce
                    }
                    
                    self.loadImage(urlString: imgPath) { image in

                        DispatchQueue.main.async {
                            cell.imageView.image = image
                        }

                    }
                    
                    cell.label_name.text = menuName
                    cell.label_name_en.text = menuEngName
                    
                    let gest: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goDetail(_:)))
                    gest.name = menuNo
                    cell.addGestureRecognizer(gest)
                    
                    seasonInner.addSubview(cell)
                    seasonHei.constant = CGFloat((index + 1) * 100)
                    
                }
                
//                newTop.constant = 0
                
            } else {
//                newTop.constant = -(bookmarkView.frame.height)
            }
            
        } else {
//            newTop.constant = -(bookmarkView.frame.height)
        }
        
    }
    
    func setDessert() {
        
        dessertCV.delegate = self
        dessertCV.dataSource = self
        
        let wid = UIScreen.main.bounds.width / 2.6
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: wid, height: (UIScreen.main.bounds.width * 100) / 375)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.scrollDirection = .horizontal

        dessertCV.collectionViewLayout = layout
        
    }
    
    func getApi() {
        
//        ShowLoading.loadingStart(uiView: self.view)
        
        let cmd = "get_order_intro"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let no = store.storeNo ?? ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><NO>\(no)</NO></DATA>"
        let encryped: String = AES256CBC.encryptString(strCode)!
        let urlString: String = "\(store.configUrl)?code=\(encryped)"
        let str = urlString.replacingOccurrences(of: "+", with: "%2B")
        
        networkUtil.request(type: .getURL(urlString: str, method: "GET")) { data, response, error in
            
//            ShowLoading.loadingStop()
            
            if let hasData = data {
                do {
                    
                    let dataStr = String(decoding: hasData, as: UTF8.self)
                    let decryped = AES256CBC.decryptString(dataStr)!
                    let decrypedData = decryped.data(using: .utf8)!
                    
                    let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: decrypedData, options:JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
//                    print(jsonResult)
                    DispatchQueue.main.async {

                        if jsonResult["errCode"] as? String == "0000" {
                            
                            self.bannerModel = jsonResult["bannerList"] as? NSArray
                            self.storyModel = jsonResult["storyList"] as? NSArray
                            self.couponModel = jsonResult["couponList"] as? NSArray
                            self.recomModel = jsonResult["recommendList"] as? NSArray
                            self.bookmarkModel = jsonResult["bookmarkList"] as? NSArray
                            self.newMenuModel = jsonResult["newMenuList"] as? NSArray
                            self.seasonModel = jsonResult["seasonMenuList"] as? NSArray
                            self.dessertModel = jsonResult["dessertMenuList"] as? NSArray
                            
                            self.bannerCV.reloadData()
                            self.setPageController()
                            self.setStory()
                            self.setCoupon()
                            
                            self.eventCV.reloadData()
                            self.recomCV.reloadData()
                            self.setBookmark()
                            self.newCV.reloadData()
                            self.setSeason()
                            self.dessertCV.reloadData()
                            
                            self.refresh.endRefreshing()

                        }

                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        ShowLoading.loadingStop()
                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
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
    
}

extension RecommendVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
            
        case bannerCV:

            var total = 0
            
            if self.bannerModel != nil {
                
                for item in bannerModel! {
                    
                    let obj = item as! NSDictionary
                    let img = obj["img"] as! String
                    
                    if img != "" {
                        total += 1
                    }
                    
                }
                
            }
            
            return total
            
        case eventCV:

            var total = 0
            
            if self.couponModel != nil {
                
                if couponModel!.count > 2 {
                    
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
                
            }

            return total
            
        case recomCV:

            var total = 0
            
            if self.recomModel != nil {
                total  = self.recomModel!.count
            }
            
            return total
            
        case newCV:

            var total = 0
            
            if self.newMenuModel != nil {
                total  = self.newMenuModel!.count
            }
            
            return total
            
        case dessertCV:

            var total = 0
            
            if self.dessertModel != nil {
                total  = self.dessertModel!.count
            }
            
            return total

        default:
            return 0
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
            
        case bannerCV:
            
            let obj = self.bannerModel![indexPath.row] as! NSDictionary
            let menuNo = obj["menuNo"] as! String
            
            store.dummyItemNo = menuNo
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
            
            break
            
        case eventCV:
            
            let obj = self.couponModel![eventArr[indexPath.row]] as! NSDictionary
            let menuNo = obj["menuNo"] as! String
            
            store.dummyItemNo = menuNo
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
            
            break
            
        case recomCV:
            
            let obj = self.recomModel![indexPath.row] as! NSDictionary
            let menuNo = obj["menuNo"] as! String
            
            store.dummyItemNo = menuNo
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
            
            break
            
        case newCV:
            
            let obj = self.newMenuModel![indexPath.row] as! NSDictionary
            let menuNo = obj["menuNo"] as! String
            
            store.dummyItemNo = menuNo
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
            
            break
            
        case dessertCV:
            
            let obj = self.dessertModel![indexPath.row] as! NSDictionary
            let menuNo = obj["menuNo"] as! String
            
            store.dummyItemNo = menuNo
            UIApplication.topViewController()!.performSegue(withIdentifier: "detailSegue", sender: self)
            
            
            break
            
        default:
           break
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
            
        case bannerCV:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderBannerCell", for: indexPath) as! OrderBannerCell
            let obj = self.bannerModel![indexPath.row] as! NSDictionary
            let imgs = obj["img"] as! String
            
            self.loadImage(urlString: imgs) { image in

                DispatchQueue.main.async {
                    cell.imageview.image = image
                }

            }
            
            return cell
            
        case eventCV:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCell", for: indexPath) as! OrderCell
            let obj = self.couponModel![eventArr[indexPath.row]] as! NSDictionary
            let menuImgPath = obj["menuImgPath"] as! String
            let menuName = obj["menuName"] as? String
            let discountPart = obj["discountPart"] as? String // 0-%, 1-price, 2-size up
            let discountPercent = obj["discountPercent"] as? String
            let discountPrice = obj["discountPrice"] as? String
            
            cell.label_name.text = menuName
            
            self.loadImage(urlString: menuImgPath) { image in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }

            }
            
            if discountPart == "0" {
                cell.part.setTitle("\(discountPercent!)%", for: .normal)
            }
            
            if discountPart == "1" {
                cell.part.setTitle("\(discountPrice!)원 ⬇︎", for: .normal)
            }
            
            if discountPart == "2" {
                cell.part.setTitle("Size ⬆︎", for: .normal)
            }
            
            return cell
            
        case recomCV:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCell", for: indexPath) as! OrderCell
            let obj = self.recomModel![indexPath.row] as! NSDictionary
            let menuImgHot = obj["menuImgHot"] as! String
            let menuImgIce = obj["menuImgIce"] as! String
            let menuName = obj["menuName"] as? String
            
            cell.label_name.text = menuName
            
            var imgPath = ""
            if menuImgHot != "" {
                imgPath = menuImgHot
            } else {
                imgPath = menuImgIce
            }
            
            cell.imageView.image = nil
//            cell.imageView.alpha = 0
            
            self.loadImage(urlString: imgPath) { image in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }

            }
            
            cell.imageView.layer.cornerRadius = cell.imageView.frame.height / 2
            
//            UIView.animate(withDuration: 0.4, delay: 0.1 * Double(indexPath.row)) {
//                cell.imageView.alpha = 1
//            }
            
            return cell
            
        case newCV:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCell", for: indexPath) as! OrderCell
            let obj = self.newMenuModel![indexPath.row] as! NSDictionary
            let menuImgHot = obj["menuImgHot"] as! String
            let menuImgIce = obj["menuImgIce"] as! String
            let menuName = obj["menuName"] as? String
            
            if indexPath.row % 2 == 0 {
                cell.imageView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF9F0E6)
            } else {
                cell.imageView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF0F0E3)
            }
            
            cell.label_name.text = menuName
            
            var imgPath = ""
            if menuImgHot != "" {
                imgPath = menuImgHot
            } else {
                imgPath = menuImgIce
            }
            
            self.loadImage(urlString: imgPath) { image in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }

            }
            
            return cell
            
        case dessertCV:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCell", for: indexPath) as! OrderCell
            let obj = self.dessertModel![indexPath.row] as! NSDictionary
            let menuImgHot = obj["menuImgHot"] as! String
            let menuName = obj["menuName"] as? String
            
            if indexPath.row % 2 == 0 {
                cell.imageView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF0F0E3)
            } else {
                cell.imageView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF9F0E6)
            }
            
            cell.label_name.text = menuName
            
            self.loadImage(urlString: menuImgHot) { image in

                DispatchQueue.main.async {
                    cell.imageView.image = image
                }

            }
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderBannerCell", for: indexPath) as! OrderBannerCell
            return cell
            
        }
        
    }
    
}

extension RecommendVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == bannerCV {
            let x = scrollView.contentOffset.x
            let w = scrollView.bounds.size.width
            num = Int(ceil(x/w))
            pageControl.currentPage = num
        }
        
    }
    
}

extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
        
    }
    
}

