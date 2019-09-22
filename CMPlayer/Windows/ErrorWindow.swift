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
    func showWindow(message: String) -> Void {
        self.renderErrorMessage(message: message)
    }
    
    ///
    /// Renders error message on screen. Waits for user to press Enter key to continue.
    ///
    func renderErrorMessage(message: String) -> Void {
        Console.clearScreen()
        Console.printXY(1, 1, "Console Music Player :: Error", 80, .center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        Console.printXY(1, 3, message, 800, .ignore, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.red, ConsoleColorModifier.bold)
        print("")
        print("")
        print(Console.applyTextColor(colorBg: ConsoleColor.black, modifierBg: ConsoleColorModifier.none, colorText: ConsoleColor.white, modifierText: ConsoleColorModifier.bold, text: "> Press ENTER Key To Continue <"))
        _ = readLine()
    }// renderErrorMessage
}// ErrorWindow
