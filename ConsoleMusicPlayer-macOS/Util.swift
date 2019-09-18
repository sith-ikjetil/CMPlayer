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
    
    func convertStringToLengthPaddedString(_ maxLength: Int,_ padding: PrintPadding,_ paddingChar: Character) -> String {
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
