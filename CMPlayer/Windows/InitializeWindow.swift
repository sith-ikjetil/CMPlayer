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
/// Represents CMPlayer HelpWindow.
///
internal class InitializeWindow : TerminalSizeHasChangedProtocol, PlayerWindowProtocol {
    //
    // Private properties/constants
    //
    private var filesFoundCompleted: Int = 0
    private var libraryLoadedCompleted: Int = 0
    private var isFinished: Bool = false
    private var currentPath: String = ""
    private let concurrentQueue1 = DispatchQueue(label: "cqueue.cmplayer.macos.Initialize", attributes: .concurrent)
    private var musicFormats: [String] = []
    
    ///
    /// Shows this HelpWindow on screen.
    ///
    /// parameter song: Instance of SongEntry to render info.
    ///
    func showWindow() -> Void {
        
        g_tscpStack.append(self)
        
        Console.clearScreenCurrentTheme()
        self.renderWindow()
        
        concurrentQueue1.async {
            self.initialize()
            self.isFinished = true
        }
        
        self.run()
        
        g_tscpStack.removeLast()
    }
    
    func initialize() -> Void {
        g_songs.removeAll()
        g_playlist.removeAll()
        
        self.musicFormats = PlayerPreferences.musicFormats.components(separatedBy: ";")
        
        for mrpath in PlayerPreferences.musicRootPath {
            //#if DEBUG
            //    let result = findSongs(path: "/Users/kjetilso/Music")//"/Volumes/ikjetil/Music/G")
            //#else
                self.filesFoundCompleted = 0
                let result = findSongs(path: mrpath)
                self.filesFoundCompleted = 100
            //#endif
            
            self.currentPath = mrpath
            self.libraryLoadedCompleted = 0
            
            var i: Int = 1
            for r in result {
                self.currentPath = mrpath
                self.libraryLoadedCompleted = Int(Double(i) * Double(100.0) / Double(result.count))
                
                let u: URL = URL(fileURLWithPath: r)
                if let se = g_library.find(url: u) {
                    g_songs.append(se)
                }
                else {
                    let nasno = g_library.nextAvailableSongNo()
                    do {
                        g_songs.append(try SongEntry(path: URL(fileURLWithPath: r),songNo: nasno))
                    }
                    catch  {
                        g_library.setNextAvailableSongNo(nasno)
                    }
                }
                
                i += 1
            }
        }
        
        if g_songs.count > 0 {
            let r1 = g_songs.randomElement()
            let r2 = g_songs.randomElement()
            
            g_playlist.append(r1!)
            g_playlist.append(r2!)
        }
    }
    
    ///
    /// Finds all songs from path and all folder paths under path. Songs must be of format in PlayerPreferences.musicFormats.
    ///
    /// parameter path: The root path to start finding supported audio files.
    ///
    /// returns: [String]. Array of file paths to audio files found.
    ///
    func findSongs(path: String) -> [String]
    {
        var results: [String] = []
        do
        {
            let result = try FileManager.default.contentsOfDirectory(atPath: path)
            for r in result {
                
                var nr = "\(path)/\(r)"
                if path.hasSuffix("/") {
                    nr = "\(path)\(r)"
                }
                
                self.currentPath = nr
                
                if isDirectory(path: nr) {
                    results.append(contentsOf: findSongs(path: nr))
                }
                else {
                    if FileManager.default.isReadableFile(atPath: nr) {
                        for f in self.musicFormats {
                            if r.hasSuffix(f) {
                                results.append(nr)
                                break
                            }
                        }
                    }
                }
            }
        }
        catch {
            results.removeAll()
        }
        
        return results
    }
    
    ///
    /// Determines if a path is a directory or not.
    ///
    /// parameter path. Path to check.
    ///
    /// returns: Bool. True if path is directory. False otherwise.
    ///
    func isDirectory(path: String) -> Bool {
        var isDirectory: ObjCBool = true
        FileManager().fileExists(atPath: path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }// isDirectory
    
    ///
    /// TerminalSizeChangedProtocol method
    ///
    func terminalSizeHasChanged() -> Void {
        Console.clearScreenCurrentTheme()
        self.renderWindow()
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
        
        Console.printXY(1,3,":: INITIALIZE ::", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.yellow, ConsoleColorModifier.bold)
        
        Console.printXY(1, 5, "Current Path: " + self.currentPath, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        let pstFiles: String = "\(self.filesFoundCompleted)%"
        Console.printXY(1, 6, "Finding Song Files: " + pstFiles, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        let pstLib: String = "\(self.libraryLoadedCompleted)%"
        Console.printXY(1, 7, "Updating Song Library: " + pstLib, 80, .left, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.printXY(1,23,"PLEASE BE PATIENT", 80, .center, " ", bgColor, ConsoleColorModifier.none, ConsoleColor.white, ConsoleColorModifier.bold)
        
        Console.gotoXY(80,1)
        print("")
    }
    
    ///
    /// Runs HelpWindow keyboard input and feedback.
    ///
    func run() -> Void {
        Console.clearScreenCurrentTheme()
        while !self.isFinished {
            self.renderWindow()
    
            let second: Double = 1_000_000
            usleep(useconds_t(0.050 * second))
        }
    }// run
}// HelpWindow
