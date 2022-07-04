//
//  OrderListCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/25.
//

import UIKit

class OrderListCell: UITableViewCell {
    
    @IBOutlet weak var image_menu: UIImageView!{
        didSet{
            image_menu.layer.cornerRadius = 12
        }
    }
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_menu: UILabel!
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var label_status: UILabel!
    @IBOutlet var arrow: UIImageView!
    
}
