//
//  StoreCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/12.
//

import Foundation
import UIKit

class StoreCell: UITableViewCell {
    
    @IBOutlet weak var store_image: UIImageView!{
        didSet{
            store_image.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var store_name: UILabel!
    @IBOutlet weak var store_dist: UILabel!
    @IBOutlet weak var store_address: UILabel!
    @IBOutlet weak var store_time: UILabel!
    @IBOutlet weak var btn_pin: UIButton!
    
}
