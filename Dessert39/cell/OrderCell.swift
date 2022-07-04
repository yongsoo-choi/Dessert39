//
//  OrderCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/20.
//

import UIKit

class OrderCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.layer.cornerRadius = 12

        }
    }
    @IBOutlet var label_name: UILabel!
    @IBOutlet var part: UIButton!
    
    
}
