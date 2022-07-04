//
//  NoticeCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/26.
//

import UIKit

class NoticeCell: UITableViewCell{
    
    @IBOutlet weak var label_urgency: UILabel!{
        didSet{
            label_urgency.isHidden = true
        }
    }
    @IBOutlet weak var lable_title: UILabel!
    @IBOutlet weak var label_date: UILabel!
    
}
