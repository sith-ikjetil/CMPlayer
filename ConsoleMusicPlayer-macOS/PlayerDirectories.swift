//
//  IgnitionDirectories.swift
//  Ignition
//
//  Created by Kjetil Kr Solberg on 14/01/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation
import Cocoa

internal class PlayerDirectories {
    internal static var homeDirectory: URL {
        return FileManager.default.homeDirectoryForCurrentUser
    }
    internal static var consoleMusicPlayerDirectory: URL {
        return PlayerDirectories.homeDirectory.appendingPathComponent(".console-music-player", isDirectory: true)
    }
    //internal static var ignitionDirectory: URL {
    //    return IgnitionDirectories.racecore24Directory.appendingPathComponent("Ignition", isDirectory: true)
    //}
    //internal static var skinsDirectory: URL {
    //    return IgnitionDirectories.ignitionDirectory.appendingPathComponent("Skins", isDirectory: true)
    //}
    //internal static var firmwareDirectory: URL {
    //    return IgnitionDirectories.ignitionDirectory.appendingPathComponent("Firmware", isDirectory: true)
    //}
    //internal static var updateDirectory: URL {
    //    return IgnitionDirectories.ignitionDirectory.appendingPathComponent("Update", isDirectory: true)
    //}
    //internal static var updaterAppDirectory: URL {
    //    return IgnitionDirectories.updateDirectory.appendingPathComponent("UpdaterApp", isDirectory: true)
    //}
    internal static var desktopDirectory: URL {
        return PlayerDirectories.homeDirectory.appendingPathComponent("Desktop", isDirectory: true)
    }
    internal static var applicationsDirectory: URL {
        return URL(fileURLWithPath: "/Applications")
    }
    internal static var volumesDirectory: URL {
        return URL(fileURLWithPath: "/Volumes")
    }
    
    internal static func ensureDirectoriesExistence() {
        let cmpDir: URL = PlayerDirectories.consoleMusicPlayerDirectory
        if FileManager.default.fileExists(atPath: cmpDir.path) == false {
            do {
                try FileManager.default.createDirectory(at: cmpDir, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                
            }
        }
        //let ignitionDir: URL = IgnitionDirectories.ignitionDirectory
        //if FileManager.default.fileExists(atPath: ignitionDir.path) == false {
        //    do {
        //        try FileManager.default.createDirectory(at: ignitionDir, withIntermediateDirectories: true, attributes: nil)
        //    }
        //    catch {
        //
        //    }
        //}
        //let skinsDir: URL = IgnitionDirectories.skinsDirectory
        //if FileManager.default.fileExists(atPath: skinsDir.path) == false {
        //    do {
        //        try FileManager.default.createDirectory(at: skinsDir, withIntermediateDirectories: true, attributes: nil)
        //    }
        //    catch {
        //
        //    }
        //}
        //let fwDir: URL = IgnitionDirectories.firmwareDirectory
        //if FileManager.default.fileExists(atPath: fwDir.path) == false {
        //    do {
        //        try FileManager.default.createDirectory(at: fwDir, withIntermediateDirectories: true, attributes: nil)
        //    }
        //    catch {
        //
        //    }
        //}
        //let updDir: URL = IgnitionDirectories.updateDirectory
        //if FileManager.default.fileExists(atPath: updDir.path) == false {
        //    do {
        //        try FileManager.default.createDirectory(at: updDir, withIntermediateDirectories: true, attributes: nil)
        //    }
        //    catch {
        //
        //    }
        //}
        //let updrAppDir: URL = IgnitionDirectories.updaterAppDirectory
        //if FileManager.default.fileExists(atPath: updrAppDir.path) == false {
        //    do {
        //        try FileManager.default.createDirectory(at: updrAppDir, withIntermediateDirectories: true, attributes: nil)
        //    }
        //    catch {
        //
        //    }
        //}
    }
}
