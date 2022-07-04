//
//  NetworkUtil.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/07.
//

import Foundation

class NetworkUtil {
    
    typealias requestCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    
    enum requestType {
        case getURL(urlString: String, method: String)
        case withParam(querys: [URLQueryItem], method: String)
    }
    
    enum requestError: Error {
        case emptyUrl
    }
    
    private func buildRequest(type: requestType) throws -> URLRequest {
        
        switch type {
        
        case .getURL(urlString: let urlString, method: let method):
            guard let hasURL = URL(string: urlString) else {
                throw requestError.emptyUrl
            }
            
            var request = URLRequest(url: hasURL)
            request.httpMethod = method
            return request
            
        case .withParam(querys: let querys, method: let method):
            
            var url = URLComponents(string: store.configUrl)!
            url.queryItems = querys
            url.percentEncodedQuery = url.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            
            var request = URLRequest(url: url.url!)
            request.httpMethod = method
            
            return request
            
        }
        
    }
    
    func request(type: requestType, completion: @escaping requestCompletion) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        do {
            
            let request = try buildRequest(type: type)
            
            session.dataTask(with: request) { data, response, error in
//                print("status : \((response as! HTTPURLResponse).statusCode)")
                
                completion(data, response, error)
            
            }.resume()
            session.finishTasksAndInvalidate()
            
        } catch {
            print(error)
        }
        
    }
    
}

