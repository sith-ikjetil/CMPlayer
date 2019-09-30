//
//  IgnitionLog.swift
//  Ignition
//
//  Created by Kjetil Kr Solberg on 21/01/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

internal class PlayerLog {
    internal static let logFilename: String = "CMPlayer.Log.xml"
    internal static var ApplicationLog: PlayerLog?
    internal var entries: [PlayerLogEntry] = []
    private var autoSave: Bool = false
    
    init(autoSave: Bool, loadOldLog: Bool ){
        self.autoSave = autoSave
        
        if loadOldLog {
            self.loadOldLog()
        }
    }
    
    internal func loadOldLog() {
        let url: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerLog.logFilename, isDirectory: false)
        
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                let xd: XMLDocument = try XMLDocument(contentsOf: url, options: XMLNode.Options.documentTidyXML)
                let elements: [XMLElement] = xd.rootElement()?.elements(forName: PlayerLogEntry.XML_ELEMENT_NAME) ?? []
                for e in elements {
                    self.entries.append(PlayerLogEntry(e: e))
                }
            }
        }
        catch {
            PlayerLog.ApplicationLog?.logError(title: "[PlayerLog].loadOldLog", text: "\(error)")
        }
    }
    
    internal func logError(title: String, text: String) {
        guard PlayerPreferences.logError else { return }
        if self.entries.count >= PlayerPreferences.logMaxSize {
            if PlayerPreferences.logMaxSizeReached == LogMaxSizeReached.EmptyLog {
                self.clear()
            }
            else {
                return
            }
        }
        self.entries.append(PlayerLogEntry(type: PlayerLogEntryType.Error, title: title, text: text, timeStamp: Date()))
        if self.autoSave {
            self.saveLog()
        }
    }
    internal func logWarning(title: String, text: String) {
        guard PlayerPreferences.logWarning else { return }
        if self.entries.count >= PlayerPreferences.logMaxSize {
            if PlayerPreferences.logMaxSizeReached == LogMaxSizeReached.EmptyLog {
                self.clear()
            }
            else {
                return
            }
        }
        self.entries.append(PlayerLogEntry(type: PlayerLogEntryType.Warning, title: title, text: text, timeStamp: Date()))
        if self.autoSave {
            self.saveLog()
        }
    }
    internal func logInformation(title: String, text: String) {
        guard PlayerPreferences.logInformation else { return }
        if self.entries.count >= PlayerPreferences.logMaxSize {
            if PlayerPreferences.logMaxSizeReached == LogMaxSizeReached.EmptyLog {
                self.clear()
            }
            else {
                return
            }
        }
        self.entries.append(PlayerLogEntry(type: PlayerLogEntryType.Information, title: title, text: text, timeStamp: Date()))
        if self.autoSave {
            self.saveLog()
        }
    }
    internal func logDebug(title: String, text: String) {
        guard PlayerPreferences.logDebug else { return }
        if self.entries.count >= PlayerPreferences.logMaxSize {
            if PlayerPreferences.logMaxSizeReached == LogMaxSizeReached.EmptyLog {
                self.clear()
            }
            else {
                return
            }
        }
        self.entries.append(PlayerLogEntry(type: PlayerLogEntryType.Debug, title: title, text: text, timeStamp: Date()))
        if self.autoSave {
            self.saveLog()
        }
    }
    internal func logOther(title: String, text: String) {
        guard PlayerPreferences.logOther else { return }
        if self.entries.count >= PlayerPreferences.logMaxSize {
            if PlayerPreferences.logMaxSizeReached == LogMaxSizeReached.EmptyLog {
                self.clear()
            }
            else {
                return
            }
        }
        self.entries.append(PlayerLogEntry(type: PlayerLogEntryType.Other, title: title, text: text, timeStamp: Date()))
        if self.autoSave {
            self.saveLog()
        }
        
    }
    internal func clear() {
        self.entries.removeAll()
    }
    
    internal func saveLogAsXMLDocument() -> XMLDocument {
        let xeRoot: XMLElement = XMLElement(name: "Log")
        let aRC24: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        aRC24.name = "id"
        aRC24.setStringValue("CMPlayer.macOS.Log", resolvingEntities: true)
        xeRoot.addAttribute(aRC24)
        
        for entry in self.entries
        {
            xeRoot.addChild(entry.toXMLElement())
        }
        
        return XMLDocument(rootElement: xeRoot)
    }
    
    internal func saveLog()
    {
        let xd: XMLDocument = self.saveLogAsXMLDocument()
        let xml: String = xd.xmlString
        let url: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerLog.logFilename, isDirectory: false)
        
        do {
            try xml.write(to: url, atomically: true,encoding: .utf8)
        }
        catch {
            PlayerLog.ApplicationLog?.logError(title: "[PlayerLog].saveLog", text: "\(error)")
        }
    }
    
    internal func saveLogAs(url: URL) {
        let xd: XMLDocument = self.saveLogAsXMLDocument()
        let xml: String = xd.xmlString
        
        do {
            try xml.write(to: url, atomically: true,encoding: .utf8)
        }
        catch {
            PlayerLog.ApplicationLog?.logError(title: "[PlayerLog].saveLogAs", text: "\(error)")
        }
    }
    
    internal func saveLogToString() -> String {
        let xd: XMLDocument = self.saveLogAsXMLDocument()
        return xd.xmlString
    }
}

