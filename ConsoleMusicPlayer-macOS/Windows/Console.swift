//
//  Console.swift
//  test
//
//  Created by Kjetil Kr Solberg on 18/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

enum ConsoleColor : Int {
    case black = 0
    case red = 1
    case green = 2
    case yellow = 3
    case blue = 4
    case magenta = 5
    case cyan = 6
    case white = 7
}

enum ConsoleColorModifier : Int {
    case none = 0
    case bold = 1
    //case dim = 2
    //case italic = 3
    //case underline = 4
    //case blink = 5
    //case inverse = 7
    //case hidden = 8
    //case strikethrough = 9
}

internal class Console {
    
    static func clearScreen() -> Void {
        print(applyTextColor(colorBg: ConsoleColor.black, modifierBg: ConsoleColorModifier.none, colorText: ConsoleColor.white , modifierText: ConsoleColorModifier.none , text: " "))
        print("\u{001B}[2J")
    }
    
    static func hideCursor() -> Void {
        print("\u{001B}[?25l")
    }
    
    static func showCursor() -> Void {
        print("\u{001B}[?25h")
    }
    
    static func echoOff() -> Void {
        let c: cc_t = 0
        let cct = (c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c, c)
        var oldt: termios = termios(c_iflag: 0, c_oflag: 0, c_cflag: 0, c_lflag: 0, c_cc: cct, c_ispeed: 0, c_ospeed: 0)
        
        tcgetattr(STDIN_FILENO, &oldt) // 1473
        var newt = oldt
        
        newt.c_lflag = newt.c_lflag & ~UInt(ECHO) //1217  // Reset ICANON and Echo off
        newt.c_lflag = newt.c_lflag & ~UInt(ICANON) //1217  // Reset ICANON and Echo off
        tcsetattr( STDIN_FILENO, TCSANOW, &newt)
    }
    
    static func applyTextColor(colorBg: ConsoleColor, modifierBg:  ConsoleColorModifier, colorText: ConsoleColor, modifierText: ConsoleColorModifier, text: String) -> String {
        
        var addToText = 30
        var addToBg = 40
        if modifierText == ConsoleColorModifier.bold {
            addToText = 90
        }
        else {
            addToText = addToText + modifierText.rawValue
        }
        
        if modifierBg == ConsoleColorModifier.bold {
            addToBg = 100
        }
        else {
            addToBg = addToBg + modifierBg.rawValue
        }
        
        return "\u{001B}[\(colorText.rawValue+addToText)m\u{001B}[\(colorBg.rawValue+addToBg)m\(text)"
    }
    
    static func gotoXY(_ x: Int, _ y: Int)
    {
        print("\u{001B}[(\(y);\(x))H", terminator: "")
    }
    
    static func printXY(_ x: Int,_ y: Int,_ text: String,_ maxLength: Int,_ padding: PrintPaddingTextAlign,_ paddingChar: Character, _ bgColor: ConsoleColor, _ modifierBg: ConsoleColorModifier, _ colorText: ConsoleColor,_ modifierText: ConsoleColorModifier) -> Void {
        let nmsg = text.convertStringToLengthPaddedString(maxLength, padding, paddingChar)
        print("\u{001B}[(\(y);\(x))H\(Console.applyTextColor(colorBg: bgColor, modifierBg: modifierBg, colorText: colorText, modifierText: modifierText, text: nmsg))", terminator: "")
    }
    
    static private let concurrentQueue1 = DispatchQueue(label: "cqueue.console.music.player.macos.1.console", attributes: .concurrent)
    static private let sigintSrc = DispatchSource.makeSignalSource(signal: Int32(SIGWINCH), queue: Console.concurrentQueue1)
    static func initialize() -> Void {
        sigintSrc.setEventHandler {
            //var w = winsize()
            //if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            //    if w.ws_row != 24 || w.ws_col != 80 {
            //        w.ws_row = 24
            //        w.ws_col = 80
            //        _ = ioctl(STDOUT_FILENO, TIOCSWINSZ, &w)
            //    }
            //}
            Console.clearScreen()
            g_player.renderScreen()
        }
        sigintSrc.resume()
    }
}
