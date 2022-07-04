//
//  CouponCell_disable.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/24.
//

import UIKit

class CouponCellDisable: UITableViewCell {
    
    @IBOutlet weak var bgView: UIImageView!{
        didSet{
            bgView.layer.masksToBounds = false
            bgView.layer.shadowColor = UIColor.gray.cgColor
            bgView.layer.shadowOpacity = 0.2
            bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
            bgView.layer.shadowRadius = 8
        }
    }
    
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var label_coupon: UILabel!
    @IBOutlet weak var label_minPrice: UILabel!
    @IBOutlet weak var label_date: UILabel!
    
}
