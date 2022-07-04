//
//  LoginModel.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/21.
//

import Foundation

struct LoginModel: Codable {
    
    let errCode: String
    let errMsg: String
    let strToken: String?
    let isFirstLogin: String?
    let cardImg: String?
    
}
