//
//  HomeRealtimeCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/25.
//

import UIKit

class HomeRealtimeCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    
    @IBOutlet var images: [UIImageView]!{
        didSet{
            for i in 0..<3 {
                images[i].layer.cornerRadius = images[i].frame.height / 2
            }
        }
    }
    @IBOutlet var labelKo: [UILabel]!
    @IBOutlet var lableEn: [UILabel]!
    @IBOutlet var views: [UIView]!
    
    @IBOutlet weak var contentsView: UIStackView!
    
}

