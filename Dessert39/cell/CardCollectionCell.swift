//
//  CardCollectionCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/07.
//

import Foundation

class CardCollectionCell: UICollectionViewCell {
    
    @IBOutlet var view_back: UIView!{
        didSet{
            view_back.layer.borderWidth = 1
            view_back.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            view_back.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF8F8F8)
            view_back.layer.cornerRadius = 5
        }
    }
    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_num: UILabel!
    
}
