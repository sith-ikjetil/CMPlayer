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
/// Represents CMPlayer AboutWindow.
///
internal class AboutWindow {
    ///
    /// Private properties/constants.
    ///
    private var aboutIndex: Int = 0
    private let aboutText: [String] = ["   CMPlayer (Console Music Player) is a clone and improvement over the",
                                       "   Interactive DJ software written in summer 1997 running on DOS.",
                                       "   ",
                                       "   The CMPlayer software runs on macOS as a console application.",
                                       "   ",
                                       "   CMPlayer is a different kind of music player. It selects random songs",
                                       "   from your library and runs to play continually. You choose music",
                                       "   by searching for them, and in the main window entering the number",
                                       "   associated with the song to add to the playlist.",
                                       "   ",
                                       "   CMPlayer was made by Kjetil Kristoffer Solberg. ENJOY!"]
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.aboutIndex = 0
        self.renderAbout()
        self.run()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderAbout() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### ABOUT ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = self.aboutIndex
        let max = self.aboutIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > self.aboutText.count - 1 {
                break
            }
            
            let se = self.aboutText[index_search]
            
            Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        //Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE TEXT. OTHER KEY TO EXIT ABOUT.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.aboutIndex = 0
        self.renderAbout()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.aboutIndex + 17) < self.aboutText.count {
                self.aboutIndex += 1
                self.renderAbout()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.aboutIndex > 0 {
                self.aboutIndex -= 1
                self.renderAbout()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            if self.aboutIndex > 0 && self.aboutText.count > g_windowContentLineCount {
                if self.aboutIndex - g_windowContentLineCount > 0 {
                    self.aboutIndex -= g_windowContentLineCount
                }
                else {
                    self.aboutIndex = 0
                }
                self.renderAbout()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            if self.aboutIndex >= 0 && self.aboutText.count > g_windowContentLineCount {
                if self.aboutIndex + g_windowContentLineCount < self.aboutText.count - g_windowContentLineCount {
                    self.aboutIndex += g_windowContentLineCount
                }
                else {
                    self.aboutIndex = self.aboutText.count - g_windowContentLineCount
                }
                self.renderAbout()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
