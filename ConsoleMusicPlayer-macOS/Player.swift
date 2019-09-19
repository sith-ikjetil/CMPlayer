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
    private let widthSongNo: Int = 7
    private let widthArtist: Int = 33
    private let widthSong: Int = 33
    private let widthTime: Int = 5
    private var musicFormats: [String] = []
    private var songs: [SongEntry] = []
    private var playlist: [SongEntry] = []
    private var currentCommand: String = ""
    private let commandsExit: [String] = ["exit", "quit"]
    private let concurrentQueue = DispatchQueue(label: "cqueue.console.music.player.macos", attributes: .concurrent)
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        self.initializeSongs()

        Console.hideCursor()
        Console.clearScreen()
        
        var c: cc_t = 0
        var cct = (c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c)
        var oldt: termios = termios(c_iflag: 0, c_oflag: 0, c_cflag: 0, c_lflag: 0, c_cc: cct, c_ispeed: 0, c_ospeed: 0)
        
        tcgetattr(STDIN_FILENO, &oldt) // 1473
        var newt = oldt
        
        newt.c_lflag = newt.c_lflag & ~UInt(ECHO) //1217  // Reset ICANON and Echo off
        tcsetattr( STDIN_FILENO, TCSANOW, &newt)
    }
    
    func run() -> Int32 {
        self.renderScreen()
        
        concurrentQueue.async {
            while !self.quit {
                self.renderScreen()
                sleep(1)
            }
        }
        
        repeat {
            Console.printXY(1,23,">: ",80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            Console.gotoXY(4, 23);
            
            var buf = String()
            var c = getchar()
            while c != EOF && c != 10 {
                buf.append(String(UnicodeScalar(UInt32(c))!))
                c = getchar()
            }
            currentCommand = buf
            
            self.songs[0].duration -= 1000
            
            
            Console.printXY(1,2,currentCommand,80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            
            if isCommandInCommands(currentCommand,commandsExit) {
                self.quit = true
            }
        } while !self.quit
        
        return exitCode
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
        for s in self.songs {
            if idx == 23 {
                break
            }
            
            renderSong(idx, idx-4, s.artist, s.title, s.duration)
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
        
        Console.printXY(1,23,">: ",80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64)
    {
        Console.printXY(1, y, " ", 82, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1, y, String(songNo), widthSongNo, .Right, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
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
