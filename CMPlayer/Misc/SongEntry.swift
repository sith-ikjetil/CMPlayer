//
//  SongEntry.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 18/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation
import AVFoundation

///
/// Represents CMPlayer SongEntry
///
internal class SongEntry {
    //
    // Properties/Constants.
    //
    var number: Int = 0
    var artist: String = ""
    var title: String = ""
    var duration: UInt64 = 0
    var fileURL: URL? = nil
    
    ///
    /// Default initializer
    ///
    init()
    {
        self.number = 0
        self.artist = "<UNKNOWN>"
        self.title = "<UNKNOWN>"
        self.duration = 0
        self.fileURL = nil
    }
    
    ///
    /// Overloaded initializer
    ///
    /// parameter: number. Song No.
    /// parameter: artist. Artist.
    /// parameter: title. Title.
    /// parameter: duration. Song length in milliseconds.
    /// parameter: url. Song file path.
    ///
    init(number: Int, artist: String, title: String, duration: UInt64, url: URL?) {
        self.number = number
        self.artist = artist
        self.title = title
        self.duration = duration
        self.fileURL = url
    }
    
    ///
    /// Overloaded initializer.
    ///
    /// parameter: path. URL file path to song.
    /// parameter: num. Song No.
    ///
    init(path: URL?, num: Int)
    {
        //
        // MEMORY LEAK IN THIS METHOD
        //
        self.number = num
        self.fileURL = path!
        
        let playerItem = AVPlayerItem(url: self.fileURL!)
        
        let audioAsset = AVURLAsset(url: self.fileURL!, options: nil)
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
    }// init
}// SongEntry
