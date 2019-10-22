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
    var isPrev: Bool = false
    
    //
    // Private properties/constants.
    //
    private var currentCommandReady: Bool = false
    
    ///
    /// Initializes the application.
    ///
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        PlayerLog.ApplicationLog = PlayerLog(autoSave: true, loadOldLog: (PlayerPreferences.logApplicationStartLoadType == LogApplicationStartLoadType.LoadOldLog))
        
        PlayerLog.ApplicationLog?.logInformation(title: "CMPlayer", text: "Application Started.")
        
        Console.initialize()
        
        if PlayerPreferences.musicRootPath.count == 0 {
            let wnd: SetupWindow = SetupWindow()
            wnd.showWindow()
        }
        
        g_library.load()
        
        
        let wnd = InitializeWindow()
        wnd.showWindow()
        
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
                    try autoreleasepool {
                        self.audio1 = try AVAudioPlayer(contentsOf:g_playlist[playlistIndex].fileURL!)
                    }
                    self.durationAudioPlayer1 = g_playlist[playlistIndex].duration
                    self.audio1?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "[Player].play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.message = msg
                    wnd.showWindow()
                    exit(ExitCodes.ERROR_PLAYING_FILE.rawValue)
                }
            }
            else {
                do {
                    self.audio1?.stop()
                    try autoreleasepool {
                        self.audio1 = try AVAudioPlayer(contentsOf: g_playlist[playlistIndex].fileURL!)
                    }
                    self.durationAudioPlayer1 = g_playlist[playlistIndex].duration
                    self.audio1?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "[Player].play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.message = msg
                    wnd.showWindow()
                    exit(ExitCodes.ERROR_PLAYING_FILE.rawValue)
                }
            }
        }
        else if player == 2 {
            if self.audio2 == nil {
                do {
                    try autoreleasepool {
                        self.audio2 = try AVAudioPlayer(contentsOf:g_playlist[playlistIndex].fileURL!)
                    }
                    self.durationAudioPlayer2 = g_playlist[playlistIndex].duration
                    self.audio2?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "[Player].play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.message = msg
                    wnd.showWindow()
                    exit(ExitCodes.ERROR_PLAYING_FILE.rawValue)
                }
            }
            else {
                do {
                    self.audio2?.stop()
                    try autoreleasepool {
                        self.audio2 = try AVAudioPlayer(contentsOf: g_playlist[playlistIndex].fileURL!)
                    }
                    self.durationAudioPlayer2 = g_playlist[playlistIndex].duration
                    self.audio2?.play()
                    self.isPaused = false
                }
                catch {
                    let msg = "EXIT_CODE_ERROR_PLAYING_FILE\nError playing player \(player) on index \(playlistIndex).\n\(error)"
                    PlayerLog.ApplicationLog?.logError(title: "[Player].play", text: msg)
                    
                    let wnd: ErrorWindow = ErrorWindow()
                    wnd.message = msg
                    wnd.showWindow()
                    exit(ExitCodes.ERROR_PLAYING_FILE.rawValue)
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
    /// Plays previous song
    ///
    func prev() {
        guard g_playedSongs.count > 0 else {
            return
        }
        
        self.isPrev = true
    
        self.skip(play: true, crossfade: false)
        
        self.isPrev = false
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
        
        if self.isPrev && g_playedSongs.count > 0 {
            g_playlist.insert( g_playedSongs.last!, at: 0)
            g_playedSongs.removeLast()
        }
        else {
            let pse = g_playlist.removeFirst()
            g_playedSongs.append(pse)
            while g_playedSongs.count > 100 {
                g_playedSongs.remove(at: 0)
            }
        }
        
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
        g_mainWindow?.showWindow()
        PlayerLog.ApplicationLog?.logInformation(title: "CMPlayer", text: "Application Exited Normally.")
        return g_mainWindow?.exitValue ?? 0
    }
}// Player
