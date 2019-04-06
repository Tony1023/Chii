//
//  DateConverterUtil.swift
//  Chii
//
//  Created by Tony Lyu on 4/4/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import Foundation

class CustomDateConverter {
    
    let localFormatter = DateFormatter()
    let UTCFormatter = DateFormatter()
    
    init() {
        localFormatter.dateFormat = "yyyy.MM.dd"
        localFormatter.timeZone = Calendar.current.timeZone
        UTCFormatter.dateFormat = "yyyy.MM.dd"
        UTCFormatter.timeZone = TimeZone(identifier: "UTC")
    }
    
    func convert2UTC(from date: Date) -> Date {
        let dateString = localFormatter.string(from: date)
        return UTCFormatter.date(from: dateString)!
    }
    
    func convert2LocalDate(fromUTCDate date: Date) -> Date {
        let dateString = UTCFormatter.string(from: date)
        return localFormatter.date(from: dateString)!
    }
}
