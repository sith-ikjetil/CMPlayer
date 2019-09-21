//
//  HelpWindow.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 20/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

internal class HelpWindow {
    private var helpIndex: Int = 0
    private let helpText: [(String, String)] = [(" exit, quit", " :: exits application"),
                                                (" next, skip", " :: plays next song"),
                                                (" play, pause, resume", " :: plays, pauses or resumes playback"),
                                                (" search [<words>]", " :: searches artist and title for a match. case insensitive"),
                                                (" help"," :: shows this help screen"),
                                                (" repaint", " :: clears and repaints entire console window"),
                                                (" set mrp <path>", " :: sets the path to the root folder where the music resides"),
                                                (" set cft <seconds>", " :: sets the crossfade time in seconds (1-10 seconds)"),
                                                (" enable crossfade"," :: enables crossfade"),
                                                (" disable crossfade", " :: disables crossfade"),
                                                (" enable aos", " :: enables autoplay when application starts"),
                                                (" disable aos", " :: disables autoplay when application starts")]
    
    
    func showWindow() {
        self.helpIndex = 0
        self.renderHelp()
    }
    
    func renderHelp() -> Void {
        Console.clearScreen()
        
        MainWindow.renderHeader()
        
        Console.printXY(1,3,"### HELP ###", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        var index_screen_lines: Int = 5
        var index_search: Int = helpIndex
        let max = helpIndex + 21
        while index_search < max {
            if index_screen_lines == 22 {
                break
            }
            
            if index_search > helpText.count - 1 {
                break
            }
            
            let se = helpText[index_search]
            
            Console.printXY(1, index_screen_lines, "\(se.0) ", 21, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.cyan, ConsoleColorModifier.bold)
            Console.printXY(21, index_screen_lines, "\(se.1)", 59, .left, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
            
            index_screen_lines += 1
            index_search += 1
        }
        
        Console.printXY(1,23,"PRESS UP KEY OR DOWN KEY FOR MORE RESULTS. OTHER KEY TO EXIT HELP.", 80, .center, " ", ConsoleColor.black, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
    }
    
    func run() -> Void {
        self.helpIndex = 0
        self.renderHelp()
        var ch = getchar()
        while ch == EOF || ch == 27 || ch == 91 || ch == 65 || ch == 66 {
            if ch == 27 {
                ch = getchar()
            }
            if ch == 91 {
                ch = getchar()
            }
            
            if ch == 66 { // DOWN
                if (self.helpIndex + 17) < self.helpText.count {
                    self.helpIndex += 1
                    self.renderHelp()
                }
            }
            if ch == 65 { // UP
                if self.helpIndex > 0 {
                    self.helpIndex -= 1
                    self.renderHelp()
                }
            }
            ch = getchar()
        }
    }
}
