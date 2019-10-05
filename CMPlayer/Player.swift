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
    var isPaused: Bool = false
    
    //
    // Private properties/constants.
    //
    private var musicFormats: [String] = []
    private var filesFound = false
    private let findingFilesText: String = "Finding Song Files:"
    private let initSongLibraryText: String = "Updating Song Library:"
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
        PlayerLog.ApplicationLog = PlayerLog(autoSave: true, loadOldLog: (PlayerPreferences.logApplicationStartLoadType == LogApplicationStartLoadType.LoadOldLog))
        
        PlayerLog.ApplicationLog?.logInformation(title: "CMPlayer", text: "Application Started.")
        
        Console.initialize()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        g_library.load()
        
        if PlayerPreferences.musicRootPath.count == 0 {
            let wnd: SetupWindow = SetupWindow()
            while !wnd.showWindow() {
                
            }
            PlayerPreferences.savePreferences()
            Console.clearScreen()
            MainWindow.renderHeader(showTime: false)
            self.initializeSongs()
        }
        else {
            Console.clearScreen()
            MainWindow.renderHeader(showTime: false)
            self.initializeSongs()
        }
        
        g_library.library = g_songs
        g_library.save()
        
        if PlayerPreferences.autoplayOnStartup && g_playlist.count > 0 {
            self.play(player: 1, playlistIndex: 0)
        }
        
        Console.clearScreenCurrentTheme()
    }
    
    ///
    /// Plays audio.
    ///
    /// parameter player: Player number. 1 or 2.
    /// parameter playlistIndex: Index of playlist array to play.
    ///
    func play(player: Int, playlistIndex: Int) -> Void {
        guard g_songs.count > 0 && g_playlist.count > playlistIndex else {
            return
        }
        
        self.audioPlayerActive = player
        if player == 1 {
            if self.audio1 == nil {
                do {
                    self.audio1 = try AVAudioPlayer(contentsOf:g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer1 = g_playlist[playlistIndex].duration
                    self.audio1?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "Player::play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: msg)
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
            else {
                do {
                    self.audio1?.stop()
                    self.audio1 = try AVAudioPlayer(contentsOf: g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer1 = g_playlist[playlistIndex].duration
                    self.audio1?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "Player::play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: msg)
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
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "Player::play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: msg)
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
            else {
                do {
                    self.audio2?.stop()
                    self.audio2 = try AVAudioPlayer(contentsOf: g_playlist[playlistIndex].fileURL!)
                    self.durationAudioPlayer2 = g_playlist[playlistIndex].duration
                    self.audio2?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "Player::play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.showWindow(message: msg)
                    exit(EXIT_CODE_ERROR_PLAYING_FILE)
                }
            }
        }
    }
    
    ///
    /// Pauses audio playback.
    ///
    func pause() -> Void {
        guard g_songs.count > 0 else {
            return
        }
        
        g_lock.lock()
        
        if self.audio1 != nil {
            if self.audio1?.isPlaying ?? false {
                audio1?.pause()
                self.isPaused = true
            }
        }
        
        if self.audio2 != nil {
            if self.audio2?.isPlaying ?? false {
                audio2?.pause()
                self.isPaused = true
            }
        }
        
        g_lock.unlock()
    }
    
    ///
    /// Resumes audio playback.
    ///
    func resume() -> Void {
        guard g_songs.count > 0 else {
            return
        }
        
        g_lock.lock()
        
        if self.audio1 != nil && self.audioPlayerActive == 1 {
            if self.audio1?.currentTime.magnitude ?? 0 > 0 {
                audio1?.play()
                self.isPaused = false
            }
        }
        
        if self.audio2 != nil && self.audioPlayerActive == 2 {
            if self.audio2?.currentTime.magnitude ?? 0 > 0 {
                audio2?.play()
                self.isPaused = false
            }
        }
        
        g_lock.unlock()
    }
    
    ///
    /// Skips audio playback to next item in playlist.
    ///
    /// parameter crossfade: True if skip should crossfade. False otherwise.
    ///
    func skip(play: Bool = true, crossfade: Bool = true) -> Void {
        guard g_songs.count > 0 && g_playlist.count >= 1 else {
            return
        }
        
        g_playlist.removeFirst()
        if g_playlist.count < 2 {
            if g_modeSearch.count > 0 && g_searchResult.count > 0 {
                let s = g_searchResult.randomElement()!
                g_playlist.append(s)
            }
            else {
                let s = g_songs.randomElement()!
                g_playlist.append(s)
            }
        }
        
        if self.audioPlayerActive == -1 || self.audioPlayerActive == 2 {
            if self.audio2 != nil {
                if self.audio2!.isPlaying {
                    if !PlayerPreferences.crossfadeSongs || !crossfade {
                        self.audio2!.stop()
                    }
                    else {
                        self.audio2!.setVolume(0.0, fadeDuration: Double(PlayerPreferences.crossfadeTimeInSeconds) )
                    }
                }
            }
            if play {
                self.play(player: 1, playlistIndex: 0)
            }
        }
        else if self.audioPlayerActive == 1 {
            if self.audio1 != nil {
                if self.audio1!.isPlaying {
                    if !PlayerPreferences.crossfadeSongs || !crossfade {
                        self.audio1!.stop()
                    }
                    else {
                        self.audio1!.setVolume(0.0, fadeDuration: Double(PlayerPreferences.crossfadeTimeInSeconds) )
                    }
                }
            }
            if play {
                self.play(player: 2, playlistIndex: 0)
            }
        }
    }
    
    ///
    /// Runs the application.
    ///
    /// returnes: Int32. Exit code.
    ///
    func run() -> Int32 {
        g_mainWindow = MainWindow()
        let retVal = g_mainWindow?.showWindow() ?? 0
        
        PlayerLog.ApplicationLog?.logInformation(title: "CMPlayer", text: "Application Exited Normally.")
        
        return retVal
    }
    
    ///
    /// Initializes all the songs from files and library.
    ///
    func initializeSongs() -> Void {
        g_songs.removeAll()
        g_playlist.removeAll()
        
        for mrpath in PlayerPreferences.musicRootPath {
            //#if DEBUG
            //    let result = findSongs(path: "/Users/kjetilso/Music")//"/Volumes/ikjetil/Music/G")
            //#else
                let result = findSongs(path: mrpath)
            //#endif
            
            filesFound = true
            printWorkingInitializationSongs(path: mrpath, completed: 0)
            
            var i: Int = 1
            for r in result {
                printWorkingInitializationSongs( path: mrpath, completed: Int(Double(i) * Double(100.0) / Double(result.count)))
                
                let u: URL = URL(fileURLWithPath: r)
                if let se = g_library.find(url: u) {
                    g_songs.append(se)
                }
                else {
                    let nasno = g_library.nextAvailableSongNo()
                    do {
                        g_songs.append(try SongEntry(path: URL(fileURLWithPath: r),songNo: nasno))
                    }
                    catch  {
                        g_library.setNextAvailableSongNo(nasno)
                    }
                }
                
                i += 1
            }
        }
        
        if g_songs.count > 0 {
            let r1 = g_songs.randomElement()
            let r2 = g_songs.randomElement()
            
            g_playlist.append(r1!)
            g_playlist.append(r2!)
        }
    }
    
    ///
    /// Finds all songs from path and all folder paths under path. Songs must be of format in PlayerPreferences.musicFormats.
    ///
    /// parameter path: The root path to start finding supported audio files.
    ///
    /// returns: [String]. Array of file paths to audio files found.
    ///
    func findSongs(path: String) -> [String]
    {
        filesFound = false
        var results: [String] = []
        do
        {
            let result = try FileManager.default.contentsOfDirectory(atPath: path)
            for r in result {
                
                var nr = "\(path)/\(r)"
                if path.hasSuffix("/") {
                    nr = "\(path)\(r)"
                }
                
                printWorkingInitializationSongs(path: nr, completed: 0)
                
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
            //Console.showCursor()
            //Console.echoOn()
            //exit(EXIT_CODE_ERROR_FINDING_FILES)
        }
        
        return results
    }
    
    ///
    /// Prints the initialization of songs.
    ///
    /// parameter path: Current Path.
    /// parameter completed: Percent completed.
    ///
    func printWorkingInitializationSongs(path: String, completed: Int) -> Void {
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,":: INITIALIZE ::", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1, 5, "Current Path: " + path, 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        let pstFiles: String = "\((filesFound) ? 100 : 0)%"
        Console.printXY(1, 6, findingFilesText + " " + pstFiles, 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        let pstLib: String = "\(completed)%"
        Console.printXY(1, 7, initSongLibraryText + " " + pstLib, 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,23,"PLEASE BE PATIENT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Determines if a path is a directory or not.
    ///
    /// parameter path. Path to check.
    ///
    /// returns: Bool. True if path is directory. False otherwise.
    ///
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        FileManager().fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }// isDirectory
}// Player
