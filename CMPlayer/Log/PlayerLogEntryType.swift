//
//  IgnitionLogEntryType.swift
//  Ignition
//
//  Created by Kjetil Kr Solberg on 22/01/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation

///
/// Log entry type class.
///
internal enum PlayerLogEntryType: String {
    case Error = "Error"
    case Warning = "Warning"
    case Information = "Information"
    case Debug = "Debug"
    case Other = "Other"
}
