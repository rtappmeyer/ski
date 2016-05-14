//
//  LevelMaker.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol tileMapDelegate {
    func createNodeOf(type type:tileType, location:CGPoint)
}

enum tileType: Int {
    case tileAir = 0
    case tileSnow = 1
    case tileTree = 2
    case tileRock = 3
    case tilePost = 4
    case tileStart = 5
}

struct tileMap {
    var delegate: tileMapDelegate?
    var tileSize = CGSize(width: 16, height: 32)
    var tileLayer: [[Int]] = Array()
    var mapSize = CGPoint(x: 16, y: 128)
    
    mutating func generateLevel(defaultValue: Int) {
        var columnArray:[[Int]] = Array()
        
        repeat {
            var rowArray:[Int] = Array()
            repeat {
                rowArray.append(defaultValue)
            } while rowArray.count < Int(mapSize.x)
            columnArray.append(rowArray)
        } while columnArray.count < Int(mapSize.y)
        
        tileLayer = columnArray
    }
    
    // MARK: Setters and getters for the tile map
    mutating func setTile(position position:CGPoint, toValue:Int) {
        tileLayer[Int(position.y)][Int(position.x)] = toValue
    }
    
    func getTile(position position:CGPoint) -> Int {
        return tileLayer[Int(position.y)][Int(position.x)]
    }
    
    func tilemapSize() -> CGSize {
        return CGSize(width: tileSize.width * mapSize.x, height:
            tileSize.height * mapSize.y)
    }
    
    // MARK: Level creation
    mutating func generateLevel() {
        
        // Read Level from File
        let levelData = readLinesFromTextFile("ski_level1.txt")
        
        // Read lines of level data description
        var row: Int = 0
        for line in levelData {
            var pos: Int = 0
            for index in line.characters.indices {
                if line[index] == "G" {                                     // Tree
                    setTile(position: CGPoint(x: pos, y: row), toValue: 2)
                } else if line[index] == "m" {                              // Rock
                    setTile(position: CGPoint(x: pos, y: row), toValue: 3)
                } else if line[index] == "P" {                              // Post
                    setTile(position: CGPoint(x: pos, y: row), toValue: 4)
                } else if line[index] == "I" {                              // Player
                    setTile(position: CGPoint(x: pos, y: row), toValue: 5)
                } else {                                                    // Snow
                    setTile(position: CGPoint(x: pos, y: row), toValue: 1)
                }
                pos += 1
            }
            row += 1
        }
    }
    
    // MARK: Presenting the layer
    func presentLayerViaDelegate() {
        for (indexr, row) in tileLayer.enumerate() {
            for (indexc, cvalue) in row.enumerate() {
                if (delegate != nil) {
                    delegate!.createNodeOf(type: tileType(rawValue: cvalue)!, location: CGPoint(x: tileSize.width * CGFloat(indexc), y: tileSize.height * CGFloat(-indexr)))
                }
            }
        }
    }
    
    // MARK: Utility
    func readLinesFromTextFile(fileName: String) -> [String] {
        // Reads lines from a text file
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil) else {
            fatalError("Resource file for \(fileName) not found.")
        }
        do {
            let content = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            return content.componentsSeparatedByString("\n")
        } catch let error {
            fatalError("Could not load strings from \(path): \(error).")
        }
    }
}
    