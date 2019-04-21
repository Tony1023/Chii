//
//  DateConverterUtil.swift
//  Chii
//
//  Created by Tony Lyu on 4/4/19.
//  Copyright © 2019 Team_XL. All rights reserved.
//

import Foundation

class DateConverter {
    
    static let localFormatter = { () -> DateFormatter in
        let local = DateFormatter()
        local.dateFormat = "yyyy.MM.dd"
        local.timeZone = Calendar.current.timeZone
        return local
    }()
    static let UTCFormatter = { () -> DateFormatter in
        let UTC = DateFormatter()
        UTC.dateFormat = "yyyy.MM.dd"
        UTC.timeZone = TimeZone(identifier: "UTC")
        return UTC
    }()
    static let calendar = Calendar(identifier: .gregorian)
    
    
    static func convert2UTC(from date: Date) -> Date {
        let dateString = DateConverter.localFormatter.string(from: date)
        return DateConverter.UTCFormatter.date(from: dateString)!
    }
    
    static func convert2LocalDate(fromUTCDate date: Date) -> Date {
        let dateString = DateConverter.UTCFormatter.string(from: date)
        return DateConverter.localFormatter.date(from: dateString)!
    }
    
    static func getWeekStart(forLocalDate date: Date) -> Date {
        return getWeekStart(forUTCDate: convert2UTC(from: date))
    }
    
    static func getWeekEnd(forLocalDate date: Date) -> Date {
        return getWeekEnd(forUTCDate: convert2UTC(from: date))
    }
    
    static func getMonthStart(forLocalDate date: Date) -> Date {
        return getMonthStart(forUTCDate: convert2UTC(from: date))
    }
    
    static func getMonthEnd(forLocalDate date: Date) -> Date {
        return getMonthEnd(forUTCDate: convert2UTC(from: date))
    }
    
    static func getYearStart(forLocalDate date: Date) -> Date {
        return getYearStart(forUTCDate: convert2UTC(from: date))
    }
    
    static func getYearEnd(forLocalDate date: Date) -> Date {
        return getYearEnd(forUTCDate: convert2UTC(from: date))
    }
    
    static func getWeekStart(forUTCDate date: Date) -> Date {
        var start = Date()
        var interval: TimeInterval = 0.0
        if (DateConverter.calendar.dateInterval(of: .weekOfYear, start: &start, interval: &interval, for: date)) {
            return convert2UTC(from: start)
        } else {
            return date
        }
    }
    
    static func getWeekEnd(forUTCDate date: Date) -> Date {
        return getWeekStart(forUTCDate: date).addingTimeInterval(3600 * 24 * 7)
    }
    
    static func getMonthStart(forUTCDate date: Date) -> Date {
        var start = Date()
        var interval: TimeInterval = 0.0
        if (DateConverter.calendar.dateInterval(of: .month, start: &start, interval: &interval, for: date)) {
            return convert2UTC(from: start)
        } else {
            return date
        }
    }
    
    static func getMonthEnd(forUTCDate date: Date) -> Date {
        let range = calendar.range(of: .day, in: .month, for: date)
        let days = Double(range!.count)
        return getMonthStart(forUTCDate: date).addingTimeInterval(3600 * 24 * days)
    }
    
    static func getYearStart(forUTCDate date: Date) -> Date {
        var start = Date()
        var interval: TimeInterval = 0.0
        if (DateConverter.calendar.dateInterval(of: .year, start: &start, interval: &interval, for: date)) {
            return convert2UTC(from: start)
        } else {
            return date
        }
    }
    
    static func getYearEnd(forUTCDate date: Date) -> Date {
        let range = calendar.range(of: .day, in: .year, for: date)
        let days = Double(range!.count)
        return getYearStart(forUTCDate: date).addingTimeInterval(3600 * 24 * days)
    }
    

}
