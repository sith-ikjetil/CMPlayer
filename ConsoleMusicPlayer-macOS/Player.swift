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
    private var playtime1: Int64 = 0
    private var playtime2: Int64 = 0
    private var quit: Bool = false
    private var exitCode: Int32 = 0
    
    func initialize() -> Void {
        self.clearScreen()
    }
    
    func run() -> Int32 {
        repeat {
            renderScreen()
        } while !quit
        
        return exitCode
    }
    
    func clearScreen() -> Void {
        print("\u{001B}[2J")
    }
    
    func printXY(_ x: Int32,_ y: Int32,_ text: String,_ maxLength: Int,_ padding: PrintPadding,_ paddingChar: Character, _ bgColor: ConsoleColor, _ modifierBg: ConsoleColorModifier, _ colorText: ConsoleColor,_ modifierText: ConsoleColorModifier) -> Void {
        let nmsg = text.convertStringToLengthPaddedString(maxLength, padding, paddingChar)
        print("\u{001B}[(\(y);\(x))H\(Console.applyTextColor(colorBg: bgColor, modifierBg: modifierBg, colorText: colorText, modifierText: modifierText, text: nmsg))")
    }
    
    func renderScreen() {
        renderFrame()
        
        
        //printXY(10,1,"12345", 10, .Right, "0", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        //printXY(20,3,"12345", 10, .Right, "0", ConsoleColor.white, ConsoleColorModifier.none, ConsoleColor.magenta, ConsoleColorModifier.bold)
    }
    
    func renderFrame() {
        printXY(1,1,"Console Music Player v0.1", 80, .Center, " ", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        printXY(10,22,"12345", 10, .Right, "0", ConsoleColor.blue, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
    }
}
