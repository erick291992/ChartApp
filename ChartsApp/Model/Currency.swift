//
//  Currency.swift
//  ChartsApp
//
//  Created by Erick Manrique on 3/9/18.
//  Copyright © 2018 Erick Manrique. All rights reserved.
//

import Foundation

class Currency {
    
    var high: Double
    var low: Double
    
    
    init(dictionary: [String: Any]) {
        self.high = dictionary["high"] as! Double
        self.low = dictionary["low"] as! Double
    }
}
