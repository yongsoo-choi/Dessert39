//
//  Qna.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/01.
//
// 상단 collectionView를 tableView로 가려놓음

import UIKit

class Qna: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    private let items: [String] = ["전체", "회원가입", "결제", "포인트", "쿠폰"]
    var currentIndex : Int = 0 {
        didSet{
            changeBtn()
        }
    }
    var selectedCell: Int?
    
    let refresh = UIRefreshControl()
    var networkUtil = NetworkUtil()
    var qnaModel: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        initRefresh()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "자주 묻는 질문")
        navigationController?.isNavigationBarHidden = false
        
        setupCollectionView()
        getListApi()
    }
    
    func setFooter() {
        
        let footer = QnaFooter()
        footer.frame = CGRect(x: 0, y: -1, width: view.frame.size.width, height: 95)
        footer.btn_ask.addTarget(self, action: #selector(goAsk(sender:)), for: .touchUpInside)
        
        tableView.tableFooterView = footer
        
    }
    
    @objc func goAsk(sender: UIButton) {
        
        store.isAsk = true
        self.navigationController?.popToRootViewController(animated: false)
        
    }
    
    func getListApi() {
        
        if !refresh.isRefreshing {
            ShowLoading.loadingStart(uiView: self.view)
        }
        
        let cmd = "get_board_list"
        let token = UserDefaults.standard.string(forKey: "loginToken")!
        let part = "faq"
        let page = ""
        let category = ""
        
        let strCode: String = "<CMD>\(cmd)</CMD><DATA><TOKEN>\(token)</TOKEN><PART>\(part)</PART><PAGE>\(page)</PAGE><CATEGORY>\(category)</CATEGORY></DATA>"
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
                    self.qnaModel = jsonResult["boardList"] as? NSArray
                    
                    DispatchQueue.main.async {
                        
                        if !self.refresh.isRefreshing {
                            ShowLoading.loadingStop()
                        }

                        if jsonResult["errCode"] as? String == "0000" {

                            self.tableView.reloadData()
                            self.refresh.endRefreshing()
                            self.setFooter()

                        }

                    }
                    

                } catch {
                    print("JSONDecoder Error : \(error)")
                }
                
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
            
            collectionView.selectItem(at: IndexPath(row: currentIndex, section: 0), animated: true, scrollPosition: .init(rawValue: 100))
        }
        
    }

}

extension Qna: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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

extension Qna: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.qnaModel?.count ?? 0
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "자주 묻는 질문이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .singleLine
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "QnaCell", for: indexPath) as! QnaCell
        let obj = self.qnaModel![indexPath.row] as! NSDictionary
        let subject = obj["subject"] as! String
        let content = obj["content"] as! String
        
        cell.label_question.text = subject
        cell.label_answer.text = content
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCell = indexPath.row
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == selectedCell {
            return UITableView.automaticDimension
        }
        
        return 52
        
    }
    
}
