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
        self.infoText.append("title")
        self.infoText.append(" :: \(song.title)")
        self.infoText.append("duration")
        self.infoText.append(" :: \(itsRenderMsToFullString(song.duration, false))")
        self.infoText.append("recording year")
        self.infoText.append(" :: \(song.recodingYear)")
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderInfo() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### SONG INFORMATION ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
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
            
            if index_search % 2 == 0 {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
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
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow