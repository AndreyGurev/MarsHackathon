//
//  BaseGateway.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit
import Alamofire
import AlamofireImage

final class BaseGateway: NSObject {
    private let baseApiUrl = ""
    
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
    
    func postRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { responseJSON in
                self.handleResponse(responseJSON: responseJSON, completion: { data in
                    completion(data)
                }, error: error, finally: finally)
        }
    }
    
    func patchRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { responseJSON in
            self.handleResponse(responseJSON: responseJSON, completion: { data in
                completion(data)
            }, error: error, finally: finally)
        }
    }
    
    func getRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
                
        manager.request(url, parameters: parameters, headers: headers).responseJSON { responseJSON in
                self.handleResponse(responseJSON: responseJSON, completion: { data in
                    completion(data)
                }, error: error, finally: finally)
            }
    }
    
    func deleteRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping () -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .delete, parameters: parameters, headers: headers).responseJSON { responseJSON in
            self.handleResponse(responseJSON: responseJSON, completion: { _ in
                completion()
            }, error: error, finally: finally)
        }
    }
    
    func putRequest(url: String, headers: HTTPHeaders, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .put, parameters: parameters, headers: headers).responseJSON { responseJSON in
            self.handleResponse(responseJSON: responseJSON, completion: { data in
                completion(data)
            }, error: error, finally: finally)
        }
    }
    
    private func handleResponse(responseJSON: DataResponse<Any>, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        switch responseJSON.result {
        case .success(let value):
            switch responseJSON.response?.statusCode {
            case 200:
                if let data = value as? [String: Any] {
                    completion(data)
                } else if let array = value as? [[String: Any]] {
                    completion(array)
                } else {
                    error(CustomError.parsingFail)
                }
            case 401:
                let tokenError = CustomError.tokenDie
                tokenError.code = 401
                error(tokenError)
            case 400, 422:
                error(handleError(value))
            case 500, 501:
                error(CustomError.serverError)
            default:
                error(CustomError.unknown)
            }
        
        case .failure(let errorMessage):
            if errorMessage._code != -999 {
                error(CustomError.networkFail)
            }
        }
        
        finally?()
    }
    
    private func handleError(_ value: Any?) -> CustomError {
        if let mappedError = CustomError.mapError(value: value) {
            return mappedError
        }
        
        return CustomError.unknown
    }
}
