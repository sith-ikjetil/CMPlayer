//
//  Util.swift
//  test
//
//  Created by Kjetil Kr Solberg on 17/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation


internal extension String {
    func itsToInt32() -> Int32 {
        var ns: String = ""
        for c in self {
            if c == "0" || c == "1" || c == "2" || c == "3" || c == "4" || c == "5" || c == "6" || c == "7" || c == "8" || c == "9" {
                ns += String(c)
            }
        }
        
        if ns.count == 0 {
            return 0
        }
        
        return Int32(ns)!
    }
    
    func itsToFloat() -> Float {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.number(from: self)!.floatValue
    }
    
    func itsToCGFloat() -> CGFloat {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return CGFloat(formatter.number(from: self)!.floatValue)
    }
    
    func itsToDouble() -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        return formatter.number(from: self)!.doubleValue
    }
    
    //func itsToNSColor() -> NSColor {
    //    let parts: [Substring]? = self.split(separator: ",")
    //    if parts != nil {
    //        if parts!.count == 4 {
    //            return NSColor(red: String(parts![0]).itsToCGFloat(), green: String(parts![1]).itsToCGFloat(), blue: String(parts![2]).itsToCGFloat(), alpha: String(parts![3]).itsToCGFloat())
    //        }
    //    }
    //    return NSColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(1))
    //}
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func convertStringToLengthPaddedString(_ maxLength: Int,_ padding: PrintPaddingTextAlign,_ paddingChar: Character) -> String {
        let msg: String = self
        if msg.count >= maxLength {
            return msg
        }
        
        switch padding {
        case .Ignore:
            if msg.count < maxLength {
                return msg
            }
            let idx = msg.index(msg.startIndex, offsetBy: maxLength)
            return String(msg[msg.startIndex..<idx])
        case .Center:
            var str = String(repeating: paddingChar, count: maxLength)
            var len: Double = Double(maxLength)
            len = len / 2.0
            let ulen = UInt64(len)
            if Double(ulen) < len {
                len -= 1
            }
            len -= Double(msg.count) / 2
            let si = str.index(str.startIndex, offsetBy: Int(len))
            str.insert(contentsOf: msg, at: si)
            return String(str[str.startIndex..<str.index(str.startIndex, offsetBy: maxLength)])
        case .Left:
            var str = String(repeating: paddingChar, count: maxLength)
            let len = 0
            let si = str.index(str.startIndex, offsetBy: len)
            str.insert(contentsOf: msg, at: si)
            return String(str[str.startIndex..<str.index(str.startIndex, offsetBy: maxLength)])
        case .Right:
            var str = String(repeating: paddingChar, count: maxLength)
            let len = maxLength-msg.count
            let si = str.index(str.startIndex, offsetBy: len)
            str.insert(contentsOf: msg, at: si)
            return String(str[str.startIndex..<str.index(str.startIndex, offsetBy: maxLength)]);
            
        }
    }
}

//
// Split ms to its parts
//
internal func itsSplitMsToHourMinuteSeconds(_ time_ms: UInt64 ) -> (part_hours: UInt64,part_minutes: UInt64,part_seconds: UInt64,part_ms: UInt64)
{
    let seconds: UInt64 = time_ms / 1000
    
    var part_hours: UInt64 = 0
    var part_minutes: UInt64 = 0
    var part_seconds: UInt64 = 0
    var part_ms: UInt64 = 0
    
    part_hours = seconds / 3600;
    part_minutes = ( seconds - ( part_hours * 3600 ) ) / 60;
    part_seconds = seconds - ( part_hours * 3600 ) - ( part_minutes * 60 );
    part_ms = time_ms - ( part_seconds * 1000 ) - ( part_minutes * 60 * 1000 ) - ( part_hours * 3600 * 1000 );
    
    return (part_hours, part_minutes, part_seconds, part_ms)
}

internal func itsSplitHourToYearWeekDayHour(_ houIn: UInt64 ) -> (houRest: UInt64, day: UInt64, week: UInt64, year: UInt64)
{
    var houRest: UInt64 = houIn;
    
    var day: UInt64 = houIn / 24;
    var week: UInt64 = day / 7;
    let year: UInt64 = week / 52;
    
    day -= ( week * 7 );
    
    week -= ( year * 52 );
    
    houRest -= week * 7 * 24;
    houRest -= day * 24;
    houRest -= year * 52 * 7 * 24;
    
    return (houRest, day, week, year)
}

internal func itsRenderMsToFullString(_ milliseconds: UInt64,_ bWithMilliseconds: Bool) -> String
{
    let (part_hours, min, sec, ms) = itsSplitMsToHourMinuteSeconds(milliseconds)
    let (houRest, day, week, year) = itsSplitHourToYearWeekDayHour(part_hours)
    
    var ss: String = ""
    
    if (year > 0) {
        if (year == 1)
        {
            ss += String(year) + " year "
        }
        else
        {
            ss += String(year) + " years "
        }
    }
    if (week > 0 || year > 0) {
        if (week == 1 || week == 0) {
            ss += String(week) + " week "
        }
        else
        {
            ss += String(week) + " weeks "
        }
    }
    if (day > 0 || week > 0 || year > 0) {
        if (day == 1 || day == 0)
        {
            ss += String(day) + " day "
        }
        else
        {
            ss += String(day) + " days "
        }
    }
    if (houRest > 0 || day > 0 || week > 0 || year > 0)
    {
        if (houRest == 1 || houRest == 0)
        {
            ss += String(houRest) + " hour "
        }
        else
        {
            ss += String(houRest) + " hours "
        }
    }
    
    if (min < 10) {
        ss += "0" + String(min) + ":"
    }
    else
    {
        ss += String(min) + ":"
    }
    if (sec < 10) {
        ss += "0" + String(sec);
    }
    else
    {
        ss += String(sec);
    }
    
    if (bWithMilliseconds)
    {
        if (ms < 10) {
            ss += ".00" + String(ms);
        }
        else if (ms < 100) {
            ss += ".0" + String(ms);
        }
        else {
            ss += "." + String(ms);
        }
    }
    
    return ss
}
