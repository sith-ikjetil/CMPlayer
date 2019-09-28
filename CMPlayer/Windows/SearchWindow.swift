//
//  SearchWindow.swift
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
/// Represents CMPlayer SearchWindow.
///
internal class SearchWindow {
    //
    // Private properties/constants.
    //
    private var searchIndex: Int = 0
    var searchResult: [SongEntry] = []
    private var parts: [String] = []
    
    ///
    /// Performs search from arguments. Searches g_songs.
    ///
    /// parameter terms: Array of search terms.
    ///
    func performSearch(terms: [String]) -> Void {
        self.searchResult.removeAll(keepingCapacity: false)
        
        for se in g_songs {
            let artist = se.artist.lowercased()
            let title = se.title.lowercased()
            
            for t in terms {
                let term = t.lowercased()
                
                if artist.contains(term) || title.contains(term) {
                    self.searchResult.append(se)
                    break
                }
            }
        }
        
        self.searchResult = self.searchResult.sorted { $0.artist < $1.artist }
    }
    
    ///
    /// Shows this SearchWindow on screen.
    ///
    func showWindow(parts: [String]) -> Void {
        self.parts = reparseCurrentCommandArguments(parts)
        self.renderSearch()
        self.run()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderSearch() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### SEARCH RESULTS ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = searchIndex
        let max = searchIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > self.searchResult.count - 1 {
                break
            }
            
            let se = self.searchResult[index_search]
            
            Console.printXY(1, index_screen_lines, "\(se.songNo) ", g_fieldWidthSongNo+1, .right, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            
            Console.printXY(10, index_screen_lines, "\(se.artist)", g_fieldWidthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)

            Console.printXY(43, index_screen_lines, "\(se.title)", g_fieldWidthTitle, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(76, index_screen_lines, itsRenderMsToFullString(se.duration, false), g_fieldWidthDuration, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS 'SPACEBAR' TO SET SEARCH MODE. PRESS ANY OTHER KEY TO EXIT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,24,"Songs Found: \(self.searchResult.count.itsToString())",80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs SearchWindow keyboard input and feedback.
    ///
    /// parameter parts: command parts from search input command.
    ///
    func run() -> Void {
        var p : [String] = []
        for px in parts {
            p.append(px)
        }
        _ = p.removeFirst()
        self.searchIndex = 0
        self.performSearch(terms: self.parts)
        self.renderSearch()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.searchIndex + 17) < self.searchResult.count {
                self.searchIndex += 1
                self.renderSearch()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.searchIndex > 0 {
                self.searchIndex -= 1
                self.renderSearch()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            if self.searchIndex > 0  && self.searchResult.count > g_windowContentLineCount {
                if self.searchIndex - g_windowContentLineCount > 0 {
                    self.searchIndex -= g_windowContentLineCount
                }
                else {
                    self.searchIndex = 0
                }
                self.renderSearch()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            if self.searchIndex >= 0  && self.searchResult.count > g_windowContentLineCount {
                if self.searchIndex + g_windowContentLineCount < self.searchResult.count - g_windowContentLineCount {
                    self.searchIndex += g_windowContentLineCount
                }
                else {
                    self.searchIndex = self.searchResult.count - g_windowContentLineCount
                }
                self.renderSearch()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_SPACEBAR, closure: { () -> Bool in
            g_searchResult = self.searchResult
            
            var mode: [String] = []
            var i: Int = 1
            while i < self.parts.count {
                mode.append(self.parts[i])
                i += 1
            }
            g_modeSearch = mode
            
            return true
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// SearchWindow
