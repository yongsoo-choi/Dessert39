//
//  AlarmButtonCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/03.
//

import UIKit

class AlarmButtonCell: UITableViewCell {
    
    @IBOutlet weak var boxView: UIView!{
        didSet{
            boxView.layer.borderWidth = 1
            boxView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x707070).cgColor
            boxView.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var label_content: UILabel!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet var image_icon: UIImageView!
    
    @IBOutlet weak var btn: UIButton!{
        didSet{
            btn.layer.cornerRadius = btn.frame.height / 2
        }
    }
    
}
