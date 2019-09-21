//
//  HelpWindow.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 20/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

internal class AboutWindow {
    private var aboutIndex: Int = 0
    private let aboutText: [String] = ["   CMPlayer (Console Music Player) is a clone and improvement over the",
                                       "   Interactive DJ software written in summer 1997 running on DOS.",
                                       "   ",
                                       "   The CMPlayer software runs on macOS as a console application.",
                                       "   ",
                                       "   CMPlayer is a different kind of music player. It selects random songs",
                                       "   from your library and runs to play continually. You choose music",
                                       "   by searching for them, and in the main window entering the number",
                                       "   associated with the song to add to the playlist.",
                                       "   ",
                                       "   CMPlayer was made by Kjetil Kristoffer Solberg. ENJOY!"]
    
    
    func showWindow() {
        self.aboutIndex = 0
        self.renderAbout()
        self.run()
    }
    
    func renderAbout() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader()
        
        Console.printXY(1,3,"### ABOUT ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = self.aboutIndex
        let max = self.aboutIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > self.aboutText.count - 1 {
                break
            }
            
            let se = self.aboutText[index_search]
            
            Console.printXY(1, index_screen_lines, se, se.count, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        //Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE TEXT. OTHER KEY TO EXIT ABOUT.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,23,"PRESS ANY KEY TO EXIT ABOUT", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func run() -> Void {
        self.aboutIndex = 0
        self.renderAbout()
        var ch = getchar()
        while ch == EOF || ch == 27 || ch == 91 || ch == 65 || ch == 66 {
            if ch == 27 {
                ch = getchar()
            }
            if ch == 91 {
                ch = getchar()
            }
            
            if ch == 66 { // DOWN
                if (self.aboutIndex + 17) < self.aboutText.count {
                    self.aboutIndex += 1
                    self.renderAbout()
                }
            }
            if ch == 65 { // UP
                if self.aboutIndex > 0 {
                    self.aboutIndex -= 1
                    self.renderAbout()
                }
            }
            ch = getchar()
        }
    }
}
