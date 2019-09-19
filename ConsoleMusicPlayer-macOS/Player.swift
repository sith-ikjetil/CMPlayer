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
    private let commandsHelp: [String] = ["help","?"]
    private let commandsPause: [String] = ["pause"]
    private let commandsResume: [String] = ["resume"]
    private var currentCommandReady: Bool = false
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.console.music.player.macos.1", attributes: .concurrent)
    private let concurrentQueue2 = DispatchQueue(label: "cqueue.console.music.player.macos.2", attributes: .concurrent)
    private var currentChar: Int32 = -1
    private let EXIT_CODE_ERROR_FINDING_FILES: Int32 = 1
    private let EXIT_CODE_ERROR_PLAYING_FILE: Int32 = 2
    private var isShowingTopWindow = false
    
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
                    printErrorMessage(text: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
            else {
                do {
                    self.audio1?.stop()
                    self.audio1 = try AVAudioPlayer(contentsOf: self.playlist[playlistIndex].fileURL!)
                    self.audio1?.play()
                }
                catch {
                    printErrorMessage(text: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
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
                    printErrorMessage(text: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
            else {
                do {
                    self.audio2?.stop()
                    self.audio2 = try AVAudioPlayer(contentsOf: self.playlist[playlistIndex].fileURL!)
                    self.audio2?.play()
                }
                catch {
                    printErrorMessage(text: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
        }
    }
    
    func pause() -> Void {
        if self.audio1 != nil {
            if self.audio1?.isPlaying ?? false {
                audio1?.pause()
            }
        }
        
        if self.audio2 != nil {
            if self.audio2?.isPlaying ?? false {
                audio2?.pause()
            }
        }
    }
    
    func resume() -> Void {
        if self.audio1 != nil && self.audioPlayerActive == 1 {
            if self.audio1?.currentTime.magnitude ?? 0 > 0 {
                audio1?.play()
            }
        }
        
        if self.audio2 != nil && self.audioPlayerActive == 2 {
            if self.audio2?.currentTime.magnitude ?? 0 > 0 {
                audio2?.play()
            }
        }
    }
    
    func skip(crossfade: Bool = true) -> Void {
        self.playlist.removeFirst()
        if self.playlist.count < 2 {
            var s = self.songs.randomElement()!
            while s.fileURL?.absoluteString == self.playlist[0].fileURL?.absoluteString {
                s = self.songs.randomElement()!
            }
            self.playlist.append(s)
        }
        
        if self.audioPlayerActive == -1 || self.audioPlayerActive == 2 {
            if self.audio2!.isPlaying {
                if !PlayerPreferences.crossfadeSongs || !crossfade {
                    self.audio2!.stop()
                }
                else {
                    self.audio2!.setVolume(0.0, fadeDuration: Double(PlayerPreferences.crossfadeTimeInSeconds) )
                }
            }
            self.play(player: 1, playlistIndex: 0)
        }
        else if self.audioPlayerActive == 1 {
            if self.audio1!.isPlaying {
                if !PlayerPreferences.crossfadeSongs || !crossfade {
                    self.audio1!.stop()
                }
                else {
                    self.audio1!.setVolume(0.0, fadeDuration: Double(PlayerPreferences.crossfadeTimeInSeconds) )
                }
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
                
                if !self.isShowingTopWindow {
                    self.renderSongs()
                }
                
                if self.playlist.count > 0 {
                    if self.audioPlayerActive == 1 {
                        let time = self.audio1!.currentTime.magnitude
                        self.playlist[0].duration = UInt64(Double(self.playlist[0].length) - time * Double(1000))
                    }
                    else if self.audioPlayerActive == 2 {
                        let time = self.audio2!.currentTime.magnitude
                        self.playlist[0].duration = UInt64(Double(self.playlist[0].length) - time * Double(1000))
                    }
                    
                    if (PlayerPreferences.crossfadeSongs && self.playlist[0].duration <= PlayerPreferences.crossfadeTimeInSeconds * 1000)
                        || self.playlist[0].duration <= 2000 {
                        self.playlist[0].duration = self.playlist[0].length
                        self.skip(crossfade: PlayerPreferences.crossfadeSongs)
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

            if !self.isShowingTopWindow {
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
                        self.skip(crossfade: false)
                    }
                    if self.isCommandInCommands(self.currentCommand, self.commandsPause) {
                        self.pause()
                    }
                    if self.isCommandInCommands(self.currentCommand, self.commandsResume) {
                        self.resume()
                    }
                    if self.isCommandInCommands(self.currentCommand, self.commandsHelp) {
                        self.isShowingTopWindow = true
                        self.renderHelp()
                        var ch = getchar()
                        while ch == EOF {
                            ch = getchar()
                        }
                        self.isShowingTopWindow = false
                        Console.clearScreen()
                        self.renderScreen()
                    }
                    self.currentCommand = ""
                }
                self.renderCommandLine()
                self.renderStatusLine()
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
        renderCommandLine()
        renderStatusLine()
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
    
    func renderFrame() -> Void {
        Console.printXY(1,1,"Console Music Player v0.1", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,3,"Song No.", widthSongNo, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(10,3,"Artist", widthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(43,3,"Song", widthSong, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(76,3,"Time", widthTime, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,4,"=", 80, .left, "=", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64) -> Void
    {
        //Console.printXY(1, y, " ", 82, .Left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1, y, String(songNo)+" ", widthSongNo+1, .right, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(10, y, artist, widthArtist, .left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(43, y, song, widthSong, .left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(76, y, itsRenderMsToFullString(time, false), widthTime, .ignore, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func renderCommandLine() -> Void
    {
        Console.printXY(1,23,">: " + self.currentCommand,80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    func renderStatusLine() -> Void
    {
        Console.printXY(1,24,"Files Found: \(self.songs.count)",80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func renderHelp() -> Void {
        Console.clearScreen()
        Console.printXY(1,1,"Console Music Player v0.1", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,3,"### HELP ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,5," exit, quit", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,6," :: exits application", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,8," next, skip", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,9," :: plays next song", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,11," pause, resume", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,12," :: pauses or resumes playback", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,14," help", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,15," :: shows this help screen while music plays in background", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT HELP", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func initializeSongs() {
        // DEBUG
        let result = findSongs(path: "/Users/kjetilso/Music")//"/Volumes/ikjetil/Music/G")
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
            printErrorMessage(text: "EXIT_CODE_ERROR_FINDING_FILES\n\(error)")
            exit(EXIT_CODE_ERROR_FINDING_FILES)
        }
        
        return results
    }
    
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        FileManager().fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    func printErrorMessage(text: String) -> Void {
        Console.clearScreen()
        Console.printXY(1, 1, "Console Music Player Error", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1, 3, text, 80, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.red, ConsoleColorModifier.bold)
        print("")
        print("")
        print(Console.applyTextColor(colorBg: ConsoleColor.black, modifierBg: ConsoleColorModifier.none, colorText: ConsoleColor.white, modifierText: ConsoleColorModifier.bold, text: "> Press ENTER Key To Continue <"))
        _ = readLine()
    }
}
