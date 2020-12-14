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
/// Represents CMPlayer HelpWindow.
///
internal class InfoWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/constants
    //
    private var infoIndex: Int = 0
    private var infoText: [String] = []
    var song: SongEntry?
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    /// parameter song: Instance of SongEntry to render info.
    ///
    func showWindow() -> Void {
        self.infoIndex = 0
        
        self.updateInfoText()
        
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
    /// Updates information to be rendered on screen
    ///
    /// parameter song: Instance of SongEntry to render info.
    ///
    func updateInfoText() -> Void {
        self.infoText.append("song no.")
        self.infoText.append(" :: \(self.song?.songNo ?? 0)")
        self.infoText.append("artist")
        self.infoText.append(" :: \(self.song?.fullArtist ?? "")")
        self.infoText.append("album")
        self.infoText.append(" :: \(self.song?.fullAlbumName ?? "")")
        self.infoText.append("track no.")
        self.infoText.append(" :: \(self.song?.trackNo ?? 0)")
        self.infoText.append("title")
        self.infoText.append(" :: \(self.song?.fullTitle ?? "")")
        self.infoText.append("duration")
        self.infoText.append(" :: \(itsRenderMsToFullString(self.song?.duration ?? 0, false))")
        self.infoText.append("recording year")
        self.infoText.append(" :: \(self.song?.recodingYear ?? 0)")
        self.infoText.append("genre")
        self.infoText.append(" :: \(self.song?.fullGenre ?? "")")
        self.infoText.append("filename")
        self.infoText.append(" :: \(self.song?.fileURL?.lastPathComponent ?? "")")
        
        let p = self.song?.fileURL?.path ?? ""
        if p.count > 0 {
            let fparts = self.song?.fileURL?.pathComponents ?? []
            var i: Int = 1
            var pathOnly: String = ""
            while i < fparts.count - 1 {
                pathOnly.append("/\(fparts[i])")
                i += 1
            }
            self.infoText.append("path")
            self.infoText.append(" :: \(pathOnly)")
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
        Console.printXY(1,3,":: SONG INFORMATION ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4," ", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = infoIndex
        let max = infoIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > infoText.count - 1 {
                break
            }
            
            let se = infoText[index_search]
            
            if !se.hasPrefix(" ::") {
                Console.printXY(1, index_screen_lines, se, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1,24," ", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        Console.clearScreenCurrentTheme()
        self.infoIndex = 0
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_DOWN.rawValue, closure: { () -> Bool in
            if (self.infoIndex + 17) < self.infoText.count {
                self.infoIndex += 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_UP.rawValue, closure: { () -> Bool in
            if self.infoIndex > 0 {
                self.infoIndex -= 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_LEFT.rawValue, closure: { () -> Bool in
            if self.infoIndex > 0 && self.infoText.count > g_windowContentLineCount{
                if self.infoIndex - g_windowContentLineCount > 0 {
                    self.infoIndex -= g_windowContentLineCount
                }
                else {
                    self.infoIndex = 0
                }
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_RIGHT.rawValue, closure: { () -> Bool in
            if self.infoIndex >= 0 && self.infoText.count > g_windowContentLineCount {
                if self.infoIndex + g_windowContentLineCount < self.infoText.count - g_windowContentLineCount {
                    self.infoIndex += g_windowContentLineCount
                }
                else {
                    self.infoIndex = self.infoText.count - g_windowContentLineCount
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
}// HelpWindow
