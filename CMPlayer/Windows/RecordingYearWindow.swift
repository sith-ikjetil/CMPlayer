//
//  HelpWindow.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 20/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import
//
import Foundation

///
/// Represents CMPlayer AboutWindow.
///
internal class RecordingYearWindow {
    ///
    /// Private properties/constants.
    ///
    private var yearIndex: Int = 0
    private var yearText: [String] = []
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.yearIndex = 0
        self.updateRecordingYearsText()
        self.renderRecordingYears()
        self.run()
    }
    
    ///
    /// Updates the genere text array. Called before visual showing.
    ///
    func updateRecordingYearsText() -> Void
    {
        self.yearText.removeAll()
        
        for g in g_recordingYears {
            let name = String(g.key)
            let desc = " :: \(g.value.count) Songs"
            
            var hit = false
            for e in g_modeRecordingYears {
                if e == g.key {
                    hit = true
                    break;
                }
            }
            
            if hit {
                self.yearText.append("\(name) (*)")
            }
            else {
                self.yearText.append(name)
            }
            self.yearText.append(desc)
        }
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderRecordingYears() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### RECORDING YEARS ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4,"mode year is: \((g_modeRecordingYears.count == 0) ? "off" : "on")", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = yearIndex
        let max = yearIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > yearText.count - 1 {
                break
            }
            
            let se = yearText[index_search]
            
            if index_search % 2 == 0 {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,24,"Year Count: \(g_artists.count.itsToString())", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.yearIndex = 0
        self.renderRecordingYears()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.yearIndex + 17) < self.yearText.count {
                self.yearIndex += 1
                self.renderRecordingYears()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.yearIndex > 0 {
                self.yearIndex -= 1
                self.renderRecordingYears()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
