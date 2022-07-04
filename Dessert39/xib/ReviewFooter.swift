//
//  ReviewFooter.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/30.
//

import UIKit

class ReviewFooter: UIView {
    
    @IBOutlet weak var textView: UITextView!{
        didSet{
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xBFBFBF).cgColor
            textView.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var btn_ok: UIButton!{
        didSet{
            btn_ok.layer.cornerRadius = btn_ok.frame.height / 2
        }
    }
    
    let xibName = "ReviewFooter"
        
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
