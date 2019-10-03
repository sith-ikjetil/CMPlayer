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
internal class GenreWindow {
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
        self.renderGenre()
        self.run()
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
            
            var hit = false
            for e in g_modeGenre {
                if e == name {
                    hit = true
                    break;
                }
            }
            
            if hit {
                self.genreText.append("\(name) (*)")
            }
            else {
                self.genreText.append(name)
            }
            self.genreText.append(desc)
        }
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderGenre() -> Void {
        Console.clearScreenCurrentTheme()
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeColor()
        Console.printXY(1,3,"### GENRE ###", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4,"mode genre is: \((g_modeGenre.count == 0) ? "off" : "on")", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
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
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,24,"Genre Count: \(g_genres.count.itsToString())", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.genreIndex = 0
        self.renderGenre()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.genreIndex + 17) < self.genreText.count {
                self.genreIndex += 1
                self.renderGenre()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.genreIndex > 0 {
                self.genreIndex -= 1
                self.renderGenre()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            if self.genreIndex > 0 && self.genreText.count > g_windowContentLineCount {
                if self.genreIndex - g_windowContentLineCount > 0 {
                    self.genreIndex -= g_windowContentLineCount
                }
                else {
                    self.genreIndex = 0
                }
                self.renderGenre()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            if self.genreIndex >= 0 && self.genreText.count > g_windowContentLineCount {
                if self.genreIndex + g_windowContentLineCount < self.genreText.count - g_windowContentLineCount {
                    self.genreIndex += g_windowContentLineCount
                }
                else {
                    self.genreIndex = self.genreText.count - g_windowContentLineCount
                }
                self.renderGenre()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
