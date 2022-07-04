//
//  Point.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/24.
//

import UIKit

class Point: UIViewController {

    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var label_point: UILabel!
    @IBOutlet weak var label_removePoint: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let refresh = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.initRefresh(tableview: tableView, refresh: refresh)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "포인트")
        navigationController?.isNavigationBarHidden = false
        
        pointView.layer.masksToBounds = false
        pointView.layer.shadowColor = UIColor.gray.cgColor
        pointView.layer.shadowOpacity = 0.2
        pointView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pointView.layer.shadowRadius = 8
        pointView.layer.cornerRadius = 10
        
        grayView.layer.cornerRadius = 10
        grayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        
    }

}

extension Point: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        tableView.setEmptyView(title: "", message: "포인트 내역이 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "PointCell", for: indexPath) as! PointCell
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}
