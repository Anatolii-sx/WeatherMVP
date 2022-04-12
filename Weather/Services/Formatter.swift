//
//  Formatter.swift
//  Weather
//
//  Created by Анатолий Миронов on 12.04.2022.
//

import Foundation

class Formatter {
    static let shared = Formatter()
    
    enum FormatType: String {
        case hours = "HH"
        case hoursAndMinutes = "HH:mm"
        case days = "EEEE"
    }
    
    private init() {}
    
    static func getFormat(unixTime: Int, timezone: String, formatType: String) -> String {
        
        let time = Double(unixTime)
        let date = "\(Date(timeIntervalSince1970: time))"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        
        guard let theDate = dateFormatter.date(from: date) else { return "" }

        let newDateFormatter = DateFormatter()
        newDateFormatter.timeZone = TimeZone(identifier: timezone)
        newDateFormatter.dateFormat = formatType
        
        return newDateFormatter.string(from: theDate)
    }
}
