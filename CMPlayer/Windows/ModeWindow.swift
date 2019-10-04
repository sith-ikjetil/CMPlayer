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
/// Represents CMPlayer ModeWindow.
///
internal class ModeWindow {
    ///
    /// Private properties/constants.
    ///
    private var modeIndex: Int = 0
    private var modeText: [String] = []
    private var inMode: Bool = false
    
    ///
    /// Shows this AboutWindow on screen.
    ///
    func showWindow() -> Void {
        self.modeIndex = 0
        self.updateModeText()
        self.renderMode()
        self.run()
    }
    
    ///
    /// Updates the genere text array. Called before visual showing.
    ///
    func updateModeText() -> Void
    {
        self.modeText.removeAll()
        
        self.modeText.append("\(g_searchType.rawValue)")
        if g_modeSearch.count == 0 || g_modeSearch.count != g_modeSearchStats.count {
            self.modeText.append(" :: ")
        }
        else {
            var index: Int = 0
            for y in g_modeSearch {
                self.inMode = true
                self.modeText.append(" :: \(y), \(g_modeSearchStats[index]) Songs")
                index += 1
            }
        }
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderMode() -> Void {
        Console.clearScreenCurrentTheme()
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeBgColor()
        Console.printXY(1,3,"### MODE ###", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        Console.printXY(1,4,"mode is: \((!self.inMode) ? "off" : "on")", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = modeIndex
        let max = modeIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > modeText.count - 1 {
                break
            }
            
            let se = modeText[index_search]
            
            if !se.hasPrefix(" ::") {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs AboutWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.modeIndex = 0
        self.renderMode()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: Console.KEY_DOWN, closure: { () -> Bool in
            if (self.modeIndex + 17) < self.modeText.count {
                self.modeIndex += 1
                self.renderMode()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_UP, closure: { () -> Bool in
            if self.modeIndex > 0 {
                self.modeIndex -= 1
                self.renderMode()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_LEFT, closure: { () -> Bool in
            if self.modeIndex > 0 && self.modeText.count > g_windowContentLineCount{
                if self.modeIndex - g_windowContentLineCount > 0 {
                    self.modeIndex -= g_windowContentLineCount
                }
                else {
                    self.modeIndex = 0
                }
                self.renderMode()
            }
            return false
        })
        keyHandler.addKeyHandler(key: Console.KEY_RIGHT, closure: { () -> Bool in
            if self.modeIndex >= 0 && self.modeText.count > g_windowContentLineCount {
                if self.modeIndex + g_windowContentLineCount < self.modeText.count - g_windowContentLineCount {
                    self.modeIndex += g_windowContentLineCount
                }
                else {
                    self.modeIndex = self.modeText.count - g_windowContentLineCount
                }
                self.renderMode()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// AboutWindow
