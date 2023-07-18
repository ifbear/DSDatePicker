//
//  Date+Extensions.swift
//  DSDatePicker
//
//  Created by dexiong on 2023/7/14.
//

import Foundation

extension Date {
    
    /// 当年第一天
    internal static var startOfCurrentYear: Date {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        return calendar.date(from: components)!
    }
    
    /// 当年最后一天
    internal static var endOfCurrentYear: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfCurrentYear)!
    }
    
    internal static func date(of year: Int, to date: Date) -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.second = -1
        return calendar.date(byAdding: components, to: date)!
    }
}
