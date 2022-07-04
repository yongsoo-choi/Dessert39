//
//  CardListModel.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/24.
//

import Foundation

struct CardListModel: Codable {
    
    let errCode: String
    let errMsg: String
    let cardList: Dictionary<String, String>?
    
}
