//
//  BasketFooter.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/19.
//

import UIKit
import SnapKit

class BasketFooter: UIView {
    
    @IBOutlet var couponTF: UITextField!
    @IBOutlet weak var tf_request: UITextField!
    
    @IBOutlet weak var btn_expend: UIButton!
    @IBOutlet var lineView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet weak var grayView: UIView!{
        didSet{
            grayView.layer.cornerRadius = 10
        }
    }
    
    var isExpend: Bool = true
    var defaultHei: Int?
    let xibName = "BasketFooter"
        
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
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(image: UIImage(systemName: "keyboard.chevron.compact.down"), style: .done, target: nil, action: #selector(done))
        doneButton.tintColor = .gray
        toolbar.setItems([doneButton], animated: false)
        
        tf_request.inputAccessoryView = toolbar
    }
    
    @objc func done() {
        self.endEditing(true)
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
            
            textLabel.text = "\n\n- 디저트39 오더 이용 시, 주문을 완료한 후에는 매장에서 픽업 가능 시간이 알림으로 전달됩니다.\n\n- 픽업 가능 시간 확인 후 결제 완료를 진행하지 않으시면 픽업 가능 시간 알림 전달 5분 후에는 자동으로 주문이 취소됩니다.\n\n- 픽업 가능 시간을 확인하신 후 결제 완료를 하시면 매장에서 제조를 시작하며, 주문 변경/전체 취소/부분 취소가 불가능합니다.\n\n- 매장 사정으로 인해 제품의 재고가 없거나 부족할 경우, 매장 혼잡으로 인해 주문이 취소될 수 있으며 알림으로 전달됩니다."
            lineView.alpha = 1
            
            UIView.setAnimationsEnabled(false)
            btn_expend.setTitle("⌃ 접기", for: .normal)
            btn_expend.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            
        }

        
//        UIView.animate(withDuration: 0.3) {
//            if self.isExpend {
//                self.textLabel.alpha = 0
//                self.btn_expend.setTitle("⌵ 펴기", for: .normal)
//            } else {
//                self.textLabel.alpha = 1
//                self.btn_expend.setTitle("⌃ 접기", for: .normal)
//            }
//        }
        
        isExpend = !isExpend
        
    }
    
}
