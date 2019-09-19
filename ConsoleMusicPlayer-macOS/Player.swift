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
    private var audioPlayerActive: Int = -1
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
    private let commandsNextSong: [String] = ["next", "skip"]
    private var currentCommandReady: Bool = false
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.console.music.player.macos.1", attributes: .concurrent)
    private let concurrentQueue2 = DispatchQueue(label: "cqueue.console.music.player.macos.2", attributes: .concurrent)
    private var currentChar: Int32 = -1
    
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        self.initializeSongs()
        
        if PlayerPreferences.autoplayOnStartup && self.playlist.count > 0 {
            self.play(player: 1, playlistIndex: 0)
        }

        Console.hideCursor()
        Console.clearScreen()
        Console.echoOff()
    }
    
    func play(player: Int, playlistIndex: Int) -> Void {
        self.audioPlayerActive = player
        if player == 1 {
            if self.audio1 == nil {
                do {
                    self.audio1 = try AVAudioPlayer(contentsOf:self.playlist[playlistIndex].fileURL!)
                    self.audio1?.play()
                }
                catch {
                    print("error playing player \(player) on index \(playlistIndex) and error is \(error)")
                    exit(1)
                }
            }
            else {
                do {
                    self.audio1?.stop()
                    self.audio1 = try AVAudioPlayer(contentsOf: self.playlist[playlistIndex].fileURL!)
                    self.audio1?.play()
                }
                catch {
                    print("error playing player \(player) on index \(playlistIndex) and error is \(error)")
                    exit(1)
                }
            }
        }
        else if player == 2 {
            if self.audio2 == nil {
                do {
                    self.audio2 = try AVAudioPlayer(contentsOf:self.playlist[playlistIndex].fileURL!)
                    self.audio2?.play()
                }
                catch {
                    print("error playing player \(player) on index \(playlistIndex) and error is \(error)")
                    exit(1)
                }
            }
            else {
                do {
                    self.audio2?.stop()
                    self.audio2 = try AVAudioPlayer(contentsOf: self.playlist[playlistIndex].fileURL!)
                    self.audio2?.play()
                }
                catch {
                    print("error playing player \(player) on index \(playlistIndex) and error is \(error)")
                    exit(1)
                }
            }
        }
    }
    
    func skip() -> Void {
        self.playlist.removeFirst()
        if self.playlist.count < 2 {
            self.playlist.append( self.songs.randomElement()! )
            if self.playlist.count < 2 {
                self.playlist.append( self.songs.randomElement()! )
            }
        }
        
        if self.audioPlayerActive == -1 || self.audioPlayerActive == 2 {
            if self.audio2!.isPlaying {
                self.audio2!.stop()
            }
            self.play(player: 1, playlistIndex: 0)
        }
        else if self.audioPlayerActive == 1 {
            if self.audio1!.isPlaying {
                self.audio1!.stop()
            }
            self.play(player: 2, playlistIndex: 0)
        }
    }
    
    func run() -> Int32 {
        self.renderScreen()
        
        //
        // Count down and render songs
        //
        concurrentQueue1.async {
            while !self.quit {
                
                self.renderSongs()//Screen()
                
                if self.playlist.count > 0 {
                    if self.audioPlayerActive == 1 {
                        let time = self.audio1!.currentTime.magnitude
                        self.playlist[0].duration = UInt64(Double(self.playlist[0].length) - time * Double(1000))
                    }
                    else if self.audioPlayerActive == 2 {
                        let time = self.audio2!.currentTime.magnitude
                        self.playlist[0].duration = UInt64(Double(self.playlist[0].length) - time * Double(1000))
                    }
                    
                    if self.playlist[0].duration <= 2000 {
                        self.playlist[0].duration = self.playlist[0].length
                        self.skip()
                    }
                }
                
                let second: Double = 1000000
                usleep(useconds_t(0.050 * second))
            }
        }
        
        
        //
        // Get Input and Process
        //
        while !self.quit {

            self.currentChar = getchar()
            if self.currentChar != EOF && self.currentChar != 10 && self.currentChar != 127 {
                self.currentCommand.append(String(UnicodeScalar(UInt32(self.currentChar))!))
                //Console.printXY(1, 2, self.currentCommand, 80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else if self.currentChar == 127 {
                if self.currentCommand.count > 0 {
                    self.currentCommand.removeLast()
                }
            }
            else if self.currentChar == 10 {
                if self.isCommandInCommands(self.currentCommand, self.commandsExit) {
                    self.quit = true
                }
                if self.isCommandInCommands(self.currentCommand, self.commandsNextSong) {
                    self.skip()
                }
                
                self.currentCommand = ""
            }
            self.renderCommandLine()
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
        renderCommandLine()
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
    }
    
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64)
    {
        //Console.printXY(1, y, " ", 82, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1, y, String(songNo)+" ", widthSongNo+1, .Right, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(10, y, artist, widthArtist, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(43, y, song, widthSong, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(76, y, itsRenderMsToFullString(time, false), widthTime, .Ignore, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func renderCommandLine()
    {
        Console.printXY(1,23,">: " + self.currentCommand,80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
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
