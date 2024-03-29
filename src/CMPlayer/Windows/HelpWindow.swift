//
//  HelpWindow.swift
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
/// Represents CMPlayer HelpWindow.
///
internal class HelpWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/constants
    //
    private var helpIndex: Int = 0
    private let helpText: [String] = [" exit, quit, q", " :: exits application",
                                      " next, skip, n, s, 'TAB'-key", " :: plays next song",
                                      " play, p", " :: plays music",
                                      " pause, p", " :: pauses music",
                                      //" resume", " :: resumes music playback",
                                      " search [<words>]", " :: searches artist and title for a match. case insensitive",
                                      " search artist [<words>]", " :: searches artist for a match. case insensitive",
                                      " search title [<words>]", " :: searches title for a match. case insensitive",
                                      " search album [<words>]", " :: searches album name for a match. case insensitive",
                                      " search genre [<words>]", " :: searches genre for a match. case insensitive",
                                      " search year [<year>]", " :: searches recorded year for a match.",
                                      " mode off", " :: clears mode playback. playback now from entire song library",
                                      " help"," :: shows this help information",
                                      " pref", " :: shows preferences information",
                                      " about"," :: show the about information",
                                      " genre"," :: shows all genre information and statistics",
                                      " year", " :: shows all year information and statistics",
                                      " mode", " :: shows current mode information and statistics",
                                      " repaint", " :: clears and repaints entire console window",
                                      " add mrp <path>", " :: adds the path to music root path",
                                      " remove mrp <path>", " :: removes the path from music root paths",
                                      " clear mrp", " :: clears all paths from music root paths",
                                      " add exp <path>", " :: adds the path to exclusion paths",
                                      " remove exp <path>", " :: removes the path from exclusion paths",
                                      " clear exp", " :: clears all paths from exclusion paths",
                                      " set cft <seconds>", " :: sets the crossfade time in seconds (1-10 seconds)",
                                      " set mf <formats>", " :: sets the supported music formats (separated by ;)",
                                      " enable crossfade"," :: enables crossfade",
                                      " disable crossfade", " :: disables crossfade",
                                      " enable aos", " :: enables playing on application startup",
                                      " disable aos", " :: disables playing on application startup",
                                      " rebuild songno"," :: rebuilds song numbers",
                                      " goto <mm:ss>", " :: moves playback point to minutes (mm) and seconds (ss) of current song",
                                      " replay", " :: starts playing current song from beginning again",
                                      " reinitialize", " :: reinitializes library and should be called after mrp paths are changed",
                                      " info", " :: shows information about first song in playlist",
                                      " info <song no>", " :: show information about song with given song number",
                                      //" update cmplayer", " :: updates cmplayer if new version is found online",
                                      " set viewtype <type>", " :: sets view type. can be 'default' or 'details'",
                                      " set theme <color>", " :: sets theme color. color can be 'default', 'blue' or 'black'",
                                      " restart", " :: restarts the application. picks up changes when files are removed or added"]
    
    ///
    /// Shows this HelpWindow on screen.q
    ///
    func showWindow() -> Void {
        self.helpIndex = 0
        g_tscpStack.append(self)
        Console.clearScreenCurrentTheme()
        self.run()
        g_tscpStack.removeLast()
    }
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        Console.clearScreenCurrentTheme()
        self.renderWindow()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderWindow() -> Void {
        if g_rows < 24 || g_cols < 80 {
            return
        }
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeBgColor()
        Console.printXY(1,3,":: HELP ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4," ", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = helpIndex
        let max = helpIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > helpText.count - 1 {
                break
            }
            
            let se = helpText[index_search]
            
            if index_search % 2 == 0 {
                Console.printXY(1, index_screen_lines, se, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,24,"\((self.helpText.count/2).itsToString()) Commands", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        Console.clearScreenCurrentTheme()
        self.helpIndex = 0
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_DOWN1.rawValue, ConsoleKey.KEY_DOWN2.rawValue], closure: { () -> Bool in
            if (self.helpIndex + 17) < self.helpText.count {
                self.helpIndex += 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_UP1.rawValue, ConsoleKey.KEY_UP2.rawValue], closure: { () -> Bool in
            if self.helpIndex > 0 {
                self.helpIndex -= 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_LEFT1.rawValue, ConsoleKey.KEY_LEFT2.rawValue], closure: { () -> Bool in
            if self.helpIndex > 0  && self.helpText.count > g_windowContentLineCount {
                if self.helpIndex - g_windowContentLineCount > 0 {
                    self.helpIndex -= g_windowContentLineCount
                }
                else {
                    self.helpIndex = 0
                }
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_RIGHT1.rawValue, ConsoleKey.KEY_RIGHT2.rawValue], closure: { () -> Bool in
            if self.helpIndex >= 0  && self.helpText.count > g_windowContentLineCount {
                if self.helpIndex + g_windowContentLineCount < self.helpText.count - g_windowContentLineCount {
                    self.helpIndex += g_windowContentLineCount
                }
                else {
                    self.helpIndex = self.helpText.count - g_windowContentLineCount
                }
                self.renderWindow()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: UInt32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
