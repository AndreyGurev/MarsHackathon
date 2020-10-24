//
//  BaseGateway.swift
//  genie
//
//  Created by Andrey Gurev on 14.10.2020.
//  Copyright © 2020 Andrey Gurev. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

final class BaseGateway: NSObject {
    private let baseApiUrl = "https://api.genie.film/api/"
    
    var manager: SessionManager
    
    override init() {
        self.manager = Alamofire.SessionManager.default
    }
    
    func cancelAllTasks() {
         manager.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
    }
    
    func dataToParameters(_ data: [String: Any]) -> Parameters {
        var parameters = Parameters()
        for (key, value) in data {
            parameters.updateValue(value, forKey: key)
        }
        
        return parameters
    }
    
    func postRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (Error) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { responseJSON in
                self.handleResponse(responseJSON: responseJSON, completion: { data in
                    completion(data)
                }, error: error, finally: finally)
        }
    }
    
    func patchRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (Error) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { responseJSON in
            self.handleResponse(responseJSON: responseJSON, completion: { data in
                completion(data)
            }, error: error, finally: finally)
        }
    }
    
    func getRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (Error) -> (), finally: (() -> ())?) {
                
        manager.request(url, parameters: parameters, headers: headers).responseJSON { responseJSON in
                self.handleResponse(responseJSON: responseJSON, completion: { data in
                    completion(data)
                }, error: error, finally: finally)
            }
    }
    
    func deleteRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping () -> (), error: @escaping (Error) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .delete, parameters: parameters, headers: headers).responseJSON { responseJSON in
            self.handleResponse(responseJSON: responseJSON, completion: { _ in
                completion()
            }, error: error, finally: finally)
        }
    }
    
    func putRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (Error) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .put, parameters: parameters, headers: headers).responseJSON { responseJSON in
            self.handleResponse(responseJSON: responseJSON, completion: { data in
                completion(data)
            }, error: error, finally: finally)
        }
    }
    
    private func handleResponse(responseJSON: DataResponse<Any>, completion: @escaping (Any) -> (), error: @escaping (Error) -> (), finally: (() -> ())?) {
        switch responseJSON.result {
        case .success(let value):
            switch responseJSON.response?.statusCode {
            case 200:
                if let data = value as? [String: Any] {
                    completion(data)
                } else if let array = value as? [[String: Any]] {
                    completion(array)
                } else {
                    error(Error.parsingFail)
                }
            case 401:
                let tokenError = Error.tokenDie
                tokenError.code = 401
                error(tokenError)
            case 400, 422:
                error(handleError(value))
            case 500, 501:
                error(Error.serverError)
            default:
                error(Error.unknown)
            }
        
        case .failure(let errorMessage):
            if errorMessage._code != -999 {
                error(Error.networkFail)
            }
        }
        
        finally?()
    }
    
    private func handleError(_ value: Any?) -> Error {
        if let mappedError = Error.mapError(value: value) {
            return mappedError
        }
        
        return Error.unknown
    }
}
