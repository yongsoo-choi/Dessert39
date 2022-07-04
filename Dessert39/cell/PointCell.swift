//
//  PointCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/24.
//

import UIKit

class PointCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!{
        didSet{
            bgView.layer.cornerRadius = 5
            bgView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE).cgColor
            bgView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var label_point: UILabel!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_expired: UILabel!
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var expiredView: UIView!
    
}
