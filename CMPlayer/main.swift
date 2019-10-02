//
//  main.swift
//  ConsoleMusicPlayer.macOS
//
//  Created by Kjetil Kr Solberg on 18/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation

//
// Global constants.
//
internal let g_fieldWidthSongNo: Int = 8
internal let g_fieldWidthArtist: Int = 33
internal let g_fieldWidthTitle: Int = 33
internal let g_fieldWidthDuration: Int = 5
internal let g_player: Player = Player()
internal let g_versionString: String = "1.8.2.5"
internal let g_lock = NSLock()
internal let g_windowContentLineCount = 17

//
// Global variables/properties
//
internal var g_songs: [SongEntry] = []
internal var g_playlist: [SongEntry] = []
internal var g_genres: [String: [SongEntry]] = [:]
internal var g_artists: [String: [SongEntry]] = [:]
internal var g_recordingYears: [Int: [SongEntry]] = [:]
internal var g_searchResult: [SongEntry] = []
internal var g_modeGenre: [String] = []
internal var g_modeArtist: [String] = []
internal var g_modeRecordingYears: [Int] = []
internal var g_modeSearch: [String] = []
internal var g_modeSearchStats: [Int] = []
internal var g_library: PlayerLibrary = PlayerLibrary()
internal var g_mainWindow: MainWindow?

//
// Startup code
//
g_player.initialize()
exit(g_player.run())

