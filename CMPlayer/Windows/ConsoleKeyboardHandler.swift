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

///
/// Represents CMPlayer ConsoleKeyboardHandler
///
internal class ConsoleKeyboardHandler {
    //
    // Private properties/constants
    //
    private var keyHandlers: [Int32 : () -> Bool] = [:]
    private var unknownKeyHandlers: [(Int32) -> Bool] = []
    
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
    func addKeyHandler(key: Int32, closure: @escaping () -> Bool) {
        self.keyHandlers[key] = closure
    }
    
    ///
    /// Adds a closure keyboard handler for given key from getchar() that is not processed with addKeyHandler handler.
    ///
    /// parameter closure: A Closure for handling key pressed.
    ///
    /// returns: True is ConsoleKeyboardHandler should stop processing keys and return from run. False otherwise.
    ///
    func addUnknownKeyHandler(closure: @escaping (Int32) -> Bool) {
        self.unknownKeyHandlers.append(closure)
    }
    
    ///
    /// Runs keyboard processing using getchar(). Calls key event handlers .
    ///
    func run() {
        var ch: Int32 = getchar()
        while true {
            if ch == 27 {
                ch = getchar()
                ch = getchar()
                
                ch += 300   // ARROWS, ADD NUMERIC BASE FOR ARROWS TO DISTINGUISH FROM A og B etc.
            }
            
            if processKey(key: ch) {
                break
            }
            
            ch = getchar()
        }
    }
    
    ///
    /// Processes a keystroke from getchar()
    ///
    /// parameter key: Value from getchar()
    ///
    /// returns: True if eventhandler processed the keystroke and eventhandler returned true. False if no eventhandler processed the key. Also false if eventhandler returned false.
    ///
    func processKey(key: Int32) -> Bool {
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
