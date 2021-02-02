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
    case KEY_UP = 65 //365
    case KEY_DOWN = 66 //366
    case KEY_RIGHT = 67 //367
    case KEY_LEFT = 68 //368
    case KEY_HTAB = 9
    case KEY_SHIFT_HTAB = 390
    case KEY_SPACEBAR = 32
    case KEY_EOF = 0
}
