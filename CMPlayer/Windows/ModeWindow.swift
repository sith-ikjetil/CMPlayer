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
/// Represents CMPlayer ModeWindow.
///
internal class ModeWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    ///
    /// Private properties/constants.
    ///
    //private var modeIndex: Int = 0
    private var modeText: [String] = []
    private var inMode: Bool = false
    private var searchResult: [SongEntry] = g_searchResult
    private var searchIndex: Int = 0
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.searchIndex = 0
        self.updateModeText()
        
        g_tscpStack.append(self)
        
        self.renderWindow()
        self.run()
        
        g_tscpStack.removeLast()
    }
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        self.renderWindow()
    }
    
    ///
    /// Updates the genere text array. Called before visual showing.
    ///
    func updateModeText() -> Void
    {
        self.modeText.removeAll()
        
        guard g_modeSearch.count == g_modeSearchStats.count else {
            return
        }
        
        if g_searchType.count > 0 {
            self.inMode = true
        }
        
        var i: Int = 0
        for type in g_searchType {
            self.modeText.append("\(type.rawValue)")
            for j in 0..<g_modeSearch[i].count {
                self.modeText.append(" :: \(g_modeSearch[i][j]), \(g_modeSearchStats[i][j]) Songs")
            }
            i += 1
        }
        
        self.modeText.append(" ");
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
        let songNoColor = ConsoleColor.cyan
        
        Console.printXY(1,3,":: MODE ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4,"mode is: \((!self.inMode) ? "off" : "on")", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        if PlayerPreferences.viewType == ViewType.Default {
            var index_screen_lines: Int = 5
            var index_search: Int = searchIndex
            let max = searchIndex + 21
            while index_search < max {
                if index_screen_lines == 22 {
                    break
                }
                
                if index_search > ((self.modeText.count + self.searchResult.count) - 1) {
                    break
                }
                
                if index_search < self.modeText.count {
                    let mt = self.modeText[index_search]
                    
                    if mt.hasPrefix(" ::") {
                        Console.printXY(1, index_screen_lines, mt, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                    }
                    else {
                        Console.printXY(1, index_screen_lines, mt, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
                    }
                }
                else {
                    let se = self.searchResult[index_search-self.modeText.count]
                
                    Console.printXY(1, index_screen_lines, "\(se.songNo) ", g_fieldWidthSongNo+1, .right, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
                
                    Console.printXY(10, index_screen_lines, "\(se.artist)", g_fieldWidthArtist, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)

                    Console.printXY(43, index_screen_lines, "\(se.title)", g_fieldWidthTitle, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                
                    Console.printXY(76, index_screen_lines, itsRenderMsToFullString(se.duration, false), g_fieldWidthDuration, .ignore, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                }
                index_screen_lines += 1
                index_search += 1
            }
        }
        else if PlayerPreferences.viewType == ViewType.Details {
            var index_screen_lines: Int = 5
            var index_search: Int = searchIndex
            let max = searchIndex + g_windowContentLineCount
            while index_search < max {
                if index_screen_lines >= 22 {
                    break
                }
                
                if index_search > ((self.modeText.count + self.searchResult.count) - 1) {
                    break
                }
                
                if index_search < self.modeText.count {
                    let mt = self.modeText[index_search]
                    
                    if mt.hasPrefix(" ::") {
                        Console.printXY(1, index_screen_lines, mt, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
                    }
                    else {
                        Console.printXY(1, index_screen_lines, mt, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
                    }
                    
                    index_screen_lines += 1
                    index_search += 1
                }
                else {
                    let song = self.searchResult[index_search-self.modeText.count]
                
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
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1,24,"\(g_searchResult.count.itsToString()) Songs", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Returns content line count
    ///
    func getSongsLineCount() -> Int {
        if PlayerPreferences.viewType == ViewType.Default {
            return g_windowContentLineCount
        }
        else {
            return g_windowContentLineCount / 2
        }
    }
    
    ///
    /// Returns song content line count
    ///
    func getSongsContentLineCount() -> Int {
        if PlayerPreferences.viewType == ViewType.Default {
            return 1
        }
        else {
            return 2
        }
    }

    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        
        self.searchIndex = 0
        //self.modeIndex = 0
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_DOWN.rawValue, closure: { () -> Bool in
            if PlayerPreferences.viewType == ViewType.Details {
                if self.searchIndex < ((self.modeText.count + self.searchResult.count) - self.getSongsLineCount() - 1) {
                    self.searchIndex += 1
                    self.renderWindow()
                }
            }
            else if PlayerPreferences.viewType == ViewType.Default {
                if self.searchIndex < ((self.modeText.count + self.searchResult.count) - g_windowContentLineCount) {
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
                var n: Int = (self.modeText.count - 1) - self.searchIndex
                if n < 0 {
                    n = 0
                }
                else if n > g_windowContentLineCount {
                    n = g_windowContentLineCount
                }
                let m: Int = n + (g_windowContentLineCount - n)/self.getSongsContentLineCount()
                
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
                var n: Int = (self.modeText.count - 1) - self.searchIndex
                if n < 0 {
                    n = 0
                }
                else if n > g_windowContentLineCount {
                    n = g_windowContentLineCount
                }
                let m: Int = n + (g_windowContentLineCount - n)/self.getSongsContentLineCount()
                
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
                var n: Int = self.modeText.count - self.searchIndex
                if n < 0 {
                    n = 0
                }
                else if n > g_windowContentLineCount {
                    n = g_windowContentLineCount
                }
                let m: Int = n + (g_windowContentLineCount - n)/self.getSongsContentLineCount()
                
                if (self.searchIndex + m) >= ((self.modeText.count+self.searchResult.count) - self.getSongsLineCount() - 1) {
                    self.searchIndex = (self.modeText.count+self.searchResult.count) - self.getSongsLineCount() - 1
                    self.renderWindow()
                }
                else {
                    self.searchIndex += m + ((n==0) ? 1 : 0)
                    self.renderWindow()
                }
            }
            else if PlayerPreferences.viewType == ViewType.Default {
                if (self.searchIndex + g_windowContentLineCount) >= ((self.modeText.count+self.searchResult.count) - g_windowContentLineCount) {
                    self.searchIndex = (self.modeText.count+self.searchResult.count) - g_windowContentLineCount
                    self.renderWindow()
                }
                else {
                    self.searchIndex += g_windowContentLineCount
                    self.renderWindow()
                }
            }
        
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: UInt32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
