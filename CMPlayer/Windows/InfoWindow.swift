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
internal class InfoWindow {
    //
    // Private properties/constants
    //
    private var infoIndex: Int = 0
    private var infoText: [String] = []
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    /// parameter song: Instance of SongEntry to render info.
    ///
    func showWindow(song: SongEntry) -> Void {
        self.infoIndex = 0
        self.updateInfoText(song: song)
        self.renderInfo()
        self.run()
    }
    
    ///
    /// Updates information to be rendered on screen
    ///
    /// parameter song: Instance of SongEntry to render info.
    ///
    func updateInfoText(song: SongEntry) -> Void {
        self.infoText.append("song no.")
        self.infoText.append(" :: \(song.songNo)")
        self.infoText.append("artist")
        self.infoText.append(" :: \(song.artist)")
        self.infoText.append("album")
        self.infoText.append(" :: \(song.albumName)")
        self.infoText.append("track no.")
        self.infoText.append(" :: \(song.trackNo)")
        self.infoText.append("title")
        self.infoText.append(" :: \(song.title)")
        self.infoText.append("duration")
        self.infoText.append(" :: \(itsRenderMsToFullString(song.duration, false))")
        self.infoText.append("recording year")
        self.infoText.append(" :: \(song.recodingYear)")
        self.infoText.append("genre")
        self.infoText.append(" :: \(song.genre)")
        self.infoText.append("filename")
        self.infoText.append(" :: \(song.fileURL?.lastPathComponent ?? "")")
        
        let p = song.fileURL?.path ?? ""
        if p.count > 0 {
            let fparts = song.fileURL?.pathComponents ?? []
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
    func renderInfo() -> Void {
        Console.clearScreenCurrentTheme()
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeColor()
        Console.printXY(1,3,"### SONG INFORMATION ###", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
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
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.infoIndex = 0
        self.renderInfo()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.infoIndex + 17) < self.infoText.count {
                self.infoIndex += 1
                self.renderInfo()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.infoIndex > 0 {
                self.infoIndex -= 1
                self.renderInfo()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            if self.infoIndex > 0 && self.infoText.count > g_windowContentLineCount{
                if self.infoIndex - g_windowContentLineCount > 0 {
                    self.infoIndex -= g_windowContentLineCount
                }
                else {
                    self.infoIndex = 0
                }
                self.renderInfo()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            if self.infoIndex >= 0 && self.infoText.count > g_windowContentLineCount {
                if self.infoIndex + g_windowContentLineCount < self.infoText.count - g_windowContentLineCount {
                    self.infoIndex += g_windowContentLineCount
                }
                else {
                    self.infoIndex = self.infoText.count - g_windowContentLineCount
                }
                self.renderInfo()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
