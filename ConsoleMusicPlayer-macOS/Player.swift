//
//  Player.swift
//  test
//
//  Created by Kjetil Kr Solberg on 17/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation
// Color codes
// black   30
// red     31
// green   32
// yellow  33
// blue    34
// magenta 35
// cyan    36
// white   37
class Player {
    
    func initialize() -> Void {
        self.clearScreen()
        self.renderScreen()
    }
    
    func run() -> Int32 {
        renderScreen()
        readLine()
        return 0
    }
    
    func clearScreen() -> Void {
        print("\u{001B}[2J")
    }
    
    func printXY(_ x: Int32,_ y: Int32,_ msg: String,_ maxLength: Int,_ padding: PrintPadding,_ paddingChar: Character, _ bgColor: ConsoleColor, _ modifierBg: ConsoleColorModifier, _ colorText: ConsoleColor,_ modifierText: ConsoleColorModifier) -> Void {
        let nmsg = msg.convertStringToLengthPaddedString(maxLength, padding, paddingChar)
        print("\u{001B}[(\(y);\(x))H\(Console.applyTextColor(colorBg: bgColor, modifierBg: modifierBg, colorText: colorText, modifierText: modifierText, text: nmsg))")
    }
    
    func renderScreen() {
        printXY(10,1,"12345", 10, .Right, "0", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        printXY(20,3,"12345", 10, .Right, "0", ConsoleColor.white, ConsoleColorModifier.none, ConsoleColor.magenta, ConsoleColorModifier.bold)
    }
}
