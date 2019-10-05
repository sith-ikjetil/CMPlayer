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
import Cocoa

///
/// Represents CMPlayer MainWindow.
///
internal class MainWindow : TerminalSizeChangedProtocol {
    //
    // Private properties/constants.
    //
    private var quit: Bool = false
    private var currentCommand: String = ""
    private let commandsExit: [String] = ["exit", "quit"]
    private let commandsUpdate: [String] = ["update cmplayer"]
    private let commandsSetViewType: [String] = ["set", "viewtype"]
    private let commandsSetBg: [String] = ["set", "theme"]
    private let commandsNextSong: [String] = ["next", "skip"]
    private let commandsHelp: [String] = ["help","?"]
    private let commandsReplay: [String] = ["replay"]
    private let commandsPlay: [String] = ["play"]
    private let commandsPause: [String] = ["pause"]
    private let commandsResume: [String] = ["resume"]
    private let commandsSearch: [String] = ["search"]
    private let commandsSearchArtist: [String] = ["search-artist"]
    private let commandsSearchTitle: [String] = ["search-title"]
    private let commandsSearchAlbum : [String] = ["search-album"]
    private let commandsSearchGenre: [String] = ["search-genre"]
    private let commandsSearchYear: [String] = ["search-year"]
    private let commandsClearMode: [String] = ["clear","mode"]
    private let commandsAbout: [String] = ["about"]
    private let commandsYear: [String] = ["year"]
    private let commandsGoTo: [String] = ["goto"]
    private let commandsMode: [String] = ["mode"]
    private let commandsInfo: [String] = ["info"]
    private let commandsRepaint: [String] = ["repaint","redraw"]
    private let commandsAddMusicRootPath: [String] = ["add", "mrp"]
    private let commandsRemoveMusicRootPath: [String] = ["remove", "mrp"]
    private let commandsClearMusicRootPath: [String] = ["clear mrp"]
    private let commandsSetCrossfadeTimeInSeconds: [String] = ["set", "cft"]
    private let commandsSetMusicFormats: [String] = ["set", "mf"]
    private let commandsEnableCrossfade: [String] = ["enable crossfade"]
    private let commandsDisableCrossfade: [String] = ["disable crossfade"]
    private let commandsEnableAutoPlayOnStartup: [String] = ["enable aos"]
    private let commandsDisableAutoPlayOnStartup: [String] = ["disable aos"]
    private let commandsReinitialize: [String] = ["reinitialize"]
    private let commandsRebuildSongNo: [String] = ["rebuild songno"]
    private let commandsGenre: [String] = ["genre"]
    private let commandsArtist: [String] = ["artist"]
    private let commandsPreferences: [String] = ["pref"]
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.cmplayer.macos.1", attributes: .concurrent)
    private let concurrentQueue2 = DispatchQueue(label: "cqueue.cmplayer.macos.2", attributes: .concurrent)
    private var currentChar: Int32 = -1
    private var exitCode: Int32 = 0
    private var isShowingTopWindow = false
    private var addendumText: String = ""
    private var updateFileName: String = ""
    static private var timeElapsedMs: UInt64 = 0
    private var isTooSmall: Bool = false
    
    ///
    /// Shows this MainWindow on screen.
    ///
    /// returns: ExitCode,  Int32
    ///
    func showWindow() -> Int32 {
        g_tscpStack.append(self)
        self.renderScreen()
        let exitCode = self.run()
        g_tscpStack.removeLast()
        return exitCode
    }
    
    ///
    /// Handler for TerminalSizeHasChangedProtocol
    ///
    func terminalSizeHasChanged() -> Void {
        Console.clearScreenCurrentTheme()
        if g_rows >= 24 && g_cols >= 80 {
            self.isTooSmall = false
            self.renderScreen()
        }
        else {
            self.isTooSmall = true
            Console.gotoXY(80,1)
            print("")
        }
    }

    ///
    /// Renders header on screen
    ///
    /// parameter showTime: True if time string is to be shown in header. False otherwise.
    ///
    static func renderHeader(showTime: Bool) -> Void {
        let bgColor = ConsoleColor.blue
        
        if showTime {
            Console.printXY(1,1,"CMPlayer | \(g_versionString) | \(itsRenderMsToFullString(MainWindow.timeElapsedMs, false))", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        else {
            Console.printXY(1,1,"CMPlayer | \(g_versionString)", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
    }
    
    ///
    /// Renders main window frame on screen
    ///
    func renderFrame() -> Void {
        
        MainWindow.renderHeader(showTime: true)
        
        let bgColor = getThemeBgColor()
        
        Console.printXY(1,2," ", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    
        if PlayerPreferences.viewType == ViewType.Default {
            Console.printXY(1,3,"Song No.", g_fieldWidthSongNo+1, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            Console.printXY(10,3,"Artist", g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            Console.printXY(43,3,"Title", g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            Console.printXY(76,3,"Time", g_fieldWidthDuration, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            //let sep = String("\u{2550}")
            Console.printXY(1,4,"=", 80, .left, "=", bgColor, ConsoleColorModifier.none, ConsoleColor.green, ConsoleColorModifier.bold)
        }
        else if PlayerPreferences.viewType == ViewType.Details {
            Console.printXY(1,3,"Song No.", g_fieldWidthSongNo+1, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
            Console.printXY(1,4," ", g_fieldWidthSongNo+1, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
            
            Console.printXY(10,3,"Artist", g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
            Console.printXY(10,4,"Album Name", g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            Console.printXY(43,3,"Title", g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
            Console.printXY(43,4,"Genre", g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            Console.printXY(76,3,"Time", g_fieldWidthDuration, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
            Console.printXY(76,4," ", g_fieldWidthDuration, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
            //let sep = String("\u{2550}")
            Console.printXY(1,5,"=", 80, .left, "=", bgColor, ConsoleColorModifier.none, ConsoleColor.green, ConsoleColorModifier.bold)
        }
    }

    ///
    /// Renders a song on screen
    ///
    /// parameter y: Line where song is to be rendered.
    /// parameter songNo: SongNo.
    /// parameter artist. Artist.
    /// parameter song. Title.
    /// parameter time. Duration (ms).
    ///
    func renderSong(_ y: Int, _ song: SongEntry, _ time: UInt64) -> Void
    {
        let bgColor = getThemeSongBgColor()
        let songNoColor = ConsoleColor.cyan
        
        if PlayerPreferences.viewType == ViewType.Default {
            Console.printXY(1, y, String(song.songNo)+" ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, songNoColor, ConsoleColorModifier.bold)
            
            Console.printXY(10, y, song.artist, g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(43, y, song.title, g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            let timeString: String = itsRenderMsToFullString(time, false)
            let endTimePart: String = String(timeString[timeString.index(timeString.endIndex, offsetBy: -5)..<timeString.endIndex])
            Console.printXY(76, y, endTimePart, g_fieldWidthDuration, .ignore, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        else if PlayerPreferences.viewType == ViewType.Details {
            Console.printXY(1, y, String(song.songNo)+" ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, songNoColor, ConsoleColorModifier.bold)
            Console.printXY(1, y+1, " ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(10, y, song.artist, g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            Console.printXY(10, y+1, song.albumName, g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(43, y, song.title, g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            Console.printXY(43, y+1, song.genre, g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            let timeString: String = itsRenderMsToFullString(time, false)
            let endTimePart: String = String(timeString[timeString.index(timeString.endIndex, offsetBy: -5)..<timeString.endIndex])
            Console.printXY(76, y, endTimePart, g_fieldWidthDuration, .ignore, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(76, y+1, " ", g_fieldWidthDuration, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
    }
    
    ///
    /// Renders the command line on screen
    ///
    func renderCommandLine() -> Void
    {
        var text = self.currentCommand
        if text.count > 77 {
            text = String(text[text.index(text.endIndex, offsetBy: -77)..<text.endIndex])
        }
        Console.printXY(1,23,">: " + text, 80, .left, " ", getThemeBgColor(), ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    ///
    /// Renders the status line on screen
    ///
    func renderStatusLine() -> Void
    {
        Console.printXY(1,24,"Song Count: \(g_songs.count.itsToString())", 80, .center, " ", getThemeBgColor(), ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Traverses all songs and ask the screen renderer to render them on screen
    ///
    func renderSongs() -> Void {
        var idx: Int = (PlayerPreferences.viewType == ViewType.Default) ? 5 : 6
        let timeRow: Int = (PlayerPreferences.viewType == ViewType.Default) ? 5 : 6
        var index: Int = 0
        let max: Int = (PlayerPreferences.viewType == ViewType.Default) ? 22 : 21
        let bgColor = getThemeBgColor()
        while idx < max {
            if index < g_playlist.count {
                let s = g_playlist[index]
                
                if idx == timeRow {
                    if g_player.audioPlayerActive == -1 && g_playlist.count > 0{
                        renderSong(idx, s, g_playlist[0].duration)
                    }
                    else if g_player.audioPlayerActive == 1 {
                        renderSong(idx, s, g_player.durationAudioPlayer1)
                    }
                    else if g_player.audioPlayerActive == 2 {
                        renderSong(idx, s, g_player.durationAudioPlayer2)
                    }
                }
                else {
                    renderSong(idx, s, s.duration)
                }
            }
            else {
                if PlayerPreferences.viewType == ViewType.Default {
                    Console.printXY(1, idx, " ", 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                }
                else if PlayerPreferences.viewType == ViewType.Details {
                    Console.printXY(1, idx, " ", 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                    Console.printXY(1, idx+1, " ", 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                }
            }
            if PlayerPreferences.viewType == ViewType.Default {
                idx += 1
            }
            else if PlayerPreferences.viewType == ViewType.Details {
                idx += 2
            }
            index += 1
        }
        Console.printXY(1, 22, self.addendumText, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
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
                    if !self.isTooSmall {
                        MainWindow.renderHeader(showTime: true)
                        self.renderScreen()
                        Console.printXY(1, 22, self.addendumText, 80, .left, " ", getThemeBgColor(), ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                    }
                }
                
                g_lock.lock()
                if g_playlist.count > 0 {
                    if g_player.audioPlayerActive == 1 {
                        var time: Double = 0.0
                        if let a = g_player.audio1 {
                            time = a.currentTime.magnitude
                        }
                        g_player.durationAudioPlayer1 = UInt64(Double(g_playlist[0].duration) - time * Double(1000))
                    }
                    else if g_player.audioPlayerActive == 2 {
                        var time: Double = 0.0
                        if let a = g_player.audio2 {
                            time = a.currentTime.magnitude
                        }
                        g_player.durationAudioPlayer2 = UInt64(Double(g_playlist[0].duration) - time * Double(1000))
                    }
                    
                    if g_player.audioPlayerActive == 1 && g_player.audio1 != nil {
                        if (PlayerPreferences.crossfadeSongs && g_player.durationAudioPlayer1 <= PlayerPreferences.crossfadeTimeInSeconds * 1000)
                            || g_player.durationAudioPlayer1 <= 1000 || ( g_player.durationAudioPlayer1 > 0 && !g_player.isPaused && !g_player.audio1!.isPlaying ) {
                            g_player.skip(crossfade: PlayerPreferences.crossfadeSongs)
                        }
                    }
                    else if g_player.audioPlayerActive == 2 && g_player.audio2 != nil {
                        if (PlayerPreferences.crossfadeSongs && g_player.durationAudioPlayer2 <= PlayerPreferences.crossfadeTimeInSeconds * 1000)
                            || g_player.durationAudioPlayer2 <= 1000 || ( g_player.durationAudioPlayer2 > 0 && !g_player.isPaused && !g_player.audio2!.isPlaying) {
                            g_player.skip(crossfade: PlayerPreferences.crossfadeSongs)
                        }
                    }
                }
                g_lock.unlock()
                
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
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_HTAB, closure: { () -> Bool in
            self.onCommandNextSong(parts: [])
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_ENTER, closure: { () -> Bool in
            var returnValue: Bool = false
            if self.currentCommand.count > 0 {
                returnValue = self.processCommand(command: self.currentCommand)
                self.quit = returnValue
            }
            self.currentCommand.removeAll()
            
            self.renderCommandLine()
            self.renderStatusLine()
            
            return returnValue
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            if key != EOF && key != 10 && key != Console.KEY_BACKSPACE && key != 27 {
                self.currentCommand.append(String(UnicodeScalar(UInt32(key))!))
            }
            else if key == Console.KEY_BACKSPACE {
                if self.currentCommand.count > 0 {
                    self.currentCommand.removeLast()
                }
            }
            
            self.renderCommandLine()
            self.renderStatusLine()
            
            return false
        })
        keyHandler.run()
        
        return self.exitCode
    }
    
    func processCommand(command: String) -> Bool {
        let parts = command.components(separatedBy: " ")
                    
        if isCommandInCommands(command, self.commandsExit) {
            return true
        }
        else if isCommandInCommands(command, self.commandsUpdate) {
            self.onCommandUpdate(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsReplay) {
            self.onCommandReplay(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsNextSong) {
            self.onCommandNextSong(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsPlay) {
            self.onCommandPlay(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsPause) {
            self.onCommandPause(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsResume) {
            self.onCommandResume(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsRepaint) {
            self.onCommandRepaint(parts: parts)
        }
        else if let num = Int(command) {
            self.onCommandAddSongToPlaylist(parts: parts, songNo: num)
        }
        else if isCommandInCommands(command, self.commandsEnableCrossfade) {
            self.onCommandEnableCrossfade(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsDisableCrossfade) {
            self.onCommandDisableCrossfade(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsEnableAutoPlayOnStartup) {
            self.onCommandEnableAutoPlayOnStartup(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsDisableAutoPlayOnStartup) {
            self.onCommandDisableAutoPlayOnStartup(parts: parts)
        }
        else if parts.count == 3 && parts[0] == self.commandsAddMusicRootPath[0] && parts[1] == self.commandsAddMusicRootPath[1] {
            self.onCommandAddMusicRootPath(parts: parts)
        }
        else if parts.count == 3 && parts[0] == self.commandsRemoveMusicRootPath[0] && parts[1] == self.commandsRemoveMusicRootPath[1] {
            self.onCommandRemoveMusicRootPath(parts: parts)
        }
        else if parts.count == 3 && parts[0] == self.commandsSetCrossfadeTimeInSeconds[0] && parts[1] == self.commandsSetCrossfadeTimeInSeconds[1] {
            self.onCommandSetCrossfadeTimeInSeconds(parts: parts)
        }
        else if parts.count == 3 && parts[0] == self.commandsSetMusicFormats[0] && parts[1] == self.commandsSetMusicFormats[1] {
            self.onCommandSetMusicFormats(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsGoTo[0] {
            self.onCommandGoTo(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsClearMode[0] && parts[1] == self.commandsClearMode[1] {
            self.onCommandClearMode(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsInfo[0] {
            self.onCommandInfoSong(parts: parts)
        }
        else if parts.count == 3 && parts[0] == self.commandsSetViewType[0] && parts[1] == self.commandsSetViewType[1] {
            self.onCommandSetViewType(parts: parts)
        }
        else if parts.count == 3 && parts[0] == self.commandsSetBg[0] && parts[1] == self.commandsSetBg[1] {
            self.onCommandSetColorTheme(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsHelp) {
            self.onCommandHelp(parts: parts)
        }
        else if parts.count > 1 && parts[0] == self.commandsSearchArtist[0] {
            self.onCommandSearchArtist(parts: parts)
        }
        else if parts.count > 1 && parts[0] == self.commandsSearchTitle[0] {
            self.onCommandSearchTitle(parts: parts)
        }
        else if parts.count > 1 && parts[0] == self.commandsSearchAlbum[0] {
            self.onCommandSearchAlbum(parts: parts)
        }
        else if parts.count > 1 && parts[0] == self.commandsSearchGenre[0] {
            self.onCommandSearchGenre(parts: parts)
        }
        else if parts.count > 1 && parts[0] == self.commandsSearchYear[0] {
            self.onCommandSearchYear(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsClearMusicRootPath) {
            self.onCommandClearMusicRootPath(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsAbout) {
            self.onCommandAbout(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsGenre) {
            self.onCommandGenre(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsArtist) {
            self.onCommandArtist(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsMode) {
            self.onCommandMode(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsInfo) {
            self.onCommandInfo(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsReinitialize) {
            self.onCommandReinitialize(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsRebuildSongNo) {
            self.onCommandRebuildSongNo(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsPreferences) {
            self.onCommandPreferences(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsYear) {
            self.onCommandYear(parts: parts)
        }
        else if parts.count > 1 && isCommandInCommands(parts[0], self.commandsSearch) {
            self.onCommandSearch(parts: parts)
        }
        
        return false
    }
    
    ///
    /// Sets main window song bg color
    ///
    func onCommandSetColorTheme(parts: [String]) -> Void {
        if parts.count == 3 {
            if ( parts[2] == "blue" ) {
                PlayerPreferences.colorTheme = ColorTheme.Blue
                PlayerPreferences.savePreferences()
            }
            else if parts[2] == "black" {
                PlayerPreferences.colorTheme = ColorTheme.Black
                PlayerPreferences.savePreferences()
            }
            else if parts[2] == "default" {
                PlayerPreferences.colorTheme = ColorTheme.Default
                PlayerPreferences.savePreferences()
            }
            self.renderScreen()
        }
    }
    
    ///
    /// Sets ViewType on Main Window
    ///
    func onCommandSetViewType(parts: [String]) -> Void {
        if parts.count == 3 {
            PlayerPreferences.viewType = ViewType(rawValue: parts[2].lowercased() ) ?? ViewType.Default
            PlayerPreferences.savePreferences()
            self.renderFrame()
        }
    }
    
    ///
    /// Restarts current playing song.
    ///
    /// parameter parts: command array.
    ///
    func onCommandReplay(parts: [String]) -> Void {
        g_lock.lock()
       
        if g_player.audioPlayerActive == 1 {
            g_player.audio1?.currentTime = TimeInterval(exactly: 0.0)!
        }
        else if g_player.audioPlayerActive == 2 {
            g_player.audio2?.currentTime = TimeInterval(exactly: 0.0)!
        }
    
        g_lock.unlock()
    }
    
    ///
    /// Play next song
    ///
    /// parameter parts: command array.
    ///
    func onCommandNextSong(parts: [String]) -> Void {
        g_lock.lock()
        g_player.skip(crossfade: false)
        g_lock.unlock()
    }
    
    ///
    /// Play if not playing.
    ///
    /// parameter parts: command array.
    ///
    func onCommandPlay(parts: [String]) -> Void {
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
    
    ///
    /// Pause playback.
    ///
    /// parameter parts: command array.
    ///
    func onCommandPause(parts: [String]) -> Void {
        g_player.pause()
    }
    
    ///
    /// Resume playback.
    ///
    /// parameter parts: command array.
    ///
    func onCommandResume(parts: [String]) -> Void {
        g_player.resume()
    }
    
    ///
    /// Repaint main window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandRepaint(parts: [String]) -> Void {
        Console.clearScreenCurrentTheme()
        self.renderScreen()
    }
    
    ///
    /// Add song to playlist
    ///
    /// parameter parts: command array.
    /// parameter songNo: song number to add.
    ///
    func onCommandAddSongToPlaylist(parts: [String], songNo: Int) -> Void {
        if songNo > 0 {
            for se in g_songs {
                if se.songNo == songNo {
                    g_playlist.append(se)
                    break
                }
            }
        }
    }
    
    ///
    /// Enable crossfade
    ///
    /// parameter parts: command array.
    ///
    func onCommandEnableCrossfade(parts: [String]) -> Void {
        PlayerPreferences.crossfadeSongs = true
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Disable crossfade.
    ///
    /// parameter parts: command array.
    ///
    func onCommandDisableCrossfade(parts: [String]) -> Void {
        PlayerPreferences.crossfadeSongs = false
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Enable audoplay on startup and after reinitialize.
    ///
    /// parameter parts: command array.
    ///
    func onCommandEnableAutoPlayOnStartup(parts: [String]) -> Void {
        PlayerPreferences.autoplayOnStartup = true
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Disable autoplay on startup and after reinitialize.
    ///
    /// parameter parts: command array.
    ///
    func onCommandDisableAutoPlayOnStartup(parts: [String]) -> Void {
        PlayerPreferences.autoplayOnStartup = false
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Add path to root paths.
    ///
    /// parameter parts: command array.
    ///
    func onCommandAddMusicRootPath(parts: [String]) -> Void {
        PlayerPreferences.musicRootPath.append(parts[2])
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Remove root path.
    ///
    /// parameter parts: command array.
    ///
    func onCommandRemoveMusicRootPath(parts: [String]) -> Void {
        var i: Int = 0
        while i < PlayerPreferences.musicRootPath.count {
            if PlayerPreferences.musicRootPath[i] == parts[2] {
                PlayerPreferences.musicRootPath.remove(at: i)
                PlayerPreferences.savePreferences()
                break
            }
            i += 1
        }
    }
    
    ///
    /// Set crossfade time in seconds.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSetCrossfadeTimeInSeconds(parts: [String]) -> Void {
        if let ctis = Int(parts[2]) {
            if isCrossfadeTimeValid(ctis) {
                PlayerPreferences.crossfadeTimeInSeconds = ctis
                PlayerPreferences.savePreferences()
            }
        }
    }
    
    ///
    /// Set music formats.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSetMusicFormats(parts: [String]) -> Void {
        PlayerPreferences.musicFormats = parts[2]
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Goto playback point of current playing item.
    ///
    /// parameter parts: command array.
    ///
    func onCommandGoTo(parts: [String]) -> Void {
        let tp = parts[1].split(separator: ":" )
        if tp.count == 2 {
            if let time1 = Int(tp[0]) {
                if let time2 = Int(tp[1]) {
                    if time1 >= 0 && time2 >= 0 {
                        let pos: Int = time1*60 + time2
                        if g_player.audioPlayerActive == 1 {
                            g_player.audio1?.currentTime = TimeInterval(exactly: Double(UInt64(Double(g_playlist[0].duration) / 1000.0)) - Double(pos))!
                        }
                        else if g_player.audioPlayerActive == 2 {
                            g_player.audio2?.currentTime = TimeInterval(exactly: Double(UInt64(Double(g_playlist[0].duration) / 1000.0)) - Double(pos))!
                        }
                    }
                }
            }
        }
    }
    
    ///
    /// Clears any search mode
    ///
    /// parameter parts: command arrary
    ///
    func onCommandClearMode(parts: [String]) -> Void {
        g_lock.lock()
        g_searchType = SearchType.ArtistOrTitle
        g_searchResult.removeAll()
        g_modeSearch.removeAll()
        g_modeSearchStats.removeAll()
        g_lock.unlock()
    }
    
    ///
    /// Show info on given song number.
    ///
    /// parameter parts: command array.
    ///
    func onCommandInfoSong(parts: [String]) -> Void {
        if let sno = Int(parts[1]) {
            if sno > 0 {
                for s in g_songs {
                    if s.songNo == sno {
                        self.isShowingTopWindow = true
                        let wnd: InfoWindow = InfoWindow()
                        wnd.showWindow(song: s)
                        Console.clearScreenCurrentTheme()
                        self.renderScreen()
                        self.isShowingTopWindow = false
                        break
                    }
                }
            }
        }
    }
    
    ///
    /// Show help window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandHelp(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: HelpWindow = HelpWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Clear music root paths.
    ///
    /// parameter parts: command array.
    ///
    func onCommandClearMusicRootPath(parts: [String]) -> Void {
        PlayerPreferences.musicRootPath.removeAll()
        PlayerPreferences.savePreferences()
    }
    
    ///
    /// Show about window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandAbout(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: AboutWindow = AboutWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Show artist window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandArtist(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: ArtistWindow = ArtistWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Show genre window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandGenre(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: GenreWindow = GenreWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Show mode window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandMode(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: ModeWindow = ModeWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }

    ///
    /// Show info window about current playing item.
    ///
    /// parameter parts: command array.
    ///
    func onCommandInfo(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: InfoWindow = InfoWindow()
        g_lock.lock()
        let song = g_playlist[0]
        g_lock.unlock()
        wnd.showWindow(song: song)
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Reinitialize library and player.
    ///
    /// parameter parts: command array.
    ///
    func onCommandReinitialize(parts: [String]) -> Void {
        g_player.pause()
                
        g_lock.lock()
        
        g_searchType = SearchType.ArtistOrTitle
        g_genres.removeAll()
        g_artists.removeAll()
        g_recordingYears.removeAll()
        g_searchResult.removeAll()
        g_modeSearch.removeAll()
        g_songs.removeAll()
        g_playlist.removeAll()
        g_library.library = []
        g_library.save()
        g_library.setNextAvailableSongNo(1)
        
        g_player.audioPlayerActive = -1
        g_player.audio1 = nil
        g_player.audio2 = nil
        
        if PlayerPreferences.musicRootPath.count == 0 {
            self.isShowingTopWindow = true
            let wnd: SetupWindow = SetupWindow()
            while !wnd.showWindow() {
                
            }
            PlayerPreferences.savePreferences()
            Console.clearScreenCurrentTheme()
            MainWindow.renderHeader(showTime: false)
            self.isShowingTopWindow = true
            g_player.initializeSongs()
        }
        else {
            Console.clearScreenCurrentTheme()
            MainWindow.renderHeader(showTime: false)
            self.isShowingTopWindow = true
            g_player.initializeSongs()
        }
        self.isShowingTopWindow = false
        
        g_library.library = g_songs
        g_library.save()
        
        self.renderScreen()
        
        g_lock.unlock()
        
        g_player.skip(play: PlayerPreferences.autoplayOnStartup)
    }
    
    ///
    /// Rebuild song numbers.
    ///
    /// parameter parts: command array.
    ///
    func onCommandRebuildSongNo(parts: [String]) -> Void {
        var i: Int = 1
        for s in g_songs {
            s.songNo = i
            i += 1
        }
        g_library.setNextAvailableSongNo(i)
        g_library.library = g_songs
        g_library.save()
    }
    
    ///
    /// Show preferences window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandPreferences(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: PreferencesWindow = PreferencesWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Show year window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandYear(parts: [String]) -> Void {
        self.isShowingTopWindow = true
        let wnd: YearWindow = YearWindow()
        wnd.showWindow()
        Console.clearScreenCurrentTheme()
        self.renderScreen()
        self.isShowingTopWindow = false
    }
    
    ///
    /// Show search window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSearch(parts: [String]) -> Void {
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()
        
        if nparts.count > 0 {
            self.isShowingTopWindow = true
            let wnd: SearchWindow = SearchWindow()
            wnd.showWindow(parts: nparts, type: SearchType.ArtistOrTitle)
            Console.clearScreenCurrentTheme()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }
    
    ///
    /// Show search window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSearchArtist(parts: [String]) -> Void {
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()
        
        if nparts.count > 0 {
            self.isShowingTopWindow = true
            let wnd: SearchWindow = SearchWindow()
            wnd.showWindow(parts: nparts, type: SearchType.Artist)
            Console.clearScreenCurrentTheme()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }
    
    ///
    /// Show search window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSearchTitle(parts: [String]) -> Void {
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()
        
        if nparts.count > 0 {
            self.isShowingTopWindow = true
            let wnd: SearchWindow = SearchWindow()
            wnd.showWindow(parts: nparts, type: SearchType.Title)
            Console.clearScreenCurrentTheme()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }
    
    ///
    /// Show search window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSearchAlbum(parts: [String]) -> Void {
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()
        
        if nparts.count > 0 {
            self.isShowingTopWindow = true
            let wnd: SearchWindow = SearchWindow()
            wnd.showWindow(parts: nparts, type: SearchType.Album)
            Console.clearScreenCurrentTheme()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }
    
    ///
    /// Show search window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSearchGenre(parts: [String]) -> Void {
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()
             
        if nparts.count > 0 {
            self.isShowingTopWindow = true
            let wnd: SearchWindow = SearchWindow()
            wnd.showWindow(parts: nparts, type: SearchType.Genre)
            Console.clearScreenCurrentTheme()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }
    
    ///
    /// Show search window.
    ///
    /// parameter parts: command array.
    ///
    func onCommandSearchYear(parts: [String]) -> Void {
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()

        if nparts.count > 0 {
            self.isShowingTopWindow = true
            let wnd: SearchWindow = SearchWindow()
            wnd.showWindow(parts: nparts, type: SearchType.RecordedYear)
            Console.clearScreenCurrentTheme()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }
    
    ///
    /// Updates CMPlayer if newer version is available.
    ///
    /// parameter parts: command array.
    ///
    private func onCommandUpdate(parts: [String]) -> Void {
        self.addendumText = "Checking for updates..."
        var request = URLRequest(url: URL(string: "http://www.ikjetil.no/Home/GetFileName/45?GUID=4dae77f8-e7f3-4631-a8e5-8afda6d065af")! )
        let session = URLSession.shared

        request.httpMethod = "GET"
        //request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("www.ikjetil.no", forHTTPHeaderField: "Host")
        request.addValue("0", forHTTPHeaderField: "Content-Length")

        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
           
            if error != nil {
                PlayerLog.ApplicationLog?.logWarning(title: "MainWindow::onCommandUpdate", text: "session.dataTask failed. With error: \(error!)")
                self.addendumText = "Error contacting server!"
                return
            }
           
            var didUpdate: Bool = false
            if let textData = data {
                let textRaw: String? = String(data: textData, encoding: .utf8)
                if let text = textRaw {
                    let version = regExMatches(for: "[0-9]+.[0-9]+.[0-9]+.[0-9]+", in: text)
                    if version.count > 0 {
                        self.addendumText = "Found version: \(version[0])"
                        self.updateFileName = text
                        
                        let partsServer = version[0].components(separatedBy: ".")
                        let partsCMP = g_versionString.components(separatedBy: ".")
                        
                        if partsServer.count == 4 && partsCMP.count == 4 {
                            let majorServer: Int = Int(partsServer[0]) ?? 0
                            let minorServer: Int = Int(partsServer[1]) ?? 0
                            let buildServer: Int = Int(partsServer[2]) ?? 0
                            let revisionServer: Int = Int(partsServer[3]) ?? 0
                            
                            let majorCMP: Int = Int(partsCMP[0]) ?? 0
                            let minorCMP: Int = Int(partsCMP[1]) ?? 0
                            let buildCMP: Int = Int(partsCMP[2]) ?? 0
                            let revisionCMP: Int = Int(partsCMP[3]) ?? 0
                            
                            if majorServer > majorCMP ||
                               (majorServer == majorCMP && minorServer > minorCMP) ||
                               (majorServer == majorCMP && minorServer == minorCMP && buildServer > buildCMP) ||
                                (majorServer == majorCMP && minorServer == minorCMP && buildServer == buildCMP && revisionServer > revisionCMP)
                            {
                                didUpdate = true
                                self.onPerformUpdate()
                            }
                        }
                    }
                }
            }
            if !didUpdate {
                self.addendumText = ""
            }
        })
        task.resume()
    }
    
    ///
    /// We have found a new version and now we do the actual downloading and updating
    ///
    private func onPerformUpdate() -> Void {
        self.addendumText = "Updating..."
        
        var request = URLRequest(url: URL(string: "http://www.ikjetil.no/Home/DownloadFile/45?GUID=4dae77f8-e7f3-4631-a8e5-8afda6d065af")! )
        let session = URLSession.shared
        
        request.httpMethod = "GET"
        //request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("www.ikjetil.no", forHTTPHeaderField: "Host")
        request.addValue("0", forHTTPHeaderField: "Content-Length")
        
        let task = session.dataTask(with: request, completionHandler: {
            data, response, error -> Void in
            
            if error != nil {
                PlayerLog.ApplicationLog?.logError(title: "MainWindow::onPerformUpdate", text: "session.dataTask failed. With error: \(error!)")
                self.addendumText = "Error downloading file!"
                return
            }
            
            if let igData = data {
                do {
                    let filename = PlayerDirectories.consoleMusicPlayerUpdateDirectory.appendingPathComponent("\(self.updateFileName)")
                    try igData.write(to: filename)
                    
                    NSWorkspace.shared.openFile(filename.path)
                    
                    self.addendumText = "Updating, please be patient..."
                    
                    sleep(7)
                    
                    do {
                        let atFilename: URL = PlayerDirectories.volumesDirectory.appendingPathComponent("CMPlayer", isDirectory: true).appendingPathComponent("CMPlayer", isDirectory: false)
                        //let atFilename: URL = URL(fileURLWithPath: "/Volumes/Ignition").appendingPathComponent("Ignition.app", isDirectory: true)
                        let toFilename: URL = PlayerDirectories.applicationsDirectory.appendingPathComponent("CMPlayer", isDirectory: false)
                        //let toFilename: URL = URL(fileURLWithPath: "/Applications").appendingPathComponent("Ignition.app", isDirectory: true)
                        if FileManager.default.fileExists(atPath: toFilename.path) {
                            try FileManager.default.removeItem(atPath: toFilename.path)
                        }
                        try FileManager.default.copyItem(at: atFilename, to: toFilename)
                        
                        sleep(2)
                        
                        try NSWorkspace.shared.unmountAndEjectDevice(at: PlayerDirectories.volumesDirectory.appendingPathComponent("CMPlayer", isDirectory: true))
                        
                        let _ = NSWorkspace.shared.openFile(toFilename.path)
                        
                        PlayerLog.ApplicationLog?.logInformation(title: "MainWindow::onPerformUpdate", text: "Update Completed to: \(self.updateFileName)")
                        
                        exit(0)
                    }
                    catch {
                        let msg = "Error Updating CMPlayer: \(error)"
                        PlayerLog.ApplicationLog?.logInformation(title: "MainWindow::onPerformUpdate", text: msg)
                        self.addendumText = msg
                    }
                }
                catch {
                    let msg = "Error writing file '\(self.updateFileName)': \(error)"
                    PlayerLog.ApplicationLog?.logInformation(title: "MainWindow::onPerformUpdate", text: msg)
                    self.addendumText = msg
                }
            }
        })
        
        task.resume()
    }// onPerformUpdate
}// CMPlayer
