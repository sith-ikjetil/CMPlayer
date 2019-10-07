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

internal class ErrorWindow : TerminalSizeChangedProtocol, PlayerWindowProtocol {
    
    var message: String = ""
    
    ///
    /// Shows this ErrorWindow on screen.
    ///
    /// parameter message: The message to show in error.
    ///
    func showWindow() -> Void {
        g_tscpStack.append(self)
        self.renderWindow()
        self.run()
        g_tscpStack.removeLast()
    }
    
    //
    // TerminalSizeChangedProtocol implementation handler.
    //
    func terminalSizeHasChanged() {
        self.renderWindow()
    }
    
    //
    // Run method.
    //
    func run() -> Void {
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_ENTER.rawValue, closure: { () -> Bool in
            return true
        })
        keyHandler.run()
    }
    
    ///
    /// Renders error message on screen. Waits for user to press Enter key to continue.
    ///
    /// parameter message: The message to show in error.
    ///
    func renderWindow() -> Void {
        Console.clearScreen()
        
        Console.printXY(1, 1, "CMPlayer Error", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1, 3, self.message, 80*15, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.red, ConsoleColorModifier.bold)
        print("")
        print("")
        print(Console.applyTextColor(colorBg: ConsoleColor.black, modifierBg: ConsoleColorModifier.none, colorText: ConsoleColor.white, modifierText: ConsoleColorModifier.bold, text: "> Press ENTER Key To Continue <"))
        
        Console.gotoXY(80,1)
        print("")
    }// renderErrorMessage
}// ErrorWindow
