//
//  CardListCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/05.
//

import UIKit

class CardListCell: UITableViewCell {
    
    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_num: UILabel!
    @IBOutlet var btn_delete: UIButton!{
        didSet{
            btn_delete.layer.borderWidth = 1
            btn_delete.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_delete.layer.cornerRadius = 5
        }
    }
    
}
