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
internal class ArtistWindow : TerminalSizeChangedProtocol {
    ///
    /// Private properties/constants.
    ///
    private var artistIndex: Int = 0
    private var artistText: [String] = []
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.artistIndex = 0
        
        self.updateArtistText()
        
        g_tscpStack.append(self)
        
        self.renderArtist()
        self.run()
        
        g_tscpStack.removeLast()
    }
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        self.renderArtist()
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Updates the genere text array. Called before visual showing.
    ///
    func updateArtistText() -> Void
    {
        self.artistText.removeAll()
        
        let sorted = g_artists.sorted { $0.key < $1.key }
        
        for g in sorted {
            let name = g.key
            let desc = " :: \(g.value.count) Songs"
    
            self.artistText.append(name)
            self.artistText.append(desc)
        }
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderArtist() -> Void {
        Console.clearScreenCurrentTheme()
        
        if g_rows < 24 || g_cols < 80 {
            return
        }
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeBgColor()
        Console.printXY(1,3,":: ARTIST ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4,"mode artist is: \((g_searchType != SearchType.Artist) ? "off" : "on")", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = artistIndex
        let max = artistIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > artistText.count - 1 {
                break
            }
            
            let se = artistText[index_search]
            
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
        
        Console.printXY(1,24,"Artist Count: \(g_artists.count.itsToString())", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.artistIndex = 0
        self.renderArtist()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.artistIndex + 17) < self.artistText.count {
                self.artistIndex += 1
                self.renderArtist()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.artistIndex > 0 {
                self.artistIndex -= 1
                self.renderArtist()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            if self.artistIndex > 0 && self.artistText.count > g_windowContentLineCount {
                if self.artistIndex - g_windowContentLineCount > 0 {
                    self.artistIndex -= g_windowContentLineCount
                }
                else {
                    self.artistIndex = 0
                }
                self.renderArtist()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            if self.artistIndex >= 0 && self.artistText.count > g_windowContentLineCount {
                if self.artistIndex + g_windowContentLineCount < self.artistText.count - g_windowContentLineCount {
                    self.artistIndex += g_windowContentLineCount
                }
                else {
                    self.artistIndex = self.artistText.count - g_windowContentLineCount
                }
                self.renderArtist()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
