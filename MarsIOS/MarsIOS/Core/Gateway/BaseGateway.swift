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
    private let baseApiUrl = "http://192.168.43.146:9000/api/"
    
    
    private static var Manager: Alamofire.SessionManager = {
               
                      // Create the server trust policies
                      let serverTrustPolicies: [String: ServerTrustPolicy] = [
                          
                           "192.168.43.146:9001": .disableEvaluation
                      ]
            
                      // Create custom manager
                      let configuration = URLSessionConfiguration.default
                      configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
                      let manager = Alamofire.SessionManager(
                           configuration: URLSessionConfiguration.default,
                           serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
                      )
            
                      return manager
                 }()
    
    public var manager: SessionManager
    
    override init() {
        self.manager = BaseGateway.Manager
    }
    
    public func cancelAllTasks() {
         manager.session.getAllTasks { (tasks) in
            tasks.forEach{ $0.cancel() }
        }
    }
    
    public func dataToParameters(_ data: [String: Any]) -> Parameters {
        var parameters = Parameters()
        for (key, value) in data {
            parameters.updateValue(value, forKey: key)
        }
        
        return parameters
    }
    
    public func postRequest(url: String, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        
        manager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { responseJSON in
                self.handleResponse(response: responseJSON, completion: { data in
                    completion(data)
                }, error: error, finally: finally)
        }
    }
    
    public func getImage(url: String, completion: @escaping (Image?) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        manager.request(url).responseImage { responseImage in
            if (responseImage.result.isFailure || responseImage.result.value == nil) {
                error(CustomError.imageLoadFail)
                return
            }
            
            completion(responseImage.result.value!)
            finally?()
        }
    }
    
    public func getRequest(url: String, parameters: Parameters, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
                
        manager.request(baseApiUrl + url, parameters: parameters).responseJSON { responseJSON in
                self.handleResponse(response: responseJSON, completion: { data in
                    completion(data)
                }, error: error, finally: finally)
            }
    }
    
    private func handleResponse(response: DataResponse<Any>, completion: @escaping (Any) -> (), error: @escaping (CustomError) -> (), finally: (() -> ())?) {
        
        switch response.result {
        case .success(let value):
            switch response.response?.statusCode {
            case 200:
                if let data = value as? [String: Any] {
                    completion(data)
                } else if let array = value as? [[String: Any]] {
                    completion(array)
                } else if let image = value as? Image {
                    completion(image)
                } else {
                    error(CustomError.parsingFail)
                }
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
