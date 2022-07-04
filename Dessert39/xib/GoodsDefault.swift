//
//  GoodsDefault.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/01/21.
//

import UIKit

class GoodsDefault: UIView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_name_en: UILabel!
    @IBOutlet var label_price: UILabel!
    
    let xibName = "GoodsDefault"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    private func loadXib() {
        
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
    }

}
