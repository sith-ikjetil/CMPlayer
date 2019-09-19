//
//  Player.swift
//  test
//
//  Created by Kjetil Kr Solberg on 17/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia

class Player {
    private var audio1: AVAudioPlayer? = nil
    private var audio2: AVAudioPlayer? = nil
    private var quit: Bool = false
    private var exitCode: Int32 = 0
    private let widthSongNo: Int = 8
    private let widthArtist: Int = 33
    private let widthSong: Int = 33
    private let widthTime: Int = 5
    private var musicFormats: [String] = []
    private var songs: [SongEntry] = []
    private var playlist: [SongEntry] = []
    private var currentCommand: String = ""
    private let commandsExit: [String] = ["exit", "quit"]
    private var currentCommandReady: Bool = false
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.console.music.player.macos.1", attributes: .concurrent)
    private let concurrentQueue2 = DispatchQueue(label: "cqueue.console.music.player.macos.2", attributes: .concurrent)
    private var currentChar: Int32 = -1
    
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        self.initializeSongs()

        Console.hideCursor()
        Console.clearScreen()
        Console.echoOff()
    }
    
    func run() -> Int32 {
        self.renderScreen()
        
        //
        // Count down songs
        //
        concurrentQueue1.async {
            while !self.quit {
                
                self.renderScreen()
                
                if self.playlist.count > 0 {
                    self.playlist[0].duration -= 150
                }
                
                let second: Double = 1000000
                usleep(useconds_t(0.150 * second))
            }
        }
        
        
        //
        // Get Input
        //
        concurrentQueue2.async {
            while !self.quit {
        
                if !self.currentCommandReady {
                    self.currentChar = getchar()
                    if self.currentChar != EOF && self.currentChar != 10 {
                        self.currentCommand.append(String(UnicodeScalar(UInt32(self.currentChar))!))
                        Console.printXY(1, 2, self.currentCommand, 80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
                    }
                    else if self.currentChar == 10 {
                        self.currentCommandReady = true
                    }
                }
            }
        }
        
        //
        // Act on input
        //
        while !self.quit {
            if self.currentCommandReady {
                if self.isCommandInCommands(self.currentCommand,self.commandsExit) {
                    self.quit = true
                }
                
                self.currentCommand = ""
                self.currentCommandReady = false
            }
        }
        
        return self.exitCode
    }
    
    func isCommandInCommands(_ command: String, _ commands: [String]) -> Bool {
        for c in commands {
            if command == c {
                return true
            }
        }
        return false
    }
    
    func renderScreen() {
        renderFrame()
        renderSongs()
    }
    
    func renderSongs() {
        var idx: Int = 5
        for s in self.playlist {
            if idx == 23 {
                break
            }
            
            renderSong(idx, s.number, s.artist, s.title, s.duration)
            idx += 1
        }
    }
    
    func renderFrame() {
        Console.printXY(1,1,"Console Music Player v0.1", 80, .Center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,3,"Sang No.", widthSongNo, .Ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(10,3,"Artist", widthArtist, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(43,3,"Song", widthSong, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(76,3,"Time", widthTime, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,4,"=", 80, .Left, "=", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        
        Console.printXY(1,23,">: " + self.currentCommand,80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64)
    {
        //Console.printXY(1, y, " ", 82, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1, y, String(songNo)+" ", widthSongNo+1, .Right, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(10, y, artist, widthArtist, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(43, y, song, widthSong, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(76, y, itsRenderMsToFullString(time, false), widthTime, .Ignore, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func initializeSongs() {
        // DEBUG
        let result = findSongs(path: "/Users/kjetilso/Music")
        //let result = findSongs(path: PlayerPreferences.musicRootPath)
        var i: Int = 1
        for r in result {
            self.songs.append(SongEntry(path: URL(fileURLWithPath: r),num: i))
            i += 1
        }
        
        if self.songs.count > 2 {
            let r1 = self.songs.randomElement()
            let r2 = self.songs.randomElement()
            
            self.playlist.append(r1!)
            self.playlist.append(r2!)
        }
        else if self.songs.count == 1 {
            let r1 = self.songs[0]
            
            self.playlist.append(r1)
        }
    }
    
    func findSongs(path: String) -> [String]
    {
        var results: [String] = []
        do
        {
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
