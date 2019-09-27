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
    var songNo: Int = 0
    var artist: String = ""
    var title: String = ""
    var duration: UInt64 = 0
    var fileURL: URL? = nil
    var genre: String = ""
    var albumName: String = ""
    var recodingYear: Int = 0
    
    ///
    /// Overloaded initializer. Is only called from PlayerLibrary.load()
    ///
    /// parameter number: Song No.
    /// parameter artist: Artist.
    /// parameter title: Title.
    /// parameter duration: Song length in milliseconds.
    /// parameter url: Song file path.
    ///
    init(songNo: Int, artist: String, albumName: String, title: String, duration: UInt64, url: URL?, genre: String, recordingYear: Int) {
        self.songNo = songNo
        self.artist = artist
        self.albumName = albumName
        self.title = title
        self.duration = duration
        self.fileURL = url
        self.genre = genre.lowercased()
        self.recodingYear = recordingYear

        if isPathInMusicRootPath(path: url!.path) {
            if self.genre.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                self.genre = "unknown"
            }
            
            //
            // Add to g_genres
            //
            if g_genres[self.genre] == nil {
                g_genres[self.genre] = []
            }
            
            g_genres[self.genre]?.append(self)
            
            //
            // Add to g_artists
            //
            if self.artist.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
                if g_artists[self.artist] == nil {
                    g_artists[self.artist] = []
                }
            
                g_artists[self.artist]?.append(self)
            }
            
            //
            // Add to g_releaseYears
            //
            if g_recordingYears[self.recodingYear] == nil {
                g_recordingYears[self.recodingYear] = []
            }
            
            g_recordingYears[self.recodingYear]?.append(self)
        }
    }
    
    ///
    /// Overloaded initializer.
    ///
    /// parameter path: URL file path to song.
    /// parameter num: Song No.
    ///
    init(path: URL?, songNo: Int) throws
    {
        if path == nil {
            return
        }
        
        self.songNo = songNo
        self.fileURL = path!
        
        autoreleasepool {
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
                    else if keyValue == "artist" {
                        self.artist = item.stringValue!
                        if self.artist.count > 32 {
                            self.artist = String(artist[artist.startIndex..<artist.index(artist.startIndex, offsetBy: 32)])
                        }
                    }
                }
            }
            
            if let npath = NSURL(string: path!.absoluteString) {
                if let metadata = MDItemCreateWithURL(kCFAllocatorDefault, npath) {
                    if let ge = MDItemCopyAttribute(metadata,kMDItemMusicalGenre) as? String {
                        self.genre = ge.lowercased()
                        
                    }
                    if let an = MDItemCopyAttribute(metadata,kMDItemAlbum) as? String {
                        self.albumName = an
                    }
                    if let geYear = MDItemCopyAttribute(metadata,kMDItemRecordingYear) as? Int {
                        self.recodingYear = geYear
                    }
                }
            }
        }
        
        guard duration > 0 else {
            throw SongEntryError.DurationIsZero
        }
        
        //
        // Add to genre
        //
        if self.genre.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            self.genre = "unknown"
        }
        
        if g_genres[self.genre] == nil {
            g_genres[self.genre] = []
        }
        
        g_genres[self.genre]?.append(self)
        
        //
        // Add to g_artists
        //
        if self.artist.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 {
            if g_artists[self.artist] == nil {
                g_artists[self.artist] = []
            }
        
            g_artists[self.artist]?.append(self)
        }
        
        //
        // Add to g_releaseYears
        //
        if g_recordingYears[self.recodingYear] == nil {
            g_recordingYears[self.recodingYear] = []
        }
       
        g_recordingYears[self.recodingYear]?.append(self)
    }// init
}// SongEntry
