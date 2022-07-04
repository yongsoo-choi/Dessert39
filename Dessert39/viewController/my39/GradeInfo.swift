//
//  GradeInfo.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/23.
//

import UIKit

class GradeInfo: UIViewController {
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var lineView: UIView!
    @IBOutlet var btn_expend: UIButton!
    var isExpend: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "등급별 혜택")
        navigationController?.isNavigationBarHidden = false
        
    }
    
    @IBAction func expendAction(_ sender: Any) {
        
        if isExpend {
            
            textLabel.text = ""
            lineView.alpha = 0
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌵ 펴기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
            
        } else {
            
            textLabel.text = "\n\n- 등업 조건 충족 시 해당일로부터 익일에 자동 처리됩니다.\n\n- 등급별 쿠폰의 유효기간 및 사용 조건은 쿠폰함에서 자세히 확인하실 수 있습니다.\n\n- 지급된 쿠폰을 기간 내에 사용하지 않을 시 자동으로 소멸됩니다.\n\n- 생일축하 쿠폰은 나무 등급 > 연 1회 제공됩니다."
            lineView.alpha = 1
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌃ 접기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
 
        }
        
        isExpend = !isExpend
        
    }

}
