//
//  NetworkClient+API.swift
//  ChartsApp
//
//  Created by Erick Manrique on 3/8/18.
//  Copyright © 2018 Erick Manrique. All rights reserved.
//

import Foundation

extension NetworkClient {
    //fsym - The cryptocurrency symbol of interest
    //tsym - The currency symbol to convert into
    //limit - the number of result you want. default = 20
    func getCurrencyData(fsym:String, tsym:String, limit:Int = 20, completion: @escaping(_ currencies:[Currency]?,_ err:Error?)->Void) {
        var parameters = [String:Any]()
        parameters["fsym"] = fsym
        parameters["tsym"] = tsym
        parameters["limit"] = limit
        
        _ = taskGetMethod("/histoday", parameters: parameters, httpHeaderValues: nil, completionHandlerForGET: { (res, err) in
            
            if err != nil {
                completion(nil, err)
            } else {
                let jsonData = res as! [String:Any]
                if let response = jsonData["Response"] as? String {
                    if response == "Success" {
                        if let data = jsonData["Data"] as? [[String:Any]] {
                            let currencies = data.map({
                                return Currency(dictionary: $0)
                            })
                            completion(currencies, nil)
                        }
                    }
                }
            }
        })
        
    }
    
}
