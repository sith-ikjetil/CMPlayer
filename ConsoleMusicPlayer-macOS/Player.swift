//
//  Player.swift
//  test
//
//  Created by Kjetil Kr Solberg on 17/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation
// Color codes
// black   30
// red     31
// green   32
// yellow  33
// blue    34
// magenta 35
// cyan    36
// white   37
class Player {
    private var playtime1: UInt64 = 0
    private var playtime2: UInt64 = 0
    private var quit: Bool = false
    private var exitCode: Int32 = 0
    private let widthSongNo: Int = 8
    private let widthArtist: Int = 33
    private let widthSong: Int = 33
    private let widthTime: Int = 5
    private var musicFormats: [String] = []
    private var songs: [SongEntry] = []
    
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        self.initializeSongs()

        Console.hideCursor()
        Console.clearScreen()
    }
    
    func run() -> Int32 {
        repeat {
            renderScreen()
        } while !quit
        
        return exitCode
    }
    
    
    
    func renderScreen() {
        renderFrame()
        
        //
        // ADD DEMO SONGS
        //
        
        renderSong(6, 123, "Vamp", "Still going strong", 444)
        renderSong(7, 333, "Dum Dum Boys", "Help", 201)
        
        var idx: Int = 8
        for s in self.songs {
            renderSong(idx, idx, "TEST", "SONG", s.playtime)
            idx += 1
        }
    }
    
    func renderFrame() {
        Console.printXY(1,1,"Console Music Player v0.1", 80, .Center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,4,"Sang No.", widthSongNo, .Ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(10,4,"Artist", widthArtist, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(43,4,"Song", widthSong, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(76,4,"Time", widthTime, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,5,"=", 80, .Left, "=", ConsoleColor.black, ConsoleColorModifier.none  , ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64)
    {
        Console.printXY(1, y, " ", 82, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1, y, String(songNo), widthSongNo, .Left, "0", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(10, y, artist, widthArtist, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(43, y, song, widthSong, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(76, y, itsRenderMsToFullString(time, false), widthTime, .Ignore, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func initializeSongs() {
        // DEBUG
        let result = findSongs(path: "/Users/kjetilso/Music")
        //let result = findSongs(path: PlayerPreferences.musicRootPath)
        for r in result {
            self.songs.append(SongEntry(path: URL(fileURLWithPath: r)))
        }
    }
    
    func findSongs(path: String) -> [String]
    {
        var results: [String] = []
        do
        {
            // DEBUG
            let result = try FileManager.default.contentsOfDirectory(atPath: path)
            for r in result {
                
                var nr = "\(path)/\(r)"
                if path.hasSuffix("/") {
                    nr = "\(path)\(r)"
                }
                
                if isDirectory(path: nr) {
                    results.append(contentsOf: findSongs(path: nr))
                }
                else {
                    if FileManager.default.isReadableFile(atPath: nr) {
                        for f in self.musicFormats {
                            if r.hasSuffix(f) {
                                results.append(nr)
                                break
                            }
                        }
                    }
                }
            }
        }
        catch {
            print("ERROR findSongs: \(error)")
            readLine()
            exit(1)
        }
        
        return results
    }
    
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        FileManager().fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}
