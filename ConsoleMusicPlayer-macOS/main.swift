//
//  main.swift
//  ConsoleMusicPlayer.macOS
//
//  Created by Kjetil Kr Solberg on 18/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

var g_songs: [SongEntry] = []
var g_playlist: [SongEntry] = []
var g_searchResult: [SongEntry] = []
var g_library: PlayerLibrary = PlayerLibrary()
var g_mainWindow: MainWindow?
let g_player: Player = Player()
g_player.initialize()
exit(g_player.run())

