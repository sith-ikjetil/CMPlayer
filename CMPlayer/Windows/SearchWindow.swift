//
//  SearchWindow.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 20/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

class SearchWindow {
    private var searchIndex: Int = 0
    
    func performSearch(terms: [String]) -> Void {
        g_searchResult.removeAll(keepingCapacity: false)
        let nterms = reparseCurrentCommandArguments(terms)
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
    
    func showWindow(parts: [String]) -> Void {
        self.renderSearch()
        self.run(parts: parts)
    }
    
    func renderSearch() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader()
        
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
            
            Console.printXY(1, index_screen_lines, "\(se.number) ", widthSongNo+1, .right, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            
            Console.printXY(10, index_screen_lines, "\(se.artist)", widthArtist, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)

            Console.printXY(43, index_screen_lines, "\(se.title)", widthSong, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(76, index_screen_lines, itsRenderMsToFullString(se.duration, false), widthTime, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT SEARCH RESULTS", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,24,"Results Found: \(g_searchResult.count.itsToString())",80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func run(parts: [String]) -> Void {
        var p : [String] = []
        for px in parts {
            p.append(px)
        }
        _ = p.removeFirst()
        self.searchIndex = 0
        self.performSearch(terms: p)
        self.renderSearch()
        var ch = getchar()
        while ch == EOF || ch == 27 || ch == 91 || ch == 65 || ch == 66 {
            if ch == 27 {
                ch = getchar()
            }
            if ch == 91 {
                ch = getchar()
            }
            
            if ch == 66 { // DOWN
                if (self.searchIndex + 17) < g_searchResult.count {
                    self.searchIndex += 1
                    self.renderSearch()
                }
            }
            if ch == 65 { // UP
                if self.searchIndex > 0 {
                    self.searchIndex -= 1
                    self.renderSearch()
                }
            }
            ch = getchar()
        }
    }
}
