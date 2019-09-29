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
internal class HelpWindow {
    //
    // Private properties/constants
    //
    private var helpIndex: Int = 0
    private let helpText: [String] = [" exit, quit", " :: exits application",
                                      " next, skip, 'TAB'-key", " :: plays next song",
                                      " play, pause, resume", " :: plays, pauses or resumes playback",
                                      " search [<words>]", " :: searches artist and title for a match. case insensitive",
                                      " help"," :: shows this help information",
                                      " pref", " :: shows preferences information",
                                      " about"," :: show the about information",
                                      " genre"," :: shows all genre information and statistics",
                                      " year", " :: shows all year information and statistics",
                                      " mode", " :: shows all modes information and statistics",
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
                                      " restart", " :: Restarts playing current playing song",
                                      " mode artist [<artist>]", " :: set playback of songs only from given artists",
                                      " mode artist", " :: removes mode artist playback and plays songs from entire library",
                                      " mode genre [<genre>]", " :: set playback of songs only from the given genres",
                                      " mode genre", " :: removes mode genre playback and plays songs from entire library",
                                      " mode year [<year>]", " :: set playback of songs only from given years",
                                      " mode year <year from>-<year to>", " :: set playback of songs from given year interval",
                                      " mode year", " :: removes mode year playback and plays songs from entire library",
                                      " mode search [<words]", " :: set playback of songs only from given search words",
                                      " mode search", " :: removes mode search playback and plays songs from entire library",
                                      " reinitialize", " :: reinitializes library and should be called after mrp paths are changed",
                                      " info", " :: shows information about first song in playlist",
                                      " info <song no>", " :: show information about song with given song number"]
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    func showWindow() -> Void {
        self.helpIndex = 0
        self.renderHelp()
        self.run()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderHelp() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### HELP ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
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
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.helpIndex = 0
        self.renderHelp()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.helpIndex + 17) < self.helpText.count {
                self.helpIndex += 1
                self.renderHelp()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.helpIndex > 0 {
                self.helpIndex -= 1
                self.renderHelp()
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
                self.renderHelp()
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
                self.renderHelp()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
