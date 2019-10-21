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
internal class SearchWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/variables/constants.
    //
    private var searchIndex: Int = 0
    private var partsYear: [String] = []
    private var modeOff: Bool = false
    
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
        Console.clearScreenCurrentTheme()
        self.renderWindow()
    }
    
    ///
    /// Perform narrow search from arguments.
    ///
    func performNarrowSearch(terms: [String], type: SearchType) -> Void {
        //for t in g_searchType {
        //    if t == type {
        //        return  // Can only search for type once
        //    }
        //}
        
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
                for s in g_searchResult {
                    if s.genre == name {
                        self.searchResult.append(s)
                        self.stats[index] += 1
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
                        for s in g_searchResult {
                            if s.recodingYear == resultYear {
                                self.searchResult.append(s)
                                self.stats[index] += 1
                            }
                        }
                        self.partsYear.append(String(resultYear))
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
                                for s in g_searchResult {
                                    if s.recodingYear == y {
                                        self.searchResult.append(s)
                                        self.stats[index] += 1
                                    }
                                }
                                index += 1
                                self.partsYear.append(String(y))
                            }
                        }
                    }
                }
            }
        }
        else {
            for se in g_searchResult {
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
    /// Performs search from arguments. Searches g_songs.
    ///
    /// parameter terms: Array of search terms.
    ///
    func performSearch(terms: [String], type: SearchType) -> Void {
        for t in g_searchType {
            if t == type {
                modeOff = true
                break;
            }
        }
        
        if !modeOff && g_searchResult.count > 0 {
            performNarrowSearch(terms: terms, type: type)
            return
        }
        
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
        Console.clearScreenCurrentTheme()
        self.renderWindow()
        self.run()
        g_tscpStack.removeLast()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderWindow() -> Void {
        //Console.clearScreenCurrentTheme()
        
        if g_rows < 24 || g_cols < 80 {
            return
        }
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeBgColor()
        
        Console.printXY(1,3,":: SEARCH RESULT ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        if PlayerPreferences.viewType == ViewType.Default {
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
        }
        else if PlayerPreferences.viewType == ViewType.Details {
            let songNoColor = ConsoleColor.cyan
            
            var index_screen_lines: Int = 5
            var index_search: Int = searchIndex
            let max = searchIndex + 21
            while index_search < max {
                if index_screen_lines >= 22 {
                    break
                }
                
                if index_search > self.searchResult.count - 1 {
                    break
                }
                
                let song = self.searchResult[index_search]
                
                Console.printXY(1, index_screen_lines, String(song.songNo)+" ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, songNoColor, ConsoleColorModifier.bold)
                Console.printXY(1, index_screen_lines+1, " ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                
                Console.printXY(10, index_screen_lines, song.artist, g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                Console.printXY(10, index_screen_lines+1, song.albumName, g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                
                Console.printXY(43, index_screen_lines, song.title, g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                Console.printXY(43, index_screen_lines+1, song.genre, g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                
                let timeString: String = itsRenderMsToFullString(song.duration, false)
                let endTimePart: String = String(timeString[timeString.index(timeString.endIndex, offsetBy: -5)..<timeString.endIndex])
                Console.printXY(76, index_screen_lines, endTimePart, g_fieldWidthDuration, .ignore, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                
                Console.printXY(76, index_screen_lines+1, " ", g_fieldWidthDuration, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                
                index_screen_lines += 2
                index_search += 1
            }
        }
        
        if self.searchResult.count > 0 {
            Console.printXY(1,23,"PRESS 'SPACEBAR' TO SET MODE. PRESS ANY OTHER KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        else {
            Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        }
        
        Console.printXY(1,24,"\(self.searchResult.count.itsToString()) Songs",80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
      /// Returnes content line count
      ///
      func getSongsLineCount() -> Int {
          if PlayerPreferences.viewType == ViewType.Default {
              return g_windowContentLineCount
          }
          else {
              return g_windowContentLineCount / 2
          }
      }
      
      func getSongsContentLineCount() -> Int {
          if PlayerPreferences.viewType == ViewType.Default {
              return 1
          }
          else {
              return 2
          }
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
        Console.clearScreenCurrentTheme()
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_DOWN.rawValue, closure: { () -> Bool in
            if PlayerPreferences.viewType == ViewType.Details {
                if self.searchIndex < (self.searchResult.count - self.getSongsLineCount() - 1) {
                    self.searchIndex += 1
                    self.renderWindow()
                }
            }
            else if PlayerPreferences.viewType == ViewType.Default {
                if self.searchIndex < (self.searchResult.count - g_windowContentLineCount) {
                    self.searchIndex += 1
                    self.renderWindow()
                }
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_UP.rawValue, closure: { () -> Bool in
            if self.searchIndex >= 1 {
                self.searchIndex -= 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_LEFT.rawValue, closure: { () -> Bool in
            if PlayerPreferences.viewType == ViewType.Details {
                let m: Int = (g_windowContentLineCount)/self.getSongsContentLineCount()
                
                if (self.searchIndex - m) >= 0 {
                    self.searchIndex -= m
                    self.renderWindow()
                }
                else {
                    self.searchIndex = 0
                    self.renderWindow()
                }
            }
            else if PlayerPreferences.viewType == ViewType.Default {
                let m: Int = (g_windowContentLineCount)/self.getSongsContentLineCount()
                
                if (self.searchIndex - m) >= 0 {
                    self.searchIndex -= m
                    self.renderWindow()
                }
                else {
                    self.searchIndex = 0
                    self.renderWindow()
                }
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_RIGHT.rawValue, closure: { () -> Bool in
            if PlayerPreferences.viewType == ViewType.Details {
                let m: Int = (g_windowContentLineCount)/self.getSongsContentLineCount()
                
                if (self.searchIndex + m) >= (self.searchResult.count - self.getSongsLineCount() - 1) {
                    self.searchIndex = self.searchResult.count - self.getSongsLineCount() - 1
                    if self.searchIndex < 0 {
                        self.searchIndex = 0
                    }
                    self.renderWindow()
                }
                else {
                    self.searchIndex += m + 1
                    self.renderWindow()
                }
            }
            else if PlayerPreferences.viewType == ViewType.Default {
                if (self.searchIndex + g_windowContentLineCount) >= (self.searchResult.count - g_windowContentLineCount) {
                    self.searchIndex = self.searchResult.count - g_windowContentLineCount
                    if self.searchIndex < 0 {
                        self.searchIndex = 0
                    }
                    self.renderWindow()
                }
                else {
                    self.searchIndex += g_windowContentLineCount
                    self.renderWindow()
                }
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_SPACEBAR.rawValue, closure: { () -> Bool in
            if self.searchResult.count > 0 {
                
                if self.modeOff {
                    g_lock.lock()
                    g_searchType.removeAll()
                    g_searchResult.removeAll()
                    g_modeSearch.removeAll()
                    g_modeSearchStats.removeAll()
                    g_lock.unlock()
                }
                
                if  self.type == SearchType.ArtistOrTitle ||
                    self.type == SearchType.Artist ||
                    self.type == SearchType.Title ||
                    self.type == SearchType.Album
                {
                    g_modeSearch.append(self.parts)
                }
                else if self.type == SearchType.Genre {
                    g_modeSearch.append(self.parts)
                }
                else if self.type == SearchType.RecordedYear {
                    g_modeSearch.append(self.partsYear)
                }
            
                g_searchResult = self.searchResult
                g_modeSearchStats.append(self.stats)
                g_searchType.append(self.type)
            }
            return true
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: UInt32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// SearchWindow
