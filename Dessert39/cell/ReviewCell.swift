//
//  ReviewCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/30.
//

import UIKit

class ReviewCell: UITableViewCell {
    
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var lineView: UIView!
    
    var selectedNum:Int?
    
    @IBAction func starTapped(_ sender: UIButton) {
        
        let last = sender.tag
        selectedNum = last
        
        for index in 0...last {
            buttons[index].setImage(UIImage(named: "smile_fill"), for: .normal)
        }
        
        for index in last + 1..<buttons.count {
            buttons[index].setImage(UIImage(named: "smile"), for: .normal)
        }
        
    }
    
}
