//
//  SendSMS.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/21.
//

import Foundation


struct SendSMS: Codable {
    
    let errCode: String
    let errMsg: String
    let requestId:String?
    let requestTime: String?
    let statusCode: String?
    let statusName: String?
    
}
