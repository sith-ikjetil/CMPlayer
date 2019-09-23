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
internal class HelpWindow {
    //
    // Private properties/constants
    //
    private var helpIndex: Int = 0
    private let helpText: [String] = [" exit, quit", " :: exits application",
                                      " next, skip", " :: plays next song",
                                      " play, pause, resume", " :: plays, pauses or resumes playback",
                                      " search [<words>]", " :: searches artist and title for a match. case insensitive",
                                      " help"," :: shows this help information",
                                      " pref, prefs, preferences", " :: shows preferences information",
                                      " about"," :: show the about information",
                                      " repaint", " :: clears and repaints entire console window",
                                      " set mrp <path>", " :: sets the path to the root folder where the music resides",
                                      " set cft <seconds>", " :: sets the crossfade time in seconds (1-10 seconds)",
                                      " set mf <formats>", " :: sets the supported music formats (separated by ;)",
                                      " enable crossfade"," :: enables crossfade",
                                      " disable crossfade", " :: disables crossfade",
                                      " enable aos", " :: enables playing on application startup",
                                      " disable aos", " :: disables playing on application startup",
                                      " rebuild songno"," :: rebuilds song numbers",
                                      " goto <mm:ss>", " :: moves playback point to minutes (mm) and seconds (ss) of current song"]
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    func showWindow() -> Void {
        self.helpIndex = 0
        self.renderHelp()
        self.run()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderHelp() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### HELP ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = helpIndex
        let max = helpIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > helpText.count - 1 {
                break
            }
            
            let se = helpText[index_search]
            
            if index_search % 2 == 0 {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT HELP.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.helpIndex = 0
        self.renderHelp()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: 66, closure: { () -> Bool in
            if (self.helpIndex + 17) < self.helpText.count {
                self.helpIndex += 1
                self.renderHelp()
            }
            return false
        })
        keyHandler.addKeyHandler(key: 65, closure: { () -> Bool in
            if self.helpIndex > 0 {
                self.helpIndex -= 1
                self.renderHelp()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
