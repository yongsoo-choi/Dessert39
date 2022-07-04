//
//  MyHeader.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/22.
//

import UIKit

class MyHeader: UIView {
    
    @IBOutlet weak var label_name: UILabel!
    @IBOutlet weak var btn_grade: UIButton!
    @IBOutlet weak var image_profile: UIImageView!{
        didSet{
            image_profile.layer.cornerRadius = 5
            image_profile.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var btn_gradeInfo: UIButton!{
        didSet{
            btn_gradeInfo.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xffffff)
            btn_gradeInfo.layer.borderWidth = 1
            btn_gradeInfo.layer.borderColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xD5D5D5).cgColor
            btn_gradeInfo.layer.cornerRadius = 5
            btn_gradeInfo.titleLabel?.textAlignment = .center
        }
    }
    @IBOutlet var gradeImage: UIImageView!
    
    let xibName = "MyHeader"
        
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
