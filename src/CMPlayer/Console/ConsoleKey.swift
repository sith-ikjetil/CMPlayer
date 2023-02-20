//
//  ConsoleKey.swift
//  CMPlayer
//
//  Created by Kjetil Kr Solberg on 07/10/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation

//
// Console Keys
//
internal enum ConsoleKey : UInt32 {
    case KEY_BACKSPACE = 127
    case KEY_ENTER = 10
    case KEY_UP1 = 65
    case KEY_UP2 = 365
    case KEY_DOWN1 = 66
    case KEY_DOWN2 = 366
    case KEY_RIGHT1 = 67
    case KEY_RIGHT2 = 367
    case KEY_LEFT1 = 68
    case KEY_LEFT2 = 368
    case KEY_HTAB = 9
    case KEY_SHIFT_HTAB = 390
    case KEY_SPACEBAR = 32
    case KEY_EOF = 0
}
