//
//  PlayerLibrary.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 21/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

//
// import.
//
import Foundation

///
/// Represents CMPlayer PlayerLibrary
///
internal class PlayerLibrary {
    //
    // Private properties/constants
    //
    private let filename: String = "CMPLayer.Library.xml"
    private var nextSongNo: Int = 0
    private var dictionary: [String: Int] = [:]
    
    //
    // Internal properties/Constants
    //
    var library: [SongEntry] = []
    
    ///
    /// Default initializer
    ///
    init() {
        
    }
    
    ///
    /// Find SongEntry in self.dictionary. Return it or nil if not existing.
    ///
    func find(url: URL) -> SongEntry? {
        if let item = self.dictionary[url.path] {
            if self.library.count > item {
                return self.library[item]
            }
        }
        return nil
    }
    
    ///
    /// Return next available SongNo.
    ///
    /// returnes: Next available song number.
    ///
    func nextAvailableSongNo() -> Int {
        self.nextSongNo += 1
        return self.nextSongNo
    }
    
    ///
    /// Sets the next available number
    ///
    func setNextAvailableSongNo(_ songNo: Int) -> Void {
        self.nextSongNo = songNo
    }
    
    ///
    /// Loads the CMPlayer.Library.xml song library for faster song initialization load time.
    ///
    func load() {
        let fileUrl: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent("CMPlayer.Library.xml", isDirectory: false)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                self.dictionary.removeAll()
                
                let xd: XMLDocument = try XMLDocument(contentsOf: fileUrl)
                let xeSongLibrary = xd.rootElement()!
            
                let xeSongs = xeSongLibrary.elements(forName: "Song")
                
                for s in xeSongs {
                    var songNo: Int = 0
                    var artist: String = ""
                    var title: String = ""
                    var url: String = ""
                    var duration: UInt64 = 0
                    var genre: String = ""
                    
                    if let aNumber = s.attribute(forName: "songNo") {
                        songNo = Int(aNumber.stringValue ?? "0") ?? 0
                    }
                    if let aArtist = s.attribute(forName: "artist") {
                        artist = aArtist.stringValue ?? "<UNKNOWN>"
                    }
                    if let aTitle = s.attribute(forName: "title") {
                        title = aTitle.stringValue ?? "<UNKNOWN>"
                    }
                    if let aDuration = s.attribute(forName: "duration") {
                        duration = UInt64(aDuration.stringValue ?? "0") ?? 0
                    }
                    if let aUrl = s.attribute(forName: "url") {
                        url = aUrl.stringValue ?? ""
                    }
                    if let aGenre = s.attribute(forName: "genre") {
                        genre = aGenre.stringValue ?? ""
                    }
                    
                    if songNo > self.nextSongNo {
                        self.nextSongNo = songNo
                    }
                    let se = SongEntry(songNo: songNo, artist: artist, title: title, duration: duration, url: URL(fileURLWithPath: url), genre: genre)
                    self.library.append(se)
                    if url.count > 0 {
                        self.dictionary[url] = self.library.count-1
                    }
                }
            }
            catch {
                
            }
        }
    }
    
    ///
    /// Saves the self.library SongEntry array to CMPlayer.Library.xml.
    ///
    func save() {
        let xeRoot: XMLElement = XMLElement(name: "SongLibrary")
        
        for s in self.library {
            let xeSong: XMLElement = XMLElement(name: "Song")
            xeRoot.addChild(xeSong)
            
            let xnSongNo: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnSongNo.name = "songNo"
            xnSongNo.setStringValue(String(s.songNo), resolvingEntities: true)
            xeSong.addAttribute(xnSongNo)
            
            let xnArtist: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnArtist.name = "artist"
            xnArtist.setStringValue(s.artist, resolvingEntities: true)
            xeSong.addAttribute(xnArtist)
            
            let xnTitle: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnTitle.name = "title"
            xnTitle.setStringValue(s.title, resolvingEntities: true)
            xeSong.addAttribute(xnTitle)
            
            let xnDuration: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnDuration.name = "duration"
            xnDuration.setStringValue(String(s.duration), resolvingEntities: true)
            xeSong.addAttribute(xnDuration)
            
            let xnUrl: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnUrl.name = "url"
            xnUrl.setStringValue(s.fileURL?.path ?? "", resolvingEntities: true)
            xeSong.addAttribute(xnUrl)
            
            let xnGenre: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnGenre.name = "genre"
            xnGenre.setStringValue(s.genre, resolvingEntities: true)
            xeSong.addAttribute(xnGenre)
        }
   
        //
        // save
        //
        let fileUrl: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent("CMPlayer.Library.xml", isDirectory: false)
        
        let xd: XMLDocument = XMLDocument(rootElement: xeRoot)
        do {
            //let str: String = xd.xmlString
            try xd.xmlString.write(to: fileUrl, atomically: true, encoding: .utf8)
        }
        catch {
            
        }
    }// save
}// PlayerLibrary
