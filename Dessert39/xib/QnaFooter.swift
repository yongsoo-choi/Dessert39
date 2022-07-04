//
//  QnaFooter.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/05/09.
//

import Foundation

class QnaFooter: UIView {
    
    @IBOutlet var btn_ask: UIButton!
    
    let xibName = "QnaFooter"
        
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
