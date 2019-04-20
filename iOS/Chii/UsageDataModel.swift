//
//  UsageDataModel.swift
//  Chii
//
//  Created by Tony Lyu on 4/14/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import Foundation

class UsageDataModel {
    
    var dailyUsage = [Date: Data]()
    
    struct Data {
        var date: Date
        var puffs: Int
        var average: Double
    }
    
    var grandAverage: Double!
    
}
