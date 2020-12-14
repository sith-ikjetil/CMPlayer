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
/// Represents CMPlayer PreferencesWindow.
///
internal class PreferencesWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/constants
    //
    private var preferencesIndex: Int = 0
    private var preferencesText: [String] = []
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    func showWindow() -> Void {
        self.preferencesIndex = 0
        
        self.updatePreferencesText()
        
        g_tscpStack.append(self)
        Console.clearScreenCurrentTheme()
        self.renderWindow()
        self.run()
        
        g_tscpStack.removeLast()
    }
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        Console.clearScreenCurrentTheme()
        self.renderWindow()
    }
    
    ///
    /// Updates the preferences text based on running values.
    ///
    func updatePreferencesText() {
        self.preferencesText.removeAll()
        
        self.preferencesText.append(" Music Root Paths")
        if PlayerPreferences.musicRootPath.count == 0 {
            self.preferencesText.append(" :: ")
        }
        else {
            for path in PlayerPreferences.musicRootPath
            {
                self.preferencesText.append(" :: \(path)")
            }
        }
        
        self.preferencesText.append(" Exclusion Paths")
        if PlayerPreferences.exclusionPaths.count == 0 {
            self.preferencesText.append(" :: ")
        }
        else {
            for path in PlayerPreferences.exclusionPaths
            {
                self.preferencesText.append(" :: \(path)")
            }
        }
        
        self.preferencesText.append(" Music Formats")
        self.preferencesText.append(" :: \(PlayerPreferences.musicFormats)")
        self.preferencesText.append(" Enable Autoplay On Startup")
        self.preferencesText.append(" :: \(PlayerPreferences.autoplayOnStartup)")
        self.preferencesText.append(" Enable Crossfade")
        self.preferencesText.append(" :: \(PlayerPreferences.crossfadeSongs)")
        self.preferencesText.append(" Crossfade Time")
        self.preferencesText.append(" :: \(PlayerPreferences.crossfadeTimeInSeconds) seconds")
        self.preferencesText.append(" View Type")
        self.preferencesText.append(" :: \(PlayerPreferences.viewType.rawValue)")
        self.preferencesText.append(" Theme")
        self.preferencesText.append(" :: \(PlayerPreferences.colorTheme.rawValue)")
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderWindow() -> Void {
        if g_rows < 24 || g_cols < 80 {
            return
        }
        
        MainWindow.renderHeader(showTime: false)
        
        let bgColor = getThemeBgColor()
        Console.printXY(1,3,":: PREFERENCES ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = preferencesIndex
        let max = preferencesIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > preferencesText.count - 1 {
                break
            }
            
            let se = preferencesText[index_search]
            
            if se.hasPrefix(" ::") {
                Console.printXY(1, index_screen_lines, se, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        Console.clearScreenCurrentTheme()
        self.preferencesIndex = 0
        self.renderWindow()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_DOWN.rawValue, closure: { () -> Bool in
            if (self.preferencesIndex + 17) < self.preferencesText.count {
                self.preferencesIndex += 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_UP.rawValue, closure: { () -> Bool in
            if self.preferencesIndex > 0 {
                self.preferencesIndex -= 1
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_LEFT.rawValue, closure: { () -> Bool in
            if self.preferencesIndex > 0 && self.preferencesText.count > g_windowContentLineCount {
                if self.preferencesIndex - g_windowContentLineCount > 0 {
                    self.preferencesIndex -= g_windowContentLineCount
                }
                else {
                    self.preferencesIndex = 0
                }
                self.renderWindow()
            }
            return false
        })
        keyHandler.addKeyHandler(key: ConsoleKey.KEY_RIGHT.rawValue, closure: { () -> Bool in
            if self.preferencesIndex >= 0 && self.preferencesText.count > g_windowContentLineCount {
                if self.preferencesIndex + g_windowContentLineCount < self.preferencesText.count - g_windowContentLineCount {
                    self.preferencesIndex += g_windowContentLineCount
                }
                else {
                    self.preferencesIndex = self.preferencesText.count - g_windowContentLineCount
                }
                self.renderWindow()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: UInt32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
