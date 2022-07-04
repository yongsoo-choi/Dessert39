//
//  CardButtonCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/01.
//

import Foundation
import UIKit

class CardButtonCell: UITableViewCell {
    
    @IBOutlet weak var btn_change: UIButton!{
        didSet{
            btn_change.layer.cornerRadius = btn_change.frame.height / 2
        }
    }
    
}
