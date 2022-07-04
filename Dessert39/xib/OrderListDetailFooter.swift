//
//  OrderListDetailFooter.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/29.
//

import UIKit

class OrderListDetailFooter: UIView {
    
    @IBOutlet weak var btn_review: UIButton!{
        didSet{
            btn_review.layer.cornerRadius = btn_review.frame.height / 2
        }
    }
    @IBOutlet weak var grayView: UIView!{
        didSet{
            grayView.clipsToBounds = true
            grayView.layer.cornerRadius = 5
            grayView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    let xibName = "OrderListDetailFooter"
        
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
