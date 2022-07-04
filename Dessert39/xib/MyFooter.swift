//
//  MyFooter.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/30.
//

import UIKit

class MyFooter: UIView {
    
    let xibName = "MyFooter"
        
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
