//
//  IgnitionPreferences.swift
//  Ignition
//
//  Created by Kjetil Kr Solberg on 17/01/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation
import AppKit

internal enum LogMaxSizeReached: String {
    case StopLogging = "StopLogging"
    case EmptyLog = "EmptyLog"
}

internal enum LogApplicationStartLoadType: String {
    case DoNotLoadOldLog = "DoNotLoadOldLog"
    case LoadOldLog = "LoadOldLog"
}

internal class PlayerPreferences {
    internal static let preferencesFilename: String = "ConsoleMediaPlayer.Preferences.xml"
    internal static var musicRootPath: String = "~/Music/"
    internal static var musicFormats: String = "mp3;mp2;m4a"
    internal static var enableBetaFirmware: Bool = false
    internal static var logInformation: Bool = true
    internal static var logWarning: Bool = true
    internal static var logError: Bool = true
    internal static var logDebug: Bool = false
    internal static var logOther: Bool = false
    internal static var logMaxSize: Int = 1000
    internal static var logMaxSizeReached: LogMaxSizeReached = LogMaxSizeReached.StopLogging
    internal static let logMaxSizes: [Int] = [100, 500, 1000, 2000, 3000, 4000, 5000]
    internal static var logApplicationStartLoadType: LogApplicationStartLoadType = LogApplicationStartLoadType.LoadOldLog
    
    internal init() {
        
    }
    
    internal static func loadPreferences(_ fileUrl: URL ) {
        do {
            let xd: XMLDocument = try XMLDocument(contentsOf: fileUrl)
            let xeRoot = xd.rootElement()!
            
            // General
            var elements: [XMLElement] = xeRoot.elements(forName: "general")
            if elements.count == 1 {
                let xeGeneral: XMLElement = elements[0]
                
                if let aEnableBetaFirmware = xeGeneral.attribute(forName: "enableBetaFirmware") {
                    PlayerPreferences.enableBetaFirmware = Bool(aEnableBetaFirmware.stringValue ?? "false") ?? false
                }
                if let aMusicRootPath = xeGeneral.attribute(forName: "musicRootPath") {
                    PlayerPreferences.musicRootPath = aMusicRootPath.stringValue!
                }
                if let aMusicFormats = xeGeneral.attribute(forName: "musicFormats") {
                    PlayerPreferences.musicFormats = aMusicFormats.stringValue!
                }
            }
            
            // log
            elements = xeRoot.elements(forName: "log")
            if elements.count == 1 {
                let xeLog: XMLElement = elements[0]
                
                if let aLogInformation = xeLog.attribute(forName: "logInformation") {
                    PlayerPreferences.logInformation = Bool(aLogInformation.stringValue ?? "true") ?? true
                }
                
                if let aLogWarning = xeLog.attribute(forName: "logWarning") {
                    PlayerPreferences.logWarning = Bool(aLogWarning.stringValue ?? "true") ?? true
                }
                
                if let aLogError = xeLog.attribute(forName: "logError") {
                    PlayerPreferences.logError = Bool(aLogError.stringValue ?? "true") ?? true
                }
                
                if let aLogDebug = xeLog.attribute(forName: "logDebug") {
                    PlayerPreferences.logDebug = Bool(aLogDebug.stringValue ?? "false") ?? false
                }
                
                if let aLogOther = xeLog.attribute(forName: "logOther") {
                    PlayerPreferences.logOther = Bool(aLogOther.stringValue ?? "false") ?? false
                }
                
                if let aLogMaxSize = xeLog.attribute(forName: "logMaxSize") {
                    PlayerPreferences.logMaxSize = Int(aLogMaxSize.stringValue ?? "1000") ?? 1000
                }
                
                if let aLogMaxSizeReached = xeLog.attribute(forName: "logMaxSizeReached") {
                    PlayerPreferences.logMaxSizeReached = LogMaxSizeReached(rawValue: aLogMaxSizeReached.stringValue ?? "StopLogging") ?? LogMaxSizeReached.StopLogging
                }
                
                if let aLogApplicationStartLoadType = xeLog.attribute(forName: "logApplicationStartLoadType") {
                    PlayerPreferences.logApplicationStartLoadType = LogApplicationStartLoadType(rawValue: aLogApplicationStartLoadType.stringValue ?? "LoadOldLog") ?? LogApplicationStartLoadType.LoadOldLog
                }
                
            }
            
        }
        catch {
            
        }
    }
    
    internal static func savePreferences() {
        let xeRoot: XMLElement = XMLElement(name: "preferences")
        
        //
        // general element
        //
        let xeGeneral: XMLElement = XMLElement(name: "general")
        xeRoot.addChild(xeGeneral)
        
        let xnEnableBetaFirmware: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnEnableBetaFirmware.name = "enableBetaFirmware"
        xnEnableBetaFirmware.setStringValue(String(PlayerPreferences.enableBetaFirmware), resolvingEntities: true)
        xeGeneral.addAttribute(xnEnableBetaFirmware)
        
        let xnMusicRootPath: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnMusicRootPath.name = "musicRootPath"
        xnMusicRootPath.setStringValue(PlayerPreferences.musicRootPath, resolvingEntities: true)
        xeGeneral.addAttribute(xnMusicRootPath)
        
        let xnMusicFormats: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnMusicFormats.name = "musicFormats"
        xnMusicFormats.setStringValue(PlayerPreferences.musicFormats, resolvingEntities: true)
        xeGeneral.addAttribute(xnMusicFormats)
        
        //
        // log
        //
        let xeLog: XMLElement = XMLElement(name: "log")
        xeRoot.addChild(xeLog)
        
        let xnLogInformation: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogInformation.name = "logInformation"
        xnLogInformation.setStringValue(String(self.logInformation), resolvingEntities: true)
        xeLog.addAttribute(xnLogInformation)
        
        let xnLogWarning: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogWarning.name = "logWarning"
        xnLogWarning.setStringValue(String(self.logWarning), resolvingEntities: true)
        xeLog.addAttribute(xnLogWarning)
        
        let xnLogError: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogError.name = "logError"
        xnLogError.setStringValue(String(self.logError), resolvingEntities: true)
        xeLog.addAttribute(xnLogError)
        
        let xnLogDebug: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogDebug.name = "logDebug"
        xnLogDebug.setStringValue(String(self.logDebug), resolvingEntities: true)
        xeLog.addAttribute(xnLogDebug)
        
        let xnLogOther: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogOther.name = "logOther"
        xnLogOther.setStringValue(String(self.logOther), resolvingEntities: true)
        xeLog.addAttribute(xnLogOther)
        
        let xnLogMaxSize: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogMaxSize.name = "logMaxSize"
        xnLogMaxSize.setStringValue(String(self.logMaxSize), resolvingEntities: true)
        xeLog.addAttribute(xnLogMaxSize)
        
        let xnLogMaxSizeReached: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogMaxSizeReached.name = "logMaxSizeReached"
        xnLogMaxSizeReached.setStringValue(self.logMaxSizeReached.rawValue, resolvingEntities: true)
        xeLog.addAttribute(xnLogMaxSizeReached)
        
        let xnLogApplicationStartLoadType: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
        xnLogApplicationStartLoadType.name = "logApplicationStartLoadType"
        xnLogApplicationStartLoadType.setStringValue(self.logApplicationStartLoadType.rawValue, resolvingEntities: true)
        xeLog.addAttribute(xnLogApplicationStartLoadType)
        
        //
        // save
        //
        let url: URL = PlayerDirectories.consoleMusicPlayerDirectory
        let fileUrl = url.appendingPathComponent(PlayerPreferences.preferencesFilename, isDirectory: false)
        
        let xd: XMLDocument = XMLDocument(rootElement: xeRoot)
        do {
            //let str: String = xd.xmlString
            try xd.xmlString.write(to: fileUrl, atomically: true, encoding: .utf8)
        }
        catch {
            
        }
    }
    
    internal static func ensureLoadPreferences()
    {
        let dir = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent(PlayerPreferences.preferencesFilename, isDirectory: false)
        if FileManager.default.fileExists(atPath: dir.path) == false {
            PlayerPreferences.savePreferences()
        }
        
        PlayerPreferences.loadPreferences(dir)
    }
}
