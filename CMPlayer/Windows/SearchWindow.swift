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
internal class SearchWindow : TerminalSizeChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/variables/constants.
    //
    private var searchIndex: Int = 0
    private var partsYear: [String] = []
    
    //
    // Public properties/variables/constants
    //
    var searchResult: [SongEntry] = []
    var parts: [String] = []
    var stats: [Int] = []
    var type: SearchType = SearchType.ArtistOrTitle
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        self.renderWindow()
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Performs search from arguments. Searches g_songs.
    ///
    /// parameter terms: Array of search terms.
    ///
    func performSearch(terms: [String], type: SearchType) -> Void {
        self.searchResult.removeAll(keepingCapacity: false)
        self.partsYear.removeAll()
        
        self.stats.removeAll()
        for _ in 0..<terms.count {
            self.stats.append(0)
        }

        if type == SearchType.Genre {
            var index: Int = 0
            for name in terms {
                let name = name.lowercased()
                if g_genres[name] != nil {
                    if g_genres[name]!.count >= 1 {
                        self.searchResult.append(contentsOf: g_genres[name]!)
                        self.stats[index] += g_genres[name]!.count
                    }
                }
                index += 1
            }
        }
        else if type == SearchType.RecordedYear {
            let currentYear = Calendar.current.component(.year, from: Date())
            var index: Int = 0
            for year in terms {
                let yearsSubs = year.split(separator: "-")
                
                var years: [String] = []
                for ys in yearsSubs {
                    years.append(String(ys))
                }
                
                if years.count == 1 {
                    let resultYear = Int(years[0]) ?? -1
                    if resultYear >= 0 && resultYear <= currentYear {
                        if g_recordingYears[resultYear] != nil {
                            if g_recordingYears[resultYear]!.count >= 1 {
                                self.searchResult.append(contentsOf: g_recordingYears[resultYear]!)
                                self.partsYear.append(String(resultYear))
                                self.stats[index] += g_recordingYears[resultYear]!.count
                            }
                        }
                    }
                    index += 1
                }
                else if years.count == 2 {
                    let from: Int = Int(years[0]) ?? -1
                    let to: Int = Int(years[1]) ?? -1
                    
                    if to <= currentYear {
                        if from != -1 && to != -1 && from <= to {
                            let xfrom: Int = from + 1
                            for _ in xfrom...to {
                                self.stats.append(0)
                            }
                            for y in from...to {
                                if g_recordingYears[y] != nil {
                                    if g_recordingYears[y]!.count >= 1 {
                                        self.searchResult.append(contentsOf: g_recordingYears[y]!)
                                        self.partsYear.append(String(y))
                                        self.stats[index] += g_recordingYears[y]!.count
                                        index += 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            for se in g_songs {
                let artist = se.artist.lowercased()
                let title = se.title.lowercased()
                let album = se.albumName.lowercased()
                var index: Int = 0
                
                for t in terms {
                    let term = t.lowercased()
                    
                    if type == SearchType.ArtistOrTitle {
                        if artist.contains(term) || title.contains(term) {
                            self.searchResult.append(se)
                            self.stats[index] += 1
                            break
                        }
                    }
                    else if type == SearchType.Artist {
                        if artist.contains(term) {
                            self.searchResult.append(se)
                            self.stats[index] += 1
                            break
                        }
                    }
                    else if type == SearchType.Title {
                        if title.contains(term) {
                            self.searchResult.append(se)
                            self.stats[index] += 1
                            break
                        }
                    }
                    else if type == SearchType.Album {
                        if album.contains(term) {
                            self.searchResult.append(se)
                            self.stats[index] += 1
                            break
                        }
                    }
                    index += 1
                }
            }
        }
    
        self.searchResult = self.searchResult.sorted {sortSongEntry(se1: $0, se2: $1)} // $0.artist < $1.artist }
    }
    
    ///
    /// Shows this SearchWindow on screen.
    ///
    func showWindow() -> Void {
        g_tscpStack.append(self)
        self.renderWindow()
        self.run()
        g_tscpStack.removeLast()
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
        
        Console.printXY(1,3,":: SEARCH RESULT ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
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
            
            Console.printXY(1, index_screen_lines, "\(se.songNo) ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            
            Console.printXY(10, index_screen_lines, "\(se.artist)", g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)

            Console.printXY(43, index_screen_lines, "\(se.title)", g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            Console.printXY(76, index_screen_lines, itsRenderMsToFullString(se.duration, false), g_fieldWidthDuration, .ignore, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        if self.searchResult.count > 0 {
            Console.printXY(1,23,"PRESS 'SPACEBAR' TO SET SEARCH MODE. PRESS ANY OTHER KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        else {
            Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        
        Console.printXY(1,24,"Songs Found: \(self.searchResult.count.itsToString())",80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
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
        self.performSearch(terms: self.parts, type: self.type)
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.searchIndex + 17) < self.searchResult.count {
                self.searchIndex += 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.searchIndex > 0 {
                self.searchIndex -= 1
                self.renderWindow()
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
                self.renderWindow()
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
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_SPACEBAR, closure: { () -> Bool in
            if self.searchResult.count > 0 {
                if  self.type == SearchType.ArtistOrTitle ||
                    self.type == SearchType.Artist ||
                    self.type == SearchType.Title ||
                    self.type == SearchType.Album
                {
                    g_modeSearch = self.parts
                }
                else if self.type == SearchType.Genre {
                    g_modeSearch = self.parts
                }
                else if self.type == SearchType.RecordedYear {
                    g_modeSearch = self.partsYear
                }
            
                g_searchResult = self.searchResult
                g_modeSearchStats = self.stats
                g_searchType = self.type
            }
            return true
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// SearchWindow
