//
//  IgnitionLogEntry.swift
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
/// Log entry class.
///
internal class PlayerLogEntry {
    static let XML_ELEMENT_NAME: String = "LogEntry"
    var type: PlayerLogEntryType
    var title: String
    var text: String
    var timeStamp: Date
    
    ///
    /// Overloaded initializer
    ///
    /// parameter type: log entry type.
    /// parameter title: log entry title.
    /// parameter text: log entry information.
    /// parameter timeStamp: date time of log entry.
    ///
    init( type: PlayerLogEntryType, title: String, text: String, timeStamp: Date)
    {
        self.type = type
        self.title = title
        self.text = text
        self.timeStamp = timeStamp
    }
    
    ///
    /// Overloaded initializer
    ///
    /// parameter e: XML element representing a log entry
    ///
    init( e: XMLElement )
    {
        self.title = e.attribute(forName: "Title")?.stringValue ?? ""
        self.text = e.stringValue ?? ""
        self.type = PlayerLogEntryType(rawValue: e.attribute(forName: "Type")?.stringValue ?? "Other") ?? PlayerLogEntryType.Other
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        self.timeStamp = dateFormatter.date(from: e.attribute(forName: "TimeStamp")?.stringValue ?? "") ?? Date()
    }
    
    ///
    /// Creates an xml element representing this log entry.
    ///
    /// returnes: XML element.
    ///
    func toXMLElement() -> XMLElement {
        let xe = XMLElement(name: PlayerLogEntry.XML_ELEMENT_NAME)
        xe.setStringValue(self.text, resolvingEntities: true)
        
        let xnTitle: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnTitle.name = "Title"
        xnTitle.setStringValue(self.title, resolvingEntities: true)
        xe.addAttribute(xnTitle)
        
        let xnType: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnType.name = "Type"
        xnType.setStringValue(self.type.rawValue, resolvingEntities: true)
        xe.addAttribute(xnType)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        let xnTimeStamp: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnTimeStamp.name = "TimeStamp"
        xnTimeStamp.setStringValue(dateFormatter.string(from: self.timeStamp) , resolvingEntities: true)
        xe.addAttribute(xnTimeStamp)
        
        return xe
    }//toXMLElement
}// PlayerLogEntry
