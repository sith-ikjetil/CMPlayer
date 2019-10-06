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
internal class HelpWindow : TerminalSizeChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/constants
    //
    private var helpIndex: Int = 0
    private let helpText: [String] = [" exit, quit", " :: exits application",
                                      " next, skip, 'TAB'-key", " :: plays next song",
                                      " play, pause, resume", " :: plays, pauses or resumes playback",
                                      " search [<words>]", " :: searches artist and title for a match. case insensitive",
                                      " search-artist [<words>]", " :: searches artist for a match. case insensitive",
                                      " search-title [<words>]", " :: searches title for a match. case insensitive",
                                      " search-album [<words>]", " :: searches album name for a match. case insensitive",
                                      " search-genre [<words>]", " :: searches genre for a match. case insensitive",
                                      " search-year [<year>]", " :: searches recorded year for a match.",
                                      " clear mode", " :: clears mode playback. playback now from entire song library",
                                      " help"," :: shows this help information",
                                      " pref", " :: shows preferences information",
                                      " about"," :: show the about information",
                                      " genre"," :: shows all genre information and statistics",
                                      " year", " :: shows all year information and statistics",
                                      " mode", " :: shows current mode information and statistics",
                                      " repaint", " :: clears and repaints entire console window",
                                      " add mrp <path>", " :: adds the path to music root folder",
                                      " remove mrp <path>", " :: removes the path from music root folders",
                                      " clear mrp", " :: clears all paths from music root folders",
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
                                      " update cmplayer", " :: updates cmplayer if new version is found online",
                                      " set viewtype <type>", " :: sets view type. can be 'default' or 'details'",
                                      " set theme <color>", " :: sets theme color. color can be 'default', 'blue' or 'black'"]
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    func showWindow() -> Void {
        self.helpIndex = 0
        g_tscpStack.append(self)
        self.renderWindow()
        self.run()
        g_tscpStack.removeLast()
    }
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        self.renderWindow()
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderWindow() -> Void {
        Console.clearScreenCurrentTheme()
        
        if g_rows < 24 || g_cols < 80 {
            return
        }
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeBgColor()
        Console.printXY(1,3,":: HELP ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
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
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.helpIndex = 0
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.helpIndex + 17) < self.helpText.count {
                self.helpIndex += 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.helpIndex > 0 {
                self.helpIndex -= 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
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
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
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
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
