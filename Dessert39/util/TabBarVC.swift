//
//  TabBarVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/09/29.
//

import UIKit

class TabBarVC: UITabBar {
    
// MARK: - Variables
    public var didTapButton: (() -> ())?
    private var shapeLayer: CALayer?
    
    let titleArr: [String] = ["Home", "Alarm", "My39", "Order"]
    let imageArr: [String] = ["tb_home", "tb_alarm", "tb_my", "tb_order"]
    
    public lazy var orderButton: UIButton! = {
        
        var orderButton = UIButton()
        orderButton.frame.size = CGSize(width: 88, height: 88)
        orderButton.setBackgroundImage(UIImage(named: "tb_order"), for: .normal)
        orderButton.setTitle("", for: .normal)
        orderButton.addTarget(self, action: #selector(orderButtonAction), for: .touchUpInside)
        
        self.addSubview(orderButton)
        
        return orderButton
        
    }()
    
    var badgeView = UIButton()
    
// MARK: - Ovveride
    override func layoutSubviews() {
        super.layoutSubviews()
        
        orderButton.center = CGPoint(x: frame.width - 50, y: -5)
        
        badgeView.frame.size = CGSize(width: 20, height: 20)
        badgeView.center = CGPoint(x: orderButton.center.x + 10, y: orderButton.center.y - 10)
        badgeView.backgroundColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xF61D0D)
        badgeView.setTitle("99", for: .normal)
        badgeView.tintColor = .white
        badgeView.titleLabel?.font = UIFont(name: "LexendDeca-Regular", size: 12)
        badgeView.layer.cornerRadius = 10
        
        self.addSubview(badgeView)
        
        badgeView.isEnabled = true
        badgeView.isHidden = true

    }
    
    @objc func orderButtonAction(sender: UIButton) {
        didTapButton?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        
        return self.orderButton.frame.contains(point) ? self.orderButton : super.hitTest(point, with: event)
    }
    
    override func draw(_ rect: CGRect) {
        
        self.addShape()
        self.unselectedItemTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
        self.tintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C)
        
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -6)
        
        if let itemArr = self.items {
         
            for (i, item) in itemArr.enumerated() {
                
                item.title = titleArr[i]
                item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "LexendDeca-Regular", size: 10)!], for: .normal)
                item.image = UIImage(named: imageArr[i])
                
                if i == itemArr.count - 1 {
                    item.title = ""
                    item.image = UIImage()
                }
                
                if  i == 1  && store.alarmBage {
                    item.badgeValue = "●"
                    item.badgeColor = .clear
                    item.setBadgeTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
                }
                
            }
            
            
        }
        
    }
    
// MARK: - draw func
    private func addShape() {
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = createPath()
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 1.0
        
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        shapeLayer.shadowRadius = 10
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.1
        
        if let oldShapeLayer = self.shapeLayer {
            self.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            self.layer.insertSublayer(shapeLayer, at: 0)
        }
        
        self.shapeLayer = shapeLayer
        
    }
    
    func createPath() -> CGPath {
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 0, y: 30))
        path.addQuadCurve(to: CGPoint(x: 30, y: 0), controlPoint: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width - 120, y: 0))
        path.addQuadCurve(to: CGPoint(x: self.frame.width - 100, y: 10), controlPoint: CGPoint(x: self.frame.width - 110, y: 0))
        path.addQuadCurve(to: CGPoint(x: self.frame.width - 10, y: 10), controlPoint: CGPoint(x: self.frame.width - 45, y: 65))
        path.addQuadCurve(to: CGPoint(x: self.frame.width, y: 0), controlPoint: CGPoint(x: self.frame.width - 5, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.close()
        
        return path.cgPath
        
    }

}
