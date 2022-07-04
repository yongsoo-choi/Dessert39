//
//  OrderItemCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/08.
//

import Foundation
import UIKit

class OrderItemCell: UITableViewCell {
    
    @IBOutlet weak var item_image: UIImageView!{
        didSet{
            item_image.layer.cornerRadius = 13
            item_image.layer.borderWidth = 1
            item_image.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8).cgColor
        }
    }
    @IBOutlet weak var item_name: UILabel!
    @IBOutlet weak var item_anme_en: UILabel!
    @IBOutlet weak var item_price: UILabel!
    @IBOutlet weak var soldout: UIImageView!{
        didSet{
            soldout.isHidden = true
        }
    }
    
}
