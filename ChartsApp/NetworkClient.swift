//
//  NetworkClient.swift
//  ChartsApp
//
//  Created by Erick Manrique on 3/8/18.
//  Copyright © 2018 Erick Manrique. All rights reserved.
//

import Foundation


import Foundation

class NetworkClient{
    
    static let shared = NetworkClient()
    
    let ApiScheme = "https"
    let ApiHost = "min-api.cryptocompare.com"
    //let ApiPort = 3000
    let ApiPath = "/data"

    func taskGetMethod(_ method: String, parameters: [String:Any]?, httpHeaderValues:[String:String]?, completionHandlerForGET:@escaping (_ result: Any?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: urlFromParameters(parameters, withPathExtension: method))
        
        if let httpHeaderValues = httpHeaderValues {
            for (key, value) in httpHeaderValues {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let conf = URLSessionConfiguration.default
        let session = URLSession(configuration: conf)
        let task = session.dataTask(with: request) { (data, response, error) in
            func sendError(_ error: String){
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGET(nil, NSError(domain: "taskGetMethod", code: 1, userInfo: userInfo))
            }
            guard error == nil else{
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            guard let data = data else{
                sendError("No data was returned by the request!")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let dataString = String(data: data, encoding: .utf8)
                if let dataArray = dataString?.components(separatedBy: "\""){
                    if dataArray.count == 1 {
                        sendError(dataString!)
                    } else {
                        sendError(dataArray[dataArray.endIndex-2])
                    }
                    
                }
                return
            }
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
            
        }
        task.resume()
        return task
        
    }
    
    func taskForPOSTMethod(_ method: String,
                           parameters: Any?,
                           httpHeaderValues:[String:String]?,
                           completionHandlerForPOST: @escaping (_ result: Any?, _ error: Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: urlFromParameters(nil, withPathExtension: method))
        request.httpMethod = "POST"
        
        if httpHeaderValues != nil && httpHeaderValues!.count > 0 {
            for (key, value) in httpHeaderValues! {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if parameters != nil {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: parameters!, options: [])
                request.httpBody = jsonData
            } catch {
                print("cannot append json data: \(parameters!)!")
            }
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) {[weak self] data, response, error in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                do {
                    let parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                    
                    completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: parsedResult))
                    
                } catch {
                    let dataString = String(data: data, encoding: .utf8)
                    if let dataArray = dataString?.components(separatedBy: "\""){
                        if dataArray.count == 1 {
                            sendError(dataString!)
                        } else {
                            sendError(dataArray[dataArray.endIndex-2])
                        }
                    }
                }
                return
            }
            self?.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
            
        }
        task.resume()
        return task
    }
    
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: Any?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any?
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            //            parsedResult = try JSONSerialization.jsonObject(with: data)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a URL from parameters
    func urlFromParameters(_ parameters: [String:Any]? = nil, withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = ApiScheme
        components.host = ApiHost
//        components.port = ApiPort
        components.path = ApiPath + (withPathExtension ?? "")
        
        components.queryItems = [URLQueryItem]()
        
        guard let parameters = parameters else {
            return components.url!
        }
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
}
