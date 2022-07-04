//
//  AddrBookCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/13.
//

import UIKit

class AddrBookCell: UITableViewCell {
    
    @IBOutlet var boxView: UIView!{
        didSet{
            boxView.layer.cornerRadius = 5
            boxView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C).cgColor
            boxView.layer.borderWidth = 1
        }
    }
    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_addr: UILabel!
    @IBOutlet var btn_delete: UIButton!{
        didSet{
            btn_delete.layer.cornerRadius = 5
            btn_delete.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_delete.layer.borderWidth = 1
        }
    }
    
}
