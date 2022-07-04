//
//  StoreInfoHeader.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/06.
//

import UIKit

class StoreInfoHeader: UIView {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var headerInner: UIView!{
        didSet{
            headerInner.layer.masksToBounds = false
            headerInner.layer.shadowColor = UIColor.gray.cgColor
            headerInner.layer.shadowOpacity = 0.2
            headerInner.layer.shadowOffset = CGSize(width: 0, height: 0)
            headerInner.layer.shadowRadius = 8
            headerInner.layer.cornerRadius = 5
        }
    }
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var lineViews: [UIView]!
    
    @IBOutlet var starView: UIView!{
        didSet{
            starView.clipsToBounds = true
            starView.layer.cornerRadius = 5
            starView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    @IBOutlet var label_star: UILabel!
    @IBOutlet weak var image_profile: UIImageView!{
        didSet{
            image_profile.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var btn_bookmark: UIButton!
    @IBOutlet weak var label_store: UILabel!
    @IBOutlet weak var label_dist: UILabel!
    @IBOutlet weak var lable_address: UILabel!
    @IBOutlet weak var label_time: UILabel!
    @IBOutlet weak var label_break: UILabel!{
        didSet{
            label_break.isHidden = true
        }
    }
    @IBOutlet weak var image_check: UIImageView!{
        didSet{
            image_check.isHidden = true
        }
    }
    @IBOutlet weak var btn_order: UIButton!{
        didSet{
            btn_order.layer.cornerRadius = btn_order.frame.height / 2
        }
    }
    
    
    
    let xibName = "StoreInfoHeader"
    
    var selectedIndex = 0
        
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
        
        setBtns()
        
    }
    
    func setBtns() {
        
        for i in 0..<4 {
            buttons[i].setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x757575), for: .normal)
            lineViews[i].isHidden = true
        }
        
        buttons[selectedIndex].setTitleColor(UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C), for: .normal)
        lineViews[selectedIndex].isHidden = false
        
    }
    
    func calculateHeight() -> CGFloat {
        
        let hei = headerView.frame.size.height + stackView.frame.size.height + 1
        return hei
        
    }
    
}
