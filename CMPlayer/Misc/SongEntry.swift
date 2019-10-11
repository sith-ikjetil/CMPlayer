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
    let unknownMetadataStringValue: String = "--unknown--"
    var songNo: Int = 0
    var artist: String = ""
    var fullArtist: String = ""
    var title: String = ""
    var fullTitle: String = ""
    var duration: UInt64 = 0
    var fileURL: URL? = nil
    var genre: String = ""
    var fullGenre: String = ""
    var albumName: String = ""
    var fullAlbumName: String = ""
    var recodingYear: Int = 0
    var trackNo: Int = 0
    let maxStringLength: Int = 32
    
    ///
    /// Overloaded initializer. Is only called from PlayerLibrary.load()
    ///
    /// parameter number: Song No.
    /// parameter artist: Artist.
    /// parameter title: Title.
    /// parameter duration: Song length in milliseconds.
    /// parameter url: Song file path.
    ///
    init(songNo: Int, artist: String, albumName: String, title: String, duration: UInt64, url: URL?, genre: String, recordingYear: Int, trackNo: Int) throws {
        guard url != nil else {
            PlayerLog.ApplicationLog?.logError(title: "[SongEntry].init(songNo:,artist:,albumName:,title:,duration:,url:,genre:,recordingYear:,trackNo:)", text: "path == nil")
            throw SongEntryError.PathIsNil
        }
        
        guard isPathInMusicRootPath(path: url!.path) else {
            PlayerLog.ApplicationLog?.logError(title: "[SongEntry].init(songNo:,artist:,albumName:,title:,duration:,url:,genre:,recordingYear:,trackNo:)", text: "url not in music root path:\(url!.path)}")
            throw SongEntryError.PathNotExist
        }
        
        guard !isPathInExclusionPath(path: url!.path) else {
            PlayerLog.ApplicationLog?.logError(title: "[SongEntry].init(songNo:,artist:,albumName:,title:,duration:,url:,genre:,recordingYear:,trackNo:)", text: "url in exclusion path:\(url!.path)}")
            throw SongEntryError.PathInExclusionPath
        }
        
        guard duration > 0 else {
            PlayerLog.ApplicationLog?.logWarning(title: "[SongEntry].init(path:songNo:)", text: "Duration was 0. File: \(url!.path)")
            throw SongEntryError.DurationIsZero
        }
        
        self.songNo = songNo
        self.artist = artist
        self.fullArtist = artist
        self.albumName = albumName
        self.fullAlbumName = albumName
        self.title = title
        self.fullTitle = title
        self.duration = duration
        self.fileURL = url
        self.genre = genre.lowercased()
        self.fullGenre = genre.lowercased()
        self.recodingYear = recordingYear
        self.trackNo = trackNo

    
        self.fullTitle = trimAndSetStringDefaultValue(str: self.title)
        self.title = trimAndSetStringDefaultValueMaxLength(str: self.title)
        
        self.fullAlbumName = trimAndSetStringDefaultValue(str: self.albumName)
        self.albumName = trimAndSetStringDefaultValueMaxLength(str: self.albumName)
        
        //
        // Add to g_genres
        //
        self.fullGenre = trimAndSetStringDefaultValue(str: self.genre)
        self.genre = trimAndSetStringDefaultValueMaxLength(str: self.genre)

        if g_genres[self.genre] == nil {
            g_genres[self.genre] = []
        }
        
        g_genres[self.genre]?.append(self)
        
        //
        // Add to g_artists
        //
        self.fullArtist = trimAndSetStringDefaultValue(str: self.artist)
        self.artist = trimAndSetStringDefaultValueMaxLength(str: self.artist)
        
        if g_artists[self.artist] == nil {
            g_artists[self.artist] = []
        }

        g_artists[self.artist]?.append(self)
        
        //
        // Add to g_releaseYears
        //
        if g_recordingYears[self.recodingYear] == nil {
            g_recordingYears[self.recodingYear] = []
        }
        
        g_recordingYears[self.recodingYear]?.append(self)
    }
    
    ///
    /// Overloaded initializer.
    ///
    /// parameter path: URL file path to song.
    /// parameter num: Song No.
    ///
    init(path: URL?, songNo: Int) throws
    {
        guard path != nil else {
            PlayerLog.ApplicationLog?.logError(title: "[SongEntry].init(path:,songNo:)", text: "path == nil")
            throw SongEntryError.PathIsNil
        }
        
        guard isPathInMusicRootPath(path: path!.path) else {
            PlayerLog.ApplicationLog?.logError(title: "[SongEntry].init(path:,songNo:)", text: "path not in music root path: \(path!.path)")
            throw SongEntryError.PathNotExist
        }
        
        guard !isPathInExclusionPath(path: path!.path) else {
            PlayerLog.ApplicationLog?.logError(title: "[SongEntry].init(path:,songNo:)", text: "url in exclusion path:\(path!.path)}")
            throw SongEntryError.PathInExclusionPath
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
                    }
                    else if keyValue == "artist" {
                        self.artist = item.stringValue!
                    }
                }
            }
            
            if let npath = NSURL(string: path!.absoluteString) {
                if let metadata = MDItemCreateWithURL(kCFAllocatorDefault, npath) {
                    if let ge = MDItemCopyAttribute(metadata,kMDItemMusicalGenre) as? String {
                        self.genre = ge.lowercased()
                    }
                    if let an = MDItemCopyAttribute(metadata,kMDItemAlbum) as? String {
                        self.albumName = an.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    if let geYear = MDItemCopyAttribute(metadata,kMDItemRecordingYear) as? Int {
                        self.recodingYear = geYear
                    }
                    if let trackNo = MDItemCopyAttribute(metadata,kMDItemAudioTrackNumber) as? Int {
                        self.trackNo = trackNo
                    }
                }
            }
        }
        
        guard duration > 0 else {
            PlayerLog.ApplicationLog?.logWarning(title: "[SongEntry].init(path:songNo:)", text: "Duration was 0. File: \(path!.path)")
            throw SongEntryError.DurationIsZero
        }
        
        //
        // Add to genre
        //
        self.fullGenre = trimAndSetStringDefaultValue(str: self.genre)
        self.genre = trimAndSetStringDefaultValueMaxLength(str: self.genre)
        if g_genres[self.genre] == nil {
            g_genres[self.genre] = []
        }
        
        g_genres[self.genre]?.append(self)
        
        //
        // Add to g_artists
        //
        self.fullArtist = trimAndSetStringDefaultValue(str: self.artist)
        self.artist = trimAndSetStringDefaultValueMaxLength(str: self.artist)
        if g_artists[self.artist] == nil {
            g_artists[self.artist] = []
        }
    
        g_artists[self.artist]?.append(self)
    
        
        //
        // Add to g_releaseYears
        //
        if g_recordingYears[self.recodingYear] == nil {
            g_recordingYears[self.recodingYear] = []
        }
       
        g_recordingYears[self.recodingYear]?.append(self)
        
        self.fullTitle = trimAndSetStringDefaultValue(str: self.title)
        self.title = trimAndSetStringDefaultValueMaxLength(str: self.title)
        
        self.fullAlbumName = trimAndSetStringDefaultValue(str: self.albumName)
        self.albumName = trimAndSetStringDefaultValueMaxLength(str: self.albumName)
    }
    
    ///
    /// Trims string and sets default value if it is empty
    ///
    func trimAndSetStringDefaultValue(str: String) -> String {
        var s = str.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.count == 0 {
            s = self.unknownMetadataStringValue
        }
        return s
    }
    
    func trimAndSetStringDefaultValueMaxLength(str: String) -> String {
        var s = self.trimAndSetStringDefaultValue(str: str)
        if s.count > self.maxStringLength {
            s = String(s[s.startIndex..<s.index(s.startIndex, offsetBy: self.maxStringLength)])
        }
        return s
    }
}// SongEntry
