//
//  SongEntry.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 18/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation
import AVFoundation

internal class SongEntry {
    var number: Int = 0
    var artist: String = ""
    var title: String = ""
    var duration: UInt64 = 0
    var fileURL: URL? = nil
    
    init()
    {
        self.number = 0
        self.artist = "<UNKNOWN>"
        self.title = "<UNKNOWN>"
        self.duration = 0
        self.fileURL = nil
    }
    
    init(number: Int, artist: String, title: String, duration: UInt64, url: URL?) {
        self.number = number
        self.artist = artist
        self.title = title
        self.duration = duration
        self.fileURL = url
    }
    
    init(path: URL?, num: Int)
    {
        self.number = num
        self.fileURL = path!
        
        let playerItem = AVPlayerItem(url: self.fileURL!)
        
        let audioAsset = AVURLAsset.init(url: self.fileURL!, options: nil)
        self.duration = UInt64(CMTimeGetSeconds(audioAsset.duration) * Float64(1000))
        
        let metadataList = playerItem.asset.metadata
        
        for item in metadataList {
            if let keyValue = item.commonKey?.rawValue {
                if keyValue == "title" {
                    self.title = item.stringValue!
                    if self.title.count > 32 {
                        self.title = String(title[title.startIndex..<title.index(title.startIndex, offsetBy: 32)])
                    }
                }
            }
            if let keyValue = item.commonKey?.rawValue {
                if keyValue == "artist" {
                    self.artist = item.stringValue!
                    if self.artist.count > 32 {
                        self.artist = String(artist[artist.startIndex..<artist.index(artist.startIndex, offsetBy: 32)])
                    }
                }
            }
        }
    }
}
