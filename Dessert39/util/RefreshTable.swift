//
//  RefreshTable.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/25.
//

import UIKit

extension UITableView {
    
    func setEmptyView(title: String, message: String, imageStr: String, imageW: CGFloat, imageH: CGFloat) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        titleLabel.font = UIFont(name: "Pretendard-Bold", size: 16)
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x202020)
        messageLabel.font = UIFont(name: "Pretendard-Regular", size: 12)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(icon)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        icon.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        icon.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -(imageH)).isActive = true
        icon.widthAnchor.constraint(equalToConstant: imageW).isActive = true
        icon.heightAnchor.constraint(equalToConstant: imageH).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        
        if imageStr != "" {
            icon.image = UIImage(named: imageStr)
        }
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
        
    }
    
    func restore() {
        
        self.backgroundView = nil
//        self.separatorStyle = .singleLine
        
    }
    
    func initRefresh(tableview: UITableView, refresh: UIRefreshControl) {
        refresh.addTarget(self, action: #selector(refreshTable(refresh:table:)), for: .valueChanged)
        refresh.backgroundColor = UIColor.clear
        refresh.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        tableview.refreshControl = refresh
    }
 
    @objc func refreshTable(refresh: UIRefreshControl, table: UITableView) {
        print("refreshTable")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            table.reloadData()
            refresh.endRefreshing()
        }
    }

    
}
