//
//  CoinListCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/13.
//

import Foundation

class CoinListCell: UITableViewCell {
    
    @IBOutlet var boxView: UIView!{
        didSet{
            boxView.layer.cornerRadius = 5
            boxView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            boxView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet var label_title: UILabel!
    @IBOutlet var image_type: UIImageView!
    @IBOutlet var label_type: UILabel!
    @IBOutlet var label_coin: UILabel!
    @IBOutlet var label_date: UILabel!
    @IBOutlet var label_fee: UILabel!
    
}
