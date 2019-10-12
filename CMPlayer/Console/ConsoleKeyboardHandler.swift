//
//  ConsoleKeyboardHandler.swift
//  CMPlayer
//
//  Created by Kjetil Kr Solberg on 23/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation
import AppKit


///
/// Represents CMPlayer ConsoleKeyboardHandler
///
internal class ConsoleKeyboardHandler {
    //
    // Private properties/constants
    //
    private var keyHandlers: [UInt32 : () -> Bool] = [:]
    private var unknownKeyHandlers: [(UInt32) -> Bool] = []
    private var characterKeyHandlers: [(Character) -> Bool] = []
    
    //
    // Default initializer
    //
    init() {
        
    }
    
    ///
    /// Adds a closure keyboard handler for given key from getchar()
    ///
    /// parameter key: getchar() return value.
    /// parameter closure: A Keyboard handler for key pressed.
    ///
    /// returns: True if ConsoleKeyboardHandler should stop processing keys and return from run. False otherwise.
    ///
    func addKeyHandler(key: UInt32, closure: @escaping () -> Bool) {
        self.keyHandlers[key] = closure
    }
    
    ///
    /// Adds a closure keyboard handler for given key from getchar() that is not processed with addKeyHandler handler.
    ///
    /// parameter closure: A Closure for handling key pressed.
    ///
    /// returns: True is ConsoleKeyboardHandler should stop processing keys and return from run. False otherwise.
    ///
    func addUnknownKeyHandler(closure: @escaping (UInt32) -> Bool) {
        self.unknownKeyHandlers.append(closure)
    }
    
    ///
    /// Adds a closure keyboard handler for given input character.
    ///
    /// parameter closure: A Closure for handling key pressed.
    ///
    /// returns: True is ConsoleKeyboardHandler should stop processing keys and return from run. False otherwise.
    ///
    func addCharacterKeyHandler(closure: @escaping (Character) -> Bool) {
        self.characterKeyHandlers.append(closure)
    }
    
    ///
    /// Runs keyboard processing using getchar(). Calls key event handlers .
    ///
    func run() {
        var b27: Bool = false
        var b91: Bool = false
        var doRun: Bool = true
        while doRun {
            let inputData = FileHandle.standardInput.availableData
            if inputData.count > 0 {
                let tmp = String(data: inputData, encoding: .utf8)
                
                if let inputString = tmp {
                    
                    for c in inputString.unicodeScalars {
                        
                        if !b91 && !b27 && c.value == 27 {
                            b27 = true
                            continue
                        }
                        else if b27 && c.value == 91 {
                            b91 = true
                            continue
                        }
                        
                        var key = c.value
                        if b91 {
                            b27 = false
                            b91 = false
                            key += 300 // WE HAVE ARROW KEYS
                        }
                        else {
                            let ch: Character = Character(c)
                            if (ch.isLetter || ch.isNumber || ch.isWhitespace || ch.isPunctuation || ch.isMathSymbol) && !ch.isNewline {
                                for handler in self.characterKeyHandlers {
                                    if handler(ch) {
                                        doRun = false
                                        break;
                                    }
                                }
                            }
                        }
                        
                        if processKey(key: key) {
                            doRun = false
                            break;
                        }
                    }
                }
            }
        }
    }
    
    ///
    /// Processes a keystroke from getchar()
    ///
    /// parameter key: Value from getchar()
    ///
    /// returns: True if eventhandler processed the keystroke and eventhandler returned true. False if no eventhandler processed the key. Also false if eventhandler returned false.
    ///
    func processKey(key: UInt32) -> Bool {
        var hit: Bool = false
        for kh in self.keyHandlers {
            if kh.key == key {
                hit = true
                if kh.value() {
                    return true
                }
            }
        }
        
        if !hit {
            for handler in self.unknownKeyHandlers {
                if handler(key) {
                    return true
                }
            }
        }
        
        return false
    }// processKey
}// ConsoleKeyboardHandler
