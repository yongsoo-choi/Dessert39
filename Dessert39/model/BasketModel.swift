//
//  BasketModel.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/11.
//

import Foundation

struct BasketModel: Codable {
    
    var name: String
    var no: String
    var goodsPath: String
    var price: String
    var option: String
    var hot_ice: String
    var size: String
    var cup: String
    var result: String
    var count: String
    var discount: String
    var discountPer: Int
    var singleResult: String
    var optionStr: String
    var shot: Int = 0
    var decaf: Int = 0
    var weak: Int = 0
    var vanilla: Int = 0
    var hazelnut: Int = 0
    var caramel: Int = 0
    var pearl: Int = 0
    var coco: Int = 0
//    let option: Dictionary<String, Int>
    
}
