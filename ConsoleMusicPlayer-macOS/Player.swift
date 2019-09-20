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
    private var searchResult: [SongEntry] = []
    private var currentCommand: String = ""
    private let commandsExit: [String] = ["exit", "quit"]
    private let commandsNextSong: [String] = ["next", "skip"]
    private let commandsHelp: [String] = ["help","?"]
    private let commandsPause: [String] = ["pause"]
    private let commandsResume: [String] = ["resume"]
    private let commandsSearch: [String] = ["search"]
    private let commandsRepaint: [String] = ["repaint","redraw"]
    private var searchIndex: Int = 0
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
                    if self.isCommandInCommands(self.currentCommand, self.commandsRepaint) {
                        Console.clearScreen()
                        self.renderScreen()
                    }
                    if let num = Int32(self.currentCommand) {
                        if num > 0 {
                            for se in self.songs {
                                if se.number == num {
                                    self.playlist.append(se)
                                    break
                                }
                            }
                        }
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
                    var parts = self.currentCommand.components(separatedBy: " ")
                    if parts.count > 1 {
                        if self.isCommandInCommands(parts[0], self.commandsSearch) {
                            _ = parts.removeFirst()
                            self.searchIndex = 0
                            self.performSearch(terms: parts)
                            self.isShowingTopWindow = true
                            self.renderSearch()
                            var ch = getchar()
                            while ch == EOF || ch == 27 || ch == 91 || ch == 65 || ch == 66 {
                                if ch == 27 {
                                    ch = getchar()
                                }
                                if ch == 91 {
                                    ch = getchar()
                                }
                                
                                if ch == 66 { // DOWN
                                    if (self.searchIndex + 17) < self.searchResult.count {
                                        self.searchIndex += 1
                                        self.renderSearch()
                                    }
                                }
                                if ch == 65 { // UP
                                    if self.searchIndex > 0 {
                                        self.searchIndex -= 1
                                        self.renderSearch()
                                    }
                                }
                                ch = getchar()
                            }
                            self.isShowingTopWindow = false
                            Console.clearScreen()
                            self.renderScreen()
                        }
                    }
                    
                    self.currentCommand = ""
                }
                self.renderCommandLine()
                self.renderStatusLine()
            }
        }
        
        return self.exitCode
    }
    
    func performSearch(terms: [String]) -> Void {
        self.searchResult.removeAll(keepingCapacity: false)
        for se in self.songs {
            let artist = se.artist.lowercased()
            let title = se.title.lowercased()
            
            for t in terms {
                let term = t.lowercased()
                
                if artist.contains(term) || title.contains(term) {
                    self.searchResult.append(se)
                    break
                }
            }
        }
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
            if idx == 22 {
                break
            }
            
            renderSong(idx, s.number, s.artist, s.title, s.duration)
            idx += 1
        }
    }
    
    func renderHeader() -> Void {
        Console.printXY(1,1,"Console Music Player | 1.0.0.1", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func renderFrame() -> Void {
        
        renderHeader()
        
        Console.printXY(1,3,"Song No.", widthSongNo, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(10,3,"Artist", widthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(43,3,"Title", widthSong, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(76,3,"Time", widthTime, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,4,"=", 80, .left, "=", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64) -> Void
    {

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
        
        renderHeader()
        
        Console.printXY(1,3,"### HELP ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,5," exit, quit", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,6," :: exits application", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,8," next, skip", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,9," :: plays next song", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,11," pause, resume", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,12," :: pauses or resumes playback", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,14," search <word 1>...<word n>", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,15," :: searches artist and title for a match. case insensitive", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,17," help", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        Console.printXY(1,18," :: shows this help screen while music plays in background", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT HELP", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func renderSearch() -> Void {
        Console.clearScreen()
        
        renderHeader()
        
        Console.printXY(1,3,"### SEARCH RESULT ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = searchIndex
        let max = searchIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > searchResult.count - 1 {
                break
            }
            
            let se = searchResult[index_search]
            
            Console.printXY(1, index_screen_lines, "\(se.number) ", widthSongNo+1, .right, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            
            Console.printXY(10, index_screen_lines, "\(se.artist)", widthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)

            Console.printXY(43, index_screen_lines, "\(se.title)", widthSong, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(76, index_screen_lines, itsRenderMsToFullString(se.length, false), widthTime, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT SEARCH RESULT.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
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
