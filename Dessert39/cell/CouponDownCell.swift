//
//  CouponDownCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/14.
//

import UIKit

class CouponDownCell: UITableViewCell {

    @IBOutlet weak var bgView: UIImageView!{
        didSet{
            bgView.layer.masksToBounds = false
            bgView.layer.shadowColor = UIColor.gray.cgColor
            bgView.layer.shadowOpacity = 0.2
            bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
            bgView.layer.shadowRadius = 8
        }
    }

    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_sale: UILabel!
    @IBOutlet var label_minPrice: UILabel!
    @IBOutlet var label_date: UILabel!
    @IBOutlet var btn_down: UIImageView!
    @IBOutlet var enabledView: UIImageView!{
        didSet{
            enabledView.alpha = 0
        }
    }
    
}
