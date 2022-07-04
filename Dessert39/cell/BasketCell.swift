//
//  BasketCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/17.
//

import UIKit

class BasketCell: UITableViewCell {
    
    @IBOutlet weak var menuImage: UIImageView!{
        didSet{
            menuImage.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var label_default: UILabel!
    @IBOutlet weak var label_option: UILabel!
    @IBOutlet weak var label_tumbler: UILabel!
    @IBOutlet weak var price_default: UILabel!
    @IBOutlet weak var price_option: UILabel!
    @IBOutlet weak var price_tumbler: UILabel!
    
    @IBOutlet weak var label_price: UILabel!
    
    @IBOutlet weak var btn_minus: UIButton!
    @IBOutlet weak var btn_plus: UIButton!
    @IBOutlet weak var labe_sum: UILabel!
    
    @IBOutlet weak var btn_close: UIButton!
    
}
