//
//  OrderMenuCell.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/04.
//

import UIKit
import SnapKit

protocol PageIndexDelegate {
    func SelectMenuItem(pageIndex: Int)
}

class OrderMenuCell: UICollectionViewCell {
    
    var delegate: PageIndexDelegate?
    
    static func fittingSize(availableHeight: CGFloat, name: String?) -> CGSize {
        let cell = OrderMenuCell()
        cell.configure(name: name)
        
        let targetSize = CGSize(width: (UIView.layoutFittingCompressedSize.width) + 20, height: availableHeight)
        return cell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required)
    }
    
    private let titleLabel: UILabel = UILabel()
    private let line: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override var isSelected: Bool {
        didSet {
            
            titleLabel.textColor = isSelected ? UIColorFromRGB.colorInit(1.0, rgbValue: 0x1C1C1C) : UIColorFromRGB.colorInit(1.0, rgbValue: 0x757575)
            titleLabel.font = isSelected ? UIFont(name: "Pretendard-Bold", size: 14) : UIFont(name: "Pretendard-Regular", size: 14)
            line.isHidden = isSelected ? false : true
            
        }
    }
    
    private func setupView() {
        
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0x757575)
        titleLabel.font = UIFont(name: "Pretendard-Regular", size: 15)
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 5))
        }
        
        line.backgroundColor = .black
        
        contentView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(2)
            make.bottom.equalToSuperview()
        }
//        print(isSelected)

    }
    
    func configure(name: String?) {
        titleLabel.text = name
    }
    
}
