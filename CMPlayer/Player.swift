//
//  Player.swift
//  test
//
//  Created by Kjetil Kr Solberg on 17/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation
import AVFoundation
import CoreMedia

//
// Represents CMPlayer Player.
//
internal class Player {
    //
    // Internal properties/constants.
    //
    var audio1: AVAudioPlayer? = nil
    var audio2: AVAudioPlayer? = nil
    var audioPlayerActive: Int = -1
    var durationAudioPlayer1: UInt64 = 0
    var durationAudioPlayer2: UInt64 = 0
    
    //
    // Private properties/constants.
    //
    private var musicFormats: [String] = []
    private let initSongLibraryText: String = "Initializing Song Library"
    private var helpIndex: Int = 0
    private var currentCommandReady: Bool = false
    private let EXIT_CODE_ERROR_FINDING_FILES: Int32 = 1
    private let EXIT_CODE_ERROR_PLAYING_FILE: Int32 = 2
    //private let EXIT_CODE_ERROR_NOT_ENOUGH_MUSIC: Int32 = 3
    
    ///
    /// Initializes the application.
    ///
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        Console.initialize()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        Console.hideCursor()
        Console.echoOff()
        
        g_library.load()
        
        Console.clearScreen()
        MainWindow.renderHeader(showTime: false)
        self.initializeSongs()
        
        if g_songs.count < 2 {
            let wnd: InitialSetupWindow = InitialSetupWindow()
            if wnd.showWindow() {
                Console.clearScreen()
                MainWindow.renderHeader(showTime: false)
                self.initializeSongs()
            }
            if g_songs.count < 2 {
                let wnd: ErrorWindow = ErrorWindow()
                wnd.showWindow(message: "Could not find any music.\nThere must be at least two music files in musicRootPath.\nmusicRootPath was: \(PlayerPreferences.musicRootPath)")
                exit(EXIT_CODE_ERROR_FINDING_FILES)
            }
            else {
                PlayerPreferences.savePreferences()
            }
        }
        
        g_library.library = g_songs
        g_library.save()
        
        if PlayerPreferences.autoplayOnStartup && g_playlist.count > 0 {
            self.play(player: 1, playlistIndex: 0)
        }
        
        
        Console.clearScreen()
    }
    
    ///
    /// Plays audio.
    ///
    /// parameter: player. Player number. 1 or 2.
    /// parameter: playlistIndex. Index of playlist array to play.
    ///
    func play(player: Int, playlistIndex: Int) -> Void {
        self.audioPlayerActive = player
        if player == 1 {
            if self.audio1 == nil {
                do {
                    self.audio1 = try AVAudioPlayer(contentsOf:g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer1 = g_playlist[playlistIndex].duration
                    self.audio1?.play()
                }
                catch {
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
            else {
                do {
                    self.audio1?.stop()
                    self.audio1 = try AVAudioPlayer(contentsOf: g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer1 = g_playlist[playlistIndex].duration
                    self.audio1?.play()
                }
                catch {
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
        }
        else if player == 2 {
            if self.audio2 == nil {
                do {
                    self.audio2 = try AVAudioPlayer(contentsOf:g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer2 = g_playlist[playlistIndex].duration
                    self.audio2?.play()
                }
                catch {
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
            else {
                do {
                    self.audio2?.stop()
                    self.audio2 = try AVAudioPlayer(contentsOf: g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer2 = g_playlist[playlistIndex].duration
                    self.audio2?.play()
                }
                catch {
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)")
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
        }
    }
    
    ///
    /// Pauses audio playback.
    ///
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
    
    ///
    /// Resumes audio playback.
    ///
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
    
    ///
    /// Skips audio playback to next item in playlist.
    ///
    func skip(crossfade: Bool = true) -> Void {
        g_playlist.removeFirst()
        if g_playlist.count < 2 {
            var s = g_songs.randomElement()!
            while s.fileURL?.absoluteString == g_playlist[0].fileURL?.absoluteString {
                s = g_songs.randomElement()!
            }
            g_playlist.append(s)
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
    
    ///
    /// Runs the application.
    ///
    /// returnes: Int32. Exit code.
    ///
    func run() -> Int32 {
        g_mainWindow = MainWindow()
        return g_mainWindow?.showWindow() ?? 0
    }
    
    ///
    /// Initializes all the songs from files and library.
    ///
    func initializeSongs() -> Void {
        g_songs.removeAll()
        g_playlist.removeAll()
        
        #if DEBUG
            let result = findSongs(path: "/Users/kjetilso/Music")//"/Volumes/ikjetil/Music/G")
        #else
            let result = findSongs(path: PlayerPreferences.musicRootPath)
        #endif
        
        
        var i: Int = 1
        for r in result {
            printWorkingInitializationSongs( completed: Int(Double(i) * Double(100.0) / Double(result.count)))
            
            let u: URL = URL(fileURLWithPath: r)
            if let se = g_library.find(url: u) {
                g_songs.append(se)
            }
            else {
                g_songs.append(SongEntry(path: URL(fileURLWithPath: r),num: g_library.nextAvailableNumber()))
            }
            
            i += 1
        }
        
        if g_songs.count > 2 {
            let r1 = g_songs.randomElement()
            let r2 = g_songs.randomElement()
            
            g_playlist.append(r1!)
            g_playlist.append(r2!)
        }
    }
    
    ///
    /// Finds all songs from path and all folder paths under path. Songs must be of format in PlayerPreferences.musicFormats.
    ///
    /// parameter: path. The root path to start finding supported audio files.
    ///
    /// returnes: [String]. Array of file paths to audio files found.
    ///
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
                
                printWorkingInitializationSongs(completed: 0)
                
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
            results.removeAll()
            
            //let wnd: ErrorWindow = ErrorWindow()
            //wnd.showWindow(message: "EXIT_CODE_ERROR_FINDING_FILES\n\(error)")
            //exit(EXIT_CODE_ERROR_FINDING_FILES)
        }
        
        return results
    }
    
    ///
    /// Prints the initialization of songs.
    ///
    /// parameters: Int. Percent completed.
    ///
    func printWorkingInitializationSongs(completed: Int) -> Void {
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### INITIALIZING ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        
        let pst: String = "\(completed)%"
        Console.printXY(1, 5, initSongLibraryText + " " + pst, initSongLibraryText.count + pst.count + 1, .right, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,23,"PLEASE BE PATIENT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Determines if a path is a directory or not.
    ///
    /// parameter: path. Path to check.
    ///
    /// returnes: Bool. True if path is directory. False otherwise.
    ///
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        FileManager().fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }// isDirectory
}// Player
