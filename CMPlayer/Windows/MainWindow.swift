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
    private let commandsReplay: [String] = ["replay"]
    private let commandsPlay: [String] = ["play"]
    private let commandsPause: [String] = ["pause"]
    private let commandsResume: [String] = ["resume"]
    private let commandsSearch: [String] = ["search"]
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
    private let commandsModeGenre: [String] = ["mode", "genre"]
    private let commandsModeArtist: [String] = ["mode", "artist"]
    private let commandsModeYear: [String] = ["mode", "year"]
    private let commandsModeSearch: [String] = ["mode", "search"]
    private let commandsRebuildSongNo: [String] = ["rebuild songno"]
    private let commandsGenre: [String] = ["genre"]
    private let commandsArtist: [String] = ["artist"]
    private let commandsPreferences: [String] = ["pref"]
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.cmplayer.macos.1", attributes: .concurrent)
    private let concurrentQueue2 = DispatchQueue(label: "cqueue.cmplayer.macos.2", attributes: .concurrent)
    private var currentChar: Int32 = -1
    private var exitCode: Int32 = 0
    private var isShowingTopWindow = false
    private var isSkipping: Bool = false
    
    
    static private var timeElapsedMs: UInt64 = 0
    
    ///
    /// Shows this MainWindow on screen.
    ///
    /// returns: ExitCode,  Int32
    ///
    func showWindow() -> Int32 {
        self.renderScreen()
        let exitCode = self.run()
        Console.showCursor()
        Console.echoOn()
        return exitCode
    }

    ///
    /// Renders header on screen
    ///
    /// parameter showTime: True if time string is to be shown in header. False otherwise.
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
        
        Console.printXY(1,3,"Song No.", g_fieldWidthSongNo, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(10,3,"Artist", g_fieldWidthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(43,3,"Title", g_fieldWidthTitle, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(76,3,"Time", g_fieldWidthDuration, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        //let sep = String("\u{2550}")
        Console.printXY(1,4,"=", 80, .left, "=", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
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
    func renderSong(_ y: Int, _ songNo: Int, _ artist: String, _ song: String, _ time: UInt64) -> Void
    {

        Console.printXY(1, y, String(songNo)+" ", g_fieldWidthSongNo+1, .right, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(10, y, artist, g_fieldWidthArtist, .left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(43, y, song, g_fieldWidthTitle, .left, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        let timeString: String = itsRenderMsToFullString(time, false)
        let endTimePart: String = String(timeString[timeString.index(timeString.endIndex, offsetBy: -5)..<timeString.endIndex])
        Console.printXY(76, y, endTimePart, g_fieldWidthDuration, .ignore, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
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
        Console.printXY(1,23,">: " + text, 80, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
    }
    
    ///
    /// Renders the status line on screen
    ///
    func renderStatusLine() -> Void
    {
        Console.printXY(1,24,"Song Count: \(g_songs.count.itsToString())", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
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
                    if g_player.audioPlayerActive == -1 && g_playlist.count > 0{
                        renderSong(idx, s.songNo, s.artist, s.title, g_playlist[0].duration)
                    }
                    else if g_player.audioPlayerActive == 1 {
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
                            || g_player.durationAudioPlayer1 <= 1000 || ( g_player.durationAudioPlayer1 > 0 && !g_player.isPaused && !g_player.audio1!.isPlaying && !self.isSkipping ) {
                            g_player.skip(crossfade: PlayerPreferences.crossfadeSongs)
                        }
                    }
                    else if g_player.audioPlayerActive == 2 && g_player.audio2 != nil {
                        if (PlayerPreferences.crossfadeSongs && g_player.durationAudioPlayer2 <= PlayerPreferences.crossfadeTimeInSeconds * 1000)
                            || g_player.durationAudioPlayer2 <= 1000 || ( g_player.durationAudioPlayer2 > 0 && !g_player.isPaused && !g_player.audio2!.isPlaying && !self.isSkipping) {
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
        else if parts.count > 2 && parts[0] == self.commandsModeGenre[0] && parts[1] == self.commandsModeGenre[1] {
            self.onCommandModeGenre(parts: parts)
        }
        else if parts.count > 2 && parts[0] == self.commandsModeArtist[0] && parts[1] == self.commandsModeArtist[1] {
            self.onCommandModeArtist(parts: parts)
        }
        else if parts.count > 2 && parts[0] == self.commandsModeYear[0] && parts[1] == self.commandsModeYear[1] {
            self.onCommandModeYear(parts: parts)
        }
        else if parts.count > 2 && parts[0] == self.commandsModeSearch[0] && parts[1] == self.commandsModeSearch[1] {
            self.onCommandModeSearch(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsModeGenre[0] && parts[1] == self.commandsModeGenre[1] {
            self.onCommandClearModeGenre(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsModeArtist[0] && parts[1] == self.commandsModeArtist[1] {
            self.onCommandClearModeArtist(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsModeYear[0] && parts[1] == self.commandsModeYear[1] {
            self.onCommandClearModeYear(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsModeSearch[0] && parts[1] == self.commandsModeSearch[1] {
            self.onCommandClearModeSearch(parts: parts)
        }
        else if parts.count == 2 && parts[0] == self.commandsInfo[0] {
            self.onCommandInfoSong(parts: parts)
        }
        else if isCommandInCommands(command, self.commandsHelp) {
            self.onCommandHelp(parts: parts)
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
        self.isSkipping = true
        g_player.skip(crossfade: false)
        self.isSkipping = false
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
        Console.clearScreen()
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
    /// Set mode genre.
    ///
    /// parameter parts: command array.
    ///
    func onCommandModeGenre(parts: [String]) -> Void {
        g_lock.lock()
        
        g_modeGenre.removeAll()
        
        let nparts = reparseCurrentCommandArguments(parts)
        
        if nparts.count > 2 {
            var i: Int = 2
            while i < nparts.count {
                let name = nparts[i].lowercased()
                if g_genres[name] != nil {
                    if g_genres[name]!.count >= 1 {
                        g_modeGenre.append(name)
                    }
                }
                i += 1
            }
        }
        
        if g_modeGenre.count > 0 {
            g_modeArtist.removeAll()
            g_modeRecordingYears.removeAll()
            g_modeSearch.removeAll()
        }
        
        g_lock.unlock()
    }
    
    ///
    /// Set mode artist.
    ///
    /// parameter parts: command array.
    ///
    func onCommandModeArtist(parts: [String]) -> Void {
        g_lock.lock()
        
        g_modeArtist.removeAll()
        
        let nparts = reparseCurrentCommandArguments(parts)
        
        if nparts.count > 2 {
            var i: Int = 2
            while i < nparts.count {
                let name = nparts[i].lowercased()
                for a in g_artists {
                    if a.key.lowercased() == name {
                        if a.value.count >= 1 {
                            g_modeArtist.append(a.key)
                        }
                    }
                }
                i += 1
            }
        }
        
        if g_modeArtist.count > 0 {
            g_modeGenre.removeAll()
            g_modeRecordingYears.removeAll()
            g_modeSearch.removeAll()
        }
        
        g_lock.unlock()
    }
    
    ///
    /// Set mode year
    ///
    /// parameter parts: command array.
    ///
    func onCommandModeYear(parts: [String]) -> Void {
        g_lock.lock()
        
        g_modeRecordingYears.removeAll()
        
        let nparts = reparseCurrentCommandArguments(parts)
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if nparts.count > 2 {
            var i: Int = 2
            while i < nparts.count {
                let year = nparts[i]
                
                let yearsSubs = year.split(separator: "-")
                
                var years: [String] = []
                for ys in yearsSubs {
                    years.append(String(ys))
                }
                
                if years.count == 1 {
                    let resultYear = Int(years[0]) ?? 0
                    if resultYear >= 0 && resultYear <= currentYear {
                        if g_recordingYears[resultYear] != nil {
                            g_modeRecordingYears.append(Int(years[0]) ?? 0)
                        }
                    }
                }
                else if years.count == 2 {
                    let from: Int = Int(years[0]) ?? -1
                    let to: Int = Int(years[1]) ?? -1
                    
                    if to <= currentYear {
                        if from != -1 && to != -6 && from <= to {
                            for y in from...to {
                                if g_recordingYears[y] != nil {
                                    g_modeRecordingYears.append(y)
                                }
                            }
                        }
                    }
                }
                i += 1
            }
        }
        
        if g_modeRecordingYears.count > 0 {
            g_modeArtist.removeAll()
            g_modeGenre.removeAll()
            g_modeSearch.removeAll()
        }
        
        g_lock.unlock()
    }
    
    ///
    /// Set  mode search.
    ///
    /// parameter parts: command array.
    ///
    func onCommandModeSearch(parts: [String]) -> Void {
        g_lock.lock()
        
        var nparts = reparseCurrentCommandArguments(parts)
        nparts.removeFirst()
        nparts.removeFirst()
        
        if nparts.count > 0 {
            let wnd: SearchWindow = SearchWindow()
            wnd.performSearch(terms: nparts)
            if wnd.searchResult.count > 0 {
                g_modeSearch = nparts
                g_modeSearchStats = wnd.stats
                g_searchResult = wnd.searchResult
            }
            else {
                g_modeSearch = []
                g_modeSearchStats = []
                g_searchResult = []
            }
            
            if g_modeSearch.count > 0 {
                g_modeArtist.removeAll()
                g_modeGenre.removeAll()
                g_modeRecordingYears.removeAll()
            }
        }
        g_lock.unlock()
    }
    
    ///
    /// Clear mode genre.
    ///
    /// parameter parts: command array.
    ///
    func onCommandClearModeGenre(parts: [String]) -> Void {
        g_lock.lock()
        g_modeGenre.removeAll()
        g_lock.unlock()
    }
    
    ///
    /// Clear mode artist.
    ///
    /// parameter parts: command array.
    ///
    func onCommandClearModeArtist(parts: [String]) -> Void {
        g_lock.lock()
        g_modeArtist.removeAll()
        g_lock.unlock()
    }
    
    ///
    /// Clear mode year.
    ///
    /// parameter parts: command array.
    ///
    func onCommandClearModeYear(parts: [String]) -> Void {
        g_lock.lock()
        g_modeRecordingYears.removeAll()
        g_lock.unlock()
    }
    
    ///
    /// Clear mode year.
    ///
    /// parameter parts: command array.
    ///
    func onCommandClearModeSearch(parts: [String]) -> Void {
        g_lock.lock()
        g_modeSearch.removeAll()
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
                        Console.clearScreen()
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
        Console.clearScreen()
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
        Console.clearScreen()
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
        Console.clearScreen()
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
        Console.clearScreen()
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
        Console.clearScreen()
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
        Console.clearScreen()
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
        
        g_genres.removeAll()
        g_artists.removeAll()
        g_recordingYears.removeAll()
        g_modeGenre.removeAll()
        g_modeArtist.removeAll()
        g_modeRecordingYears.removeAll()
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
            Console.clearScreen()
            MainWindow.renderHeader(showTime: false)
            self.isShowingTopWindow = true
            g_player.initializeSongs()
        }
        else {
            Console.clearScreen()
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
        Console.clearScreen()
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
        Console.clearScreen()
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
            wnd.showWindow(parts: nparts)
            Console.clearScreen()
            self.renderScreen()
            self.isShowingTopWindow = false
        }
    }// onCommandSearch
}// CMPlayer
