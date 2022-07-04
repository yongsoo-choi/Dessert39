//
//  WeatherModel.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/11/05.
//

import Foundation

struct WeatherModel: Codable {
    
    let errCode: String
    let errMsg: String
    let korStatus: String?
    let enStatus: String?
    
}
