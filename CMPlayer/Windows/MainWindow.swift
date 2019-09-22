//
//  MainWindow.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 20/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import
//
import Foundation

///
/// Represents CMPlayer MainWindow.
///
internal class MainWindow {
    //
    // Private properties/constants.
    //
    private var quit: Bool = false
    private var currentCommand: String = ""
    private let commandsExit: [String] = ["exit", "quit"]
    private let commandsNextSong: [String] = ["next", "skip"]
    private let commandsHelp: [String] = ["help","?"]
    private let commandsPlay: [String] = ["play"]
    private let commandsPause: [String] = ["pause"]
    private let commandsResume: [String] = ["resume"]
    private let commandsSearch: [String] = ["search"]
    private let commandsAbout: [String] = ["about"]
    private let commandsRepaint: [String] = ["repaint","redraw"]
    private let commandsSetMusicRootPath: [String] = ["set", "mrp"]
    private let commandsSetCrossfadeTimeInSeconds: [String] = ["set", "cft"]
    private let commandsEnableCrossfade: [String] = ["enable crossfade"]
    private let commandsDisableCrossfade: [String] = ["disable crossfade"]
    private let commandsEnableAutoPlayOnStartup: [String] = ["enable aos"]
    private let commandsDisableAutoPlayOnStartup: [String] = ["disable aos"]
    private let commandsRebuildSongNo: [String] = ["rebuild songno"]
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.cmplayer.macos.1", attributes: .concurrent)
    private let concurrentQueue2 = DispatchQueue(label: "cqueue.cmplayer.macos.2", attributes: .concurrent)
    //private let concurrentQueue3 = DispatchQueue(label: "cqueue.cmplayer.macos.3", attributes: .concurrent)
    private var currentChar: Int32 = -1
    private var exitCode: Int32 = 0
    private var isShowingTopWindow = false
    static private var timeElapsedMs: UInt64 = 0
    
    ///
    /// Shows this MainWindow on screen.
    ///
    /// returns: ExitCode,  Int32
    ///
    func showWindow() -> Int32 {
        self.renderScreen()
        return self.run()
    }

    ///
    /// Renders header on screen
    ///
    static func renderHeader(showTime: Bool) -> Void {
        if showTime {
            Console.printXY(1,1,"CMPlayer | \(g_versionString) | \(itsRenderMsToFullString(MainWindow.timeElapsedMs, false))", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        else {
            Console.printXY(1,1,"CMPlayer | \(g_versionString)", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
    }
    
    ///
    /// Renders main window frame on screen
    ///
    func renderFrame() -> Void {
        
        MainWindow.renderHeader(showTime: true)
        
        Console.printXY(1,3,"Song No.", widthSongNo, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(10,3,"Artist", widthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(43,3,"Title", widthSong, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(76,3,"Time", widthTime, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,4,"=", 80, .left, "=", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }

    ///
    /// Renders a song on screen
    ///
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64) -> Void
    {

        Console.printXY(1, y, String(songNo)+" ", widthSongNo+1, .right, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(10, y, artist, widthArtist, .left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(43, y, song, widthSong, .left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(76, y, itsRenderMsToFullString(time, false), widthTime, .ignore, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Renders the command line on screen
    ///
    func renderCommandLine() -> Void
    {
        Console.printXY(1,23,">: " + self.currentCommand,80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    ///
    /// Renders the status line on screen
    ///
    func renderStatusLine() -> Void
    {
        Console.printXY(1,24,"Songs Found: \(g_songs.count.itsToString())", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Traverses all songs and ask the screen renderer to render them on screen
    ///
    func renderSongs() -> Void {
        var idx: Int = 5
        var index: Int = 0
        while idx < 22 {
            if index < g_playlist.count {
                let s = g_playlist[index]
                
                if idx == 5 {
                    if g_player.audioPlayerActive == 1 {
                        renderSong(idx, s.songNo, s.artist, s.title, g_player.durationAudioPlayer1)
                    }
                    else if g_player.audioPlayerActive == 2 {
                        renderSong(idx, s.songNo, s.artist, s.title, g_player.durationAudioPlayer2)
                    }
                }
                else {
                    renderSong(idx, s.songNo, s.artist, s.title, s.duration)
                }
            }
            else {
                Console.printXY(1, idx, " ", 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            idx += 1
            index += 1
        }
    }
    
    ///
    /// Renders screen output. Does not clear screen first.
    ///
    func renderScreen() -> Void {
        renderFrame()
        renderSongs()
        renderCommandLine()
        renderStatusLine()
    }
    
    ///
    /// Runs MainWindow keyboard input and feedback. Delegation to other windows and command processing.
    ///
    /// returns: Int32. Exit code.
    ///
    func run() -> Int32 {
        self.renderScreen()
        
        //
        // Count down and render songs
        //
        concurrentQueue1.async {
            while !self.quit {
                
                if !self.isShowingTopWindow {
                    MainWindow.renderHeader(showTime: true)
                    self.renderSongs()
                }
                
                if g_playlist.count > 0 {
                    if g_player.audioPlayerActive == 1 {
                        let time = g_player.audio1!.currentTime.magnitude
                        g_player.durationAudioPlayer1 = UInt64(Double(g_playlist[0].duration) - time * Double(1000))
                    }
                    else if g_player.audioPlayerActive == 2 {
                        let time = g_player.audio2!.currentTime.magnitude
                        g_player.durationAudioPlayer2 = UInt64(Double(g_playlist[0].duration) - time * Double(1000))
                    }
                    
                    if g_player.audioPlayerActive == 1 {
                        if (PlayerPreferences.crossfadeSongs && g_player.durationAudioPlayer1 <= PlayerPreferences.crossfadeTimeInSeconds * 1000)
                            || g_player.durationAudioPlayer1 <= 1000 {
                            g_player.skip(crossfade: PlayerPreferences.crossfadeSongs)
                        }
                    }
                    else if g_player.audioPlayerActive == 2 {
                        if (PlayerPreferences.crossfadeSongs && g_player.durationAudioPlayer2 <= PlayerPreferences.crossfadeTimeInSeconds * 1000)
                            || g_player.durationAudioPlayer2 <= 1000 {
                            g_player.skip(crossfade: PlayerPreferences.crossfadeSongs)
                        }
                    }
                }
                
                let second: Double = 1_000_000
                usleep(useconds_t(0.050 * second))
            }
        }
        
        //
        // Count down and render songs
        //
        concurrentQueue2.async {
            while !self.quit {
                let second: Double = 1_000_000
                usleep(useconds_t(0.150 * second))
                MainWindow.timeElapsedMs += 150
            }
        }
        
        
        //
        // Get Input and Process
        //
        while !self.quit {

            if !self.isShowingTopWindow {
                self.currentChar = getchar()
                if self.currentChar != EOF
                    && self.currentChar != 10
                    && self.currentChar != 127
                    && self.currentChar != 27
                {
                    self.currentCommand.append(String(UnicodeScalar(UInt32(self.currentChar))!))
                    //Console.printXY(1, 2, self.currentCommand, 80, .Left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
                }
                else if self.currentChar == 127 {
                    if self.currentCommand.count > 0 {
                        self.currentCommand.removeLast()
                    }
                }
                else if self.currentChar == 27 {
                    _ = getchar()
                    _ = getchar()
                }
                else if self.currentChar == 10 {
                    let parts = self.currentCommand.components(separatedBy: " ")
                    
                    if isCommandInCommands(self.currentCommand, self.commandsExit) {
                        self.quit = true
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsNextSong) {
                        g_player.skip(crossfade: false)
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsPlay) {
                        if g_player.audioPlayerActive == -1 {
                            g_player.play(player: 1, playlistIndex: 0)
                        }
                        else if g_player.audioPlayerActive == 1 {
                            g_player.resume()
                        }
                        else if g_player.audioPlayerActive == 2 {
                            g_player.resume()
                        }
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsPause) {
                        g_player.pause()
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsResume) {
                        g_player.resume()
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsRepaint) {
                        Console.clearScreen()
                        self.renderScreen()
                    }
                    if let num = Int32(self.currentCommand) {
                        if num > 0 {
                            for se in g_songs {
                                if se.songNo == num {
                                    g_playlist.append(se)
                                    break
                                }
                            }
                        }
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsEnableCrossfade) {
                        PlayerPreferences.crossfadeSongs = true
                        PlayerPreferences.savePreferences()
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsDisableCrossfade) {
                        PlayerPreferences.crossfadeSongs = false
                        PlayerPreferences.savePreferences()
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsEnableAutoPlayOnStartup) {
                        PlayerPreferences.autoplayOnStartup = true
                        PlayerPreferences.savePreferences()
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsDisableAutoPlayOnStartup) {
                        PlayerPreferences.autoplayOnStartup = false
                        PlayerPreferences.savePreferences()
                    }
                    if parts.count == 3 && parts[0] == self.commandsSetMusicRootPath[0] && parts[1] == self.commandsSetMusicRootPath[1] {
                        PlayerPreferences.musicRootPath = parts[2]
                        PlayerPreferences.savePreferences()
                    }
                    if parts.count == 3 && parts[0] == self.commandsSetCrossfadeTimeInSeconds[0] && parts[1] == self.commandsSetCrossfadeTimeInSeconds[1] {
                        if let ctis = Int(parts[2]) {
                            PlayerPreferences.crossfadeTimeInSeconds = ctis
                            PlayerPreferences.savePreferences()
                        }
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsHelp) {
                        self.isShowingTopWindow = true
                        let wnd: HelpWindow = HelpWindow()
                        wnd.showWindow()
                        Console.clearScreen()
                        self.renderScreen()
                        self.isShowingTopWindow = false
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsAbout) {
                        self.isShowingTopWindow = true
                        let wnd: AboutWindow = AboutWindow()
                        wnd.showWindow()
                        Console.clearScreen()
                        self.renderScreen()
                        self.isShowingTopWindow = false
                    }
                    if isCommandInCommands(self.currentCommand, self.commandsRebuildSongNo) {
                        var i: Int = 1
                        for s in g_songs {
                            s.songNo = i
                            i += 1
                        }
                        g_library.setNextAvailableSongNo(i)
                        g_library.library = g_songs
                        g_library.save()
                    }
                    if parts.count > 1 {
                        if isCommandInCommands(parts[0], self.commandsSearch) {
                            self.isShowingTopWindow = true
                            let wnd: SearchWindow = SearchWindow()
                            wnd.showWindow(parts: parts)
                            Console.clearScreen()
                            self.renderScreen()
                            self.isShowingTopWindow = false
                        }
                    }
                    
                    self.currentCommand = ""
                }
                self.renderCommandLine()
                self.renderStatusLine()
            }
        }
        
        return self.exitCode
    }// run
}// CMPlayer
