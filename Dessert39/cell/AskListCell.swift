//
//  AskListCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/02.
//

import UIKit

class AskListCell: UITableViewCell {
    
    @IBOutlet weak var box_answer: UIButton!{
        didSet{
            box_answer.layer.cornerRadius = 5
            box_answer.layer.borderWidth = 1
            box_answer.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
            box_answer.tintColor = .white
            box_answer.backgroundColor = .black
        }
    }
    @IBOutlet weak var box: UIButton!{
        didSet{
            box.layer.cornerRadius = 5
            box.layer.borderWidth = 1
            box.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x000000).cgColor
        }
    }
    @IBOutlet weak var label_askType: UILabel!
    @IBOutlet weak var label_askDate: UILabel!
    @IBOutlet weak var label_askTitle: UILabel!
    @IBOutlet weak var label_askContents: UILabel!
    
    @IBOutlet weak var label_answerDate: UILabel!
    @IBOutlet weak var label_answerContents: UILabel!
    
    @IBOutlet weak var view_answer: UIView!
}
