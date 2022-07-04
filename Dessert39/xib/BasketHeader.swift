//
//  BasketHeader.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/22.
//

import UIKit

class BasketHeader: UIView {
    
    @IBOutlet weak var label_store: UILabel!{
        didSet{
            label_store.text = store.storeName
        }
    }
    
    @IBOutlet weak var btn_remove: UIButton!{
        didSet{
            btn_remove.layer.borderWidth = 1
            btn_remove.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_remove.layer.cornerRadius = 3
        }
    }
    
    @IBOutlet weak var btn_copyAddress: UIButton!{
        didSet{
            btn_copyAddress.layer.cornerRadius = btn_copyAddress.frame.height / 2
        }
    }
    
    let xibName = "BasketHeader"
        
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
