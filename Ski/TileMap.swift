//
//  TileMap.swift
//  Ski
//
//  Created by Ralf Tappmeyer on 5/7/16.
//  Copyright © 2016 Ralf Tappmeyer. All rights reserved.
//

import SpriteKit
import GameplayKit

protocol tileMapDelegate {
    func createNodeOf(type:tileType, location:CGPoint)
}

enum tileType: Int {
    case
    tileAir = 0,
    tileSnow = 1,
    tileTree = 2,
    tileRock = 3,
    tilePostLeft = 4,
    tileGate = 5,
    tilePostRight = 6,
    tileStart = 7,
    tileFinish = 8,
    tileOpponent = 9
}

enum tileCharacter: String {
    case
    tileAir = "",
    tileSnow = " ",
    tileTree = "G",
    tileRock = "m",
    tilePostLeft = "q",
    tileGate = ".",
    tilePostRight = "p",
    tileStart = "I",
    tileFinish = "F",
    tileOpponent = "O"
    
    static let getAll = [tileAir, tileSnow, tileTree, tileRock, tilePostLeft, tileGate, tilePostRight, tileStart, tileFinish, tileOpponent]
}

struct tileMap {
    var delegate: tileMapDelegate?
    var tileSize = CGSize(width: 16, height: 32)
    var tileLayer: [[Int]] = Array()
    var mapSize = CGPoint(x: 16, y: 128) // TODO: put it back to 128
    
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
    mutating func setTile(position:CGPoint, toValue:Int) {
        tileLayer[Int(position.y)][Int(position.x)] = toValue
    }
    
    func getTile(position:CGPoint) -> Int {
        return tileLayer[Int(position.y)][Int(position.x)]
    }
    
    func getTileFromPoint(point: CGPoint) -> Int {
        let tilePoint = CGPoint(x: point.x / 16, y: (point.y / 32) * -1)
        print(tilePoint)
        return getTile(position: tilePoint)
    }
    
    func getTilesInRowOfPoint(point: CGPoint) -> [Int] {
        var rowArray = [Int]()
        var pos = 0
        repeat {
            rowArray.append(getTile(position: CGPoint(x: pos, y: Int(point.y / 32) * -1)))
            pos += 1
        } while rowArray.count < Int(mapSize.x)
        return rowArray
    }
    
    func tilemapSize() -> CGSize {
        return CGSize(width: tileSize.width * mapSize.x, height:
            tileSize.height * mapSize.y)
    }
    
    // MARK: Level creation
    mutating func createLevel(level: Int) {
        
        // Read Level from File
        print("Loading level \(level) from tile map")
        let levelFileName = "ski_level\(level).txt"
        let levelData = readLinesFromTextFile(fileName: levelFileName)
        
        // Read lines of level data description
        var row: Int = 0
        for line in levelData {
            var pos: Int = 0
            for index in line.characters.indices {
                if let foundIndex = tileCharacter.getAll.index(where: {$0.rawValue == String(line[index])}) {
                    setTile(position: CGPoint(x: pos, y: row), toValue: foundIndex)
                }
                pos += 1
            }
            row += 1
        }
    }
    
    // MARK: Presenting the layer
    func presentLayerViaDelegate() {
        for (indexr, row) in tileLayer.enumerated() {
            for (indexc, cvalue) in row.enumerated() {
                if (delegate != nil) {
                    delegate!.createNodeOf(type: tileType(rawValue: cvalue)!, location: CGPoint(x: tileSize.width * CGFloat(indexc), y: tileSize.height * CGFloat(-indexr)))
                }
            }
        }
    }
    
    // MARK: Utility
    func readLinesFromTextFile(fileName: String) -> [String] {
        // Reads lines from a text file
        guard let path = Bundle.main.path(forResource: fileName, ofType: nil) else {
            fatalError("Resource file for \(fileName) not found.")
        }
        do {
            let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            return content.components(separatedBy: "\n")
        } catch let error {
            fatalError("Could not load strings from \(path): \(error).")
        }
    }
}
    
