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
internal class InitialSetupWindow {
    ///
    /// Private properties/constants.
    ///
    private let setupTextRootPath: String = "There seems to be a problem finding the 2+ songs needed"
    private let setupTextPleaseEnterPath: String = "Please enter a new path to root directory of music"

    ///
    /// Shows this InitialSetupWindow on screen.
    ///
    func showWindow() -> Bool {
        self.renderInitialSetup(path: "")
        return self.run()
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderInitialSetup(path: String) -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### SETUP ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1,5, setupTextRootPath, 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1,7, setupTextPleaseEnterPath, 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1,9, ":> \(path)", 3+path.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
        
        //Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT HELP.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs InitialSetupWindow keyboard input and feedback.
    ///
    ///  returns: Bool. True if path entered, false otherwise.
    ///
    func run() -> Bool {
        var path: String = ""
        var retVal: Bool = false
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: 127, closure: { () -> Bool in
            if path.count > 0 {
                path.removeLast()
                self.renderInitialSetup(path: path)
            }
            return false
        })
        keyHandler.addKeyHandler(key: 10, closure: { () -> Bool in
            if path.count > 0 {
                PlayerPreferences.musicRootPath = path
                retVal = true
                return true
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            if key != EOF
               && key != 10
               && key != 127
               && key != 27
            {
                path.append(String(UnicodeScalar(UInt32(key))!))
                self.renderInitialSetup(path: path)
            }
            return false
        })
        keyHandler.run()
        
        return retVal
    }// run
}// InitialSetupWindow
