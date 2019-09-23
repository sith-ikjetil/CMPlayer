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
internal class PreferencesWindow {
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
        self.renderHelp()
        self.run()
    }
    
    func updatePreferencesText() {
        self.preferencesText = [" Music Root Path", " :: \(PlayerPreferences.musicRootPath)",
                                " Music Formats", " :: \(PlayerPreferences.musicFormats)",
                                " Enable Autoplay On Startup", " :: \(PlayerPreferences.autoplayOnStartup)",
                                " Enable Crossfade", " :: \(PlayerPreferences.crossfadeSongs)",
                                " Crossfade Time"," :: \(PlayerPreferences.crossfadeTimeInSeconds) seconds"]
    }
    
    ///
    /// Renders screen output. Does clear screen first.
    ///
    func renderHelp() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader(showTime: false)
        
        Console.printXY(1,3,"### PREFERENCES ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
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
            
            if index_search % 2 == 0 {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            }
            else {
                Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            }
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT PREFERENCES.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        self.preferencesIndex = 0
        self.renderHelp()
        
        let keyHandler: ConsoleKeyboardHandler = ConsoleKeyboardHandler()
        keyHandler.addKeyHandler(key: 66, closure: { () -> Bool in
            if (self.preferencesIndex + 17) < self.preferencesText.count {
                self.preferencesIndex += 1
                self.renderHelp()
            }
            return false
        })
        keyHandler.addKeyHandler(key: 65, closure: { () -> Bool in
            if self.preferencesIndex > 0 {
                self.preferencesIndex -= 1
                self.renderHelp()
            }
            return false
        })
        keyHandler.addUnknownKeyHandler(closure: { (key: Int32) -> Bool in
            return true
        })
        keyHandler.run()
    }// run
}// HelpWindow
