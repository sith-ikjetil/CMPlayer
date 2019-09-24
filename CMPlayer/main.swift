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
// Global properties/constants.
//
var g_songs: [SongEntry] = []
var g_playlist: [SongEntry] = []
var g_searchResult: [SongEntry] = []
var g_genres: [String: [SongEntry]] = [:]
var g_artists: [String: [SongEntry]] = [:]
var g_modeGenre: [String] = []
var g_modeArtist: [String] = []
var g_library: PlayerLibrary = PlayerLibrary()
var g_mainWindow: MainWindow?
let g_player: Player = Player()
let g_versionString: String = "1.4.5.2"

//
// Startup code
//
g_player.initialize()
exit(g_player.run())

