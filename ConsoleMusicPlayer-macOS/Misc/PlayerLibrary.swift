//
//  PlayerLibrary.swift
//  ConsoleMusicPlayer-macOS
//
//  Created by Kjetil Kr Solberg on 21/09/2019.
//  Copyright © 2019 Kjetil Kr Solberg. All rights reserved.
//

import Foundation

internal class PlayerLibrary {
    private let filename: String = "CMPLayer.Library.xml"
    var library: [SongEntry] = []
    var numbers: [Int] = []
    
    init() {
        
    }
    
    func find(url: URL) -> SongEntry? {
        for s in self.library {
            if s.fileURL != nil {
                if ( s.fileURL! == url ) {
                    return s
                }
            }
        }
        return nil
    }
    
    func nextAvailableNumber() -> Int {
        for number in 1..<Int.max  {
            var hit = false
            for n in self.numbers {
                if n == number {
                    hit = true
                    break
                }
            }
            if hit == false {
                self.numbers.append(number)
                return number
            }
        }
        return 0
    }
    
    func load() {
        let fileUrl: URL = PlayerDirectories.consoleMusicPlayerDirectory.appendingPathComponent("CMPlayer.Library.xml", isDirectory: false)
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            do {
                self.numbers.removeAll()
                let xd: XMLDocument = try XMLDocument(contentsOf: fileUrl)
                let xeSongLibrary = xd.rootElement()!
            
                let xeSongs = xeSongLibrary.elements(forName: "Song")
                
                for s in xeSongs {
                    var number: Int = 0
                    var artist: String = ""
                    var title: String = ""
                    var url: String = ""
                    var duration: UInt64 = 0
                    
                    if let aNumber = s.attribute(forName: "number") {
                        number = Int(aNumber.stringValue ?? "0") ?? 0
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
                    
                    self.numbers.append(number)
                    self.library.append(SongEntry(number: number, artist: artist, title: title, duration: duration, url: URL(fileURLWithPath: url)))
                }
            }
            catch {
                
            }
        }
    }
    
    func save() {
        let xeRoot: XMLElement = XMLElement(name: "SongLibrary")
        
        for s in self.library {
            let xeSong: XMLElement = XMLElement(name: "Song")
            xeRoot.addChild(xeSong)
            
            let xnNumber: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnNumber.name = "number"
            xnNumber.setStringValue(String(s.number), resolvingEntities: true)
            xeSong.addAttribute(xnNumber)
            
            let xnArtist: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnArtist.name = "artist"
            xnArtist.setStringValue(String(s.artist), resolvingEntities: true)
            xeSong.addAttribute(xnArtist)
            
            let xnTitle: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnTitle.name = "title"
            xnTitle.setStringValue(String(s.title), resolvingEntities: true)
            xeSong.addAttribute(xnTitle)
            
            let xnDuration: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnDuration.name = "duration"
            xnDuration.setStringValue(String(s.duration), resolvingEntities: true)
            xeSong.addAttribute(xnDuration)
            
            let xnUrl: XMLNode = XMLNode(kind: XMLNode.Kind.attribute)
            xnUrl.name = "url"
            xnUrl.setStringValue(s.fileURL?.path ?? "", resolvingEntities: true)
            xeSong.addAttribute(xnUrl)
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
    }
}
