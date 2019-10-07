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
/// Represents CMPlayer InitialSetupWindow.
///
internal class SetupWindow : TerminalSizeChangedProtocol, PlayerWindowProtocol {
    ///
    /// Private properties/variables/constants.
    ///
    private let setupText: [String] = ["CMPlayer needs to have a path to search for music",
                                       "In CMPlayer you can have many root paths.",
                                       "In CMPlayer Use: add mrp <path> or: remove mrp <path> to add remove path.",
                                       "Please enter the path to the root directory of where your music resides."]
    //
    // Public propreties/variables/constants
    //
    var path: String = ""
    
    ///
    /// Shows this InitialSetupWindow on screen.
    ///
    func showWindow() -> Void {
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
    /// Renders screen output. Does clear screen first.
    ///
    /// parameter path: Path to render on screen.
    ///
    func renderWindow() -> Void {
        Console.clearScreen()
        
        if g_rows < 24 || g_cols < 80 {
            return
        }
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,":: SETUP ::", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var y: Int = 5
        for txt in self.setupText {
            Console.printXY(1, y, txt, 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            y += 1
        }
        
        Console.printXY(1,y+1, ":> \(self.path)", 3+path.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Runs InitialSetupWindow keyboard input and feedback.
    ///
    /// returns: Bool. True if path entered, false otherwise.
    ///
    func run() -> Void {
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_BACKSPACE.rawValue, closure: { () -> Bool in
            if self.path.count > 0 {
                self.path.removeLast()
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_ENTER.rawValue, closure: { () -> Bool in
            if self.path.count > 0 {
                PlayerPreferences.musicRootPath.append(self.path)
                PlayerPreferences.savePreferences()
                return true
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: UInt32) -> Bool in
            if key != EOF
               && key != 10
               && key != 127
               && key != 27
            {
                self.path.append(String(UnicodeScalar(UInt32(key))!))
                self.renderWindow()
            }
            return false
        })
        keyHandler.run()
    }// run
}// InitialSetupWindow
