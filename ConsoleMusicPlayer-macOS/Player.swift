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

internal class Player {
    var audio1: AVAudioPlayer? = nil
    var audio2: AVAudioPlayer? = nil
    var audioPlayerActive: Int = -1
    
    private var musicFormats: [String] = []
    var durationAudioPlayer1: UInt64 = 0
    var durationAudioPlayer2: UInt64 = 0
    
    private var helpIndex: Int = 0
    private var currentCommandReady: Bool = false
    private let EXIT_CODE_ERROR_FINDING_FILES: Int32 = 1
    private let EXIT_CODE_ERROR_PLAYING_FILE: Int32 = 2
    private let EXIT_CODE_ERROR_NOT_ENOUGH_MUSIC: Int32 = 3
    
    
    func initialize() -> Void {
        PlayerDirectories.ensureDirectoriesExistence()
        PlayerPreferences.ensureLoadPreferences()
        Console.initialize()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        self.initializeSongs()
        
        if g_songs.count < 2 {
            let wnd: ErrorWindow = ErrorWindow()
            wnd.showWindow(message: "There must be at least two music files in musicRootPath.\nmusicRootPath is now: \(PlayerPreferences.musicRootPath)")
            exit(EXIT_CODE_ERROR_NOT_ENOUGH_MUSIC)
        }
        
        if PlayerPreferences.autoplayOnStartup && g_playlist.count > 0 {
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
    
    func run() -> Int32 {
        g_mainWindow = MainWindow()
        return g_mainWindow?.showWindow() ?? 0
    }
    
    
    
    func initializeSongs() {
        // DEBUG
        #if DEBUG
            let result = findSongs(path: "/Users/kjetilso/Music")//"/Volumes/ikjetil/Music/G")
        #else
            let result = findSongs(path: PlayerPreferences.musicRootPath)
        #endif
        var i: Int = 1
        for r in result {
            g_songs.append(SongEntry(path: URL(fileURLWithPath: r),num: i))
            i += 1
        }
        
        if g_songs.count > 2 {
            let r1 = g_songs.randomElement()
            let r2 = g_songs.randomElement()
            
            g_playlist.append(r1!)
            g_playlist.append(r2!)
        }
        else if g_songs.count == 1 {
            let r1 = g_songs[0]
            
            g_playlist.append(r1)
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
            let wnd: ErrorWindow = ErrorWindow()
            wnd.showWindow(message: "EXIT_CODE_ERROR_FINDING_FILES\n\(error)")
            exit(EXIT_CODE_ERROR_FINDING_FILES)
        }
        
        return results
    }
    
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        FileManager().fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    
    
}
