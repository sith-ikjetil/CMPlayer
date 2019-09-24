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
class SearchWindow {
    //
    // Private properties/constants.
    //
    private var searchIndex: Int = 0
    
    ///
    /// Performs search from arguments. Searches g_songs.
    ///
    /// parameter terms: Array of search terms.
    ///
    func performSearch(terms: [String]) -> Void {
        g_searchResult.removeAll(keepingCapacity: false)
        let nterms = reparseCurrentCommandArguments(terms) // reparse the arguments taking "a b" strings into account
        for se in g_songs {
            let artist = se.artist.lowercased()
            let title = se.title.lowercased()
            
            for t in nterms {
                let term = t.lowercased()
                
                if artist.contains(term) || title.contains(term) {
                    g_searchResult.append(se)
                    break
                }
            }
        }
    }
    
    ///
    /// Shows this SearchWindow on screen.
    ///
    func showWindow(parts: [String]) -> Void {
        self.renderSearch()
        self.run(parts: parts)
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
            
            if index_search > g_searchResult.count - 1 {
                break
            }
            
            let se = g_searchResult[index_search]
            
            Console.printXY(1, index_screen_lines, "\(se.songNo) ", widthSongNo+1, .right, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            
            Console.printXY(10, index_screen_lines, "\(se.artist)", widthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)

            Console.printXY(43, index_screen_lines, "\(se.title)", widthSong, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(76, index_screen_lines, itsRenderMsToFullString(se.duration, false), widthTime, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT SEARCH RESULTS", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,24,"Results Found: \(g_searchResult.count.itsToString())",80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs SearchWindow keyboard input and feedback.
    ///
    /// parameter parts: command parts from search input command.
    ///
    func run(parts: [String]) -> Void {
        var p : [String] = []
        for px in parts {
            p.append(px)
        }
        _ = p.removeFirst()
        self.searchIndex = 0
        self.performSearch(terms: p)
        self.renderSearch()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: 66, closure: { () -> Bool in
            if (self.searchIndex + 17) < g_searchResult.count {
                self.searchIndex += 1
                self.renderSearch()
            }
            return false
        })
        keyHandler.addKeyHandler(key: 65, closure: { () -> Bool in
            if self.searchIndex > 0 {
                self.searchIndex -= 1
                self.renderSearch()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// SearchWindow
