//
//  ErrorWindow.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 21/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import
//
import Foundation

internal class ErrorWindow {
    
    ///
    /// Shows this ErrorWindow on screen.
    ///
    /// parameter message: The message to show in error.
    ///
    func showWindow(message: String) -> Void {
        self.renderErrorMessage(message: message)
    }
    
    ///
    /// Renders error message on screen. Waits for user to press Enter key to continue.
    ///
    /// parameter message: The message to show in error.
    ///
    func renderErrorMessage(message: String) -> Void {
        Console.clearScreen()
        Console.printXY(1, 1, "CMPlayer Error", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1, 3, message, 800, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        print("")
        print("")
        print(Console.applyTextColor(colorBg: ConsoleColor.black, modifierBg: ConsoleColorModifier.none, colorText: ConsoleColor.white, modifierText: ConsoleColorModifier.bold, text: "> Press ENTER Key To Continue <"))
        
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: 10, closure: { () -> Bool in
            return true
        })
        keyHandler.run()
    }// renderErrorMessage
}// ErrorWindow
