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
internal class ModeWindow {
    ///
    /// Private properties/constants.
    ///
    private var modeIndex: Int = 0
    private var modeText: [String] = []
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.modeIndex = 0
        self.updateModeText()
        self.renderMode()
        self.run()
    }
    
    ///
    /// Updates the genere text array. Called before visual showing.
    ///
    func updateModeText() -> Void
    {
        self.modeText.removeAll()
      
        self.modeText.append("genre")
        if g_modeGenre.count == 0 {
            self.modeText.append(" :: ")
        }
        for g in g_modeGenre {
            self.modeText.append(" :: \(g), \(g_genres[g]!.count) Songs")
        }
        
        self.modeText.append("artist")
        if g_modeArtist.count == 0 {
            self.modeText.append(" :: ")
        }
        for a in g_modeArtist {
            self.modeText.append(" :: \(a), \(g_artists[a]!.count) Songs")
        }
        
        self.modeText.append("year")
        if g_modeRecordingYears.count == 0 {
            self.modeText.append(" :: ")
        }
        for y in g_modeRecordingYears {
            self.modeText.append(" :: \(y), \(g_recordingYears[y]!.count) Songs")
        }
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderMode() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### MODE ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var bMode: Bool = false;
        if g_modeRecordingYears.count > 0 || g_modeGenre.count > 0 || g_modeArtist.count > 0 {
            bMode = true
        }
        Console.printXY(1,4,"mode is: \((!bMode) ? "off" : "on")", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = modeIndex
        let max = modeIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > modeText.count - 1 {
                break
            }
            
            let se = modeText[index_search]
            
            if !se.hasPrefix(" ::") {
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
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.modeIndex = 0
        self.renderMode()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.modeIndex + 17) < self.modeText.count {
                self.modeIndex += 1
                self.renderMode()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.modeIndex > 0 {
                self.modeIndex -= 1
                self.renderMode()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
