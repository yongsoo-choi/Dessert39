//
//  LoadImage.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/07.
//

import UIKit

class LoadImage {
    
    static func load(urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        NetworkUtil().request(type: .getURL(urlString: urlString, method: "GET")) { data, response, error in
            
            if let hasData = data {
                
                completion(UIImage(data: hasData))
                return
                
            }
            
            completion(nil)
            
        }
        
    }
    
}
