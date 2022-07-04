//
//  OrderListDetailHeader.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/29.
//

import UIKit

class OrderListDetailHeader: UIView {
    
    @IBOutlet weak var label_orderNum: UILabel!
    @IBOutlet var label_status: [UILabel]!
    @IBOutlet var icon_status: [UIImageView]!
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var btn_copyAddress: UIButton!{
        didSet{
            btn_copyAddress.layer.borderWidth = 1
            btn_copyAddress.layer.borderColor = UIColorFromRGB.colorInit(0.5, rgbValue: 0xCFCFCF).cgColor
            btn_copyAddress.backgroundColor = .white
            btn_copyAddress.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var label_menu: UILabel!
    @IBOutlet weak var btn_expended: UIButton!
    @IBOutlet weak var grayView: UIView!{
        didSet{
            grayView.clipsToBounds = true
            grayView.layer.cornerRadius = 10
            grayView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    let xibName = "OrderListDetailHeader"
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
}
