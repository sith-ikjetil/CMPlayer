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
internal class GenreWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    ///
    /// Private properties/constants.
    ///
    private var genreIndex: Int = 0
    private var genreText: [String] = []
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.genreIndex = 0
        self.updateGenreText()
        
        g_tscpStack.append(self)
        Console.clearScreenCurrentTheme()
        self.renderWindow()
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
    /// Updates the genere text array. Called before visual showing.
    ///
    func updateGenreText() -> Void
    {
        self.genreText.removeAll()
        
        let sorted = g_genres.sorted { $0.key < $1.key }
        
        for g in sorted {
            let name = g.key.lowercased()
            let desc = " :: \(g.value.count) Songs"
    
            self.genreText.append(name)
            self.genreText.append(desc)
        }
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
        Console.printXY(1,3,":: GENRE ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4,"mode genre is: \((isSearchTypeInMode(SearchType.Genre)) ? "off" : "on")", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = genreIndex
        let max = genreIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > genreText.count - 1 {
                break
            }
            
            let se = genreText[index_search]
            
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
        
        Console.printXY(1,24,"\(g_genres.count.itsToString()) Genres", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        Console.clearScreenCurrentTheme()
        self.genreIndex = 0
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_DOWN1.rawValue, ConsoleKey.KEY_DOWN2.rawValue], closure: { () -> Bool in
            if (self.genreIndex + 17) < self.genreText.count {
                self.genreIndex += 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_UP1.rawValue, ConsoleKey.KEY_UP2.rawValue], closure: { () -> Bool in
            if self.genreIndex > 0 {
                self.genreIndex -= 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_LEFT1.rawValue, ConsoleKey.KEY_LEFT2.rawValue], closure: { () -> Bool in
            if self.genreIndex > 0 && self.genreText.count > g_windowContentLineCount {
                if self.genreIndex - g_windowContentLineCount > 0 {
                    self.genreIndex -= g_windowContentLineCount
                }
                else {
                    self.genreIndex = 0
                }
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: [ConsoleKey.KEY_RIGHT1.rawValue, ConsoleKey.KEY_RIGHT2.rawValue], closure: { () -> Bool in
            if self.genreIndex >= 0 && self.genreText.count > g_windowContentLineCount {
                if self.genreIndex + g_windowContentLineCount < self.genreText.count - g_windowContentLineCount {
                    self.genreIndex += g_windowContentLineCount
                }
                else {
                    self.genreIndex = self.genreText.count - g_windowContentLineCount
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
}// AboutWindow
