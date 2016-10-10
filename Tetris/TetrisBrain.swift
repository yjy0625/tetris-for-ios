//
//  TetrisBrain.swift
//  Tetris
//
//  Created by Day Day Up on 7/1/16.
//  Copyright © 2016 Jingyun Yang. All rights reserved.
//

import UIKit

protocol TetrisBrainDelegate {
    func scoreDidChange()
    func gameDidEnd()
}

class TetrisBrain {
    
    struct Size {
        let width: Int
        let height: Int
        var count: Int {
            return width * height
        }
    }
    
    struct Point {
        var x: Int
        var y: Int
    }
    
    class Matrix {
        let size: Size
        var data: [Bool]
        
        init(size: Size) {
            self.size = Size(width: max(0, size.width), height: max(0, size.height))
            self.data = [Bool](count: self.size.count, repeatedValue: false)
        }
        
        convenience init(size: Size, data: [Bool]) {
            self.init(size: size)
            for i in 0 ..< min(self.size.count, data.count) {
                self.data[i] = data[i]
            }
        }
        
        func value(x: Int, _ y: Int) -> Bool {
            if x >= 0 && x < size.width && y >= 0 && y < size.height {
                return data[x + size.width * y]
            }
            return false
        }
        
        func setValue(x: Int, _ y: Int, value: Bool) {
            let index = x + size.width * y
            if x >= 0 && x < size.width && y >= 0 && y < size.height {
                data[index] = value
            }
        }
        
        // Sample:
        // (0,0)F (1,0)T (2,0)F
        // (0,1)T (1,1)T (2,1)T
        
    }
    
    class Brick {
        let matrix: Matrix
        let pivit: Point
        
        init(matrix: Matrix, pivit: Point) {
            self.matrix = matrix
            self.pivit = pivit
        }
        
        func rotatedBrick() -> Brick {
            let newMatrix = Matrix(size: Size(width: self.matrix.size.height, height: self.matrix.size.width))
            for i in 0 ..< self.matrix.size.width {
                for j in 0 ..< self.matrix.size.height {
                    newMatrix.setValue(j, newMatrix.size.height - 1 - i, value: matrix.value(i, j))
                }
            }
            return Brick(matrix: newMatrix, pivit: Point(x: pivit.y, y: matrix.size.width - 1 - pivit.x))
        }
        
        private func canFitInPosition(position: Point, space: Matrix) -> Bool {
            if position.x - pivit.x < 0 || position.x - pivit.x + matrix.size.width > space.size.width {
                return false
            }
            if position.y - pivit.y + matrix.size.height > space.size.height {
                return false
            }
            for i in 0 ..< matrix.size.width {
                for j in 0 ..< matrix.size.height {
                    if matrix.value(i,j) && space.value(position.x - pivit.x + i, position.y - pivit.y + j) {
                        return false
                    }
                }
            }
            return true
        }
        
        func canMoveLeft(position: Point, space: Matrix) -> Bool {
            return canFitInPosition(Point(x: position.x - 1, y: position.y), space: space)
        }
        
        func canMoveRight(position: Point, space: Matrix) -> Bool {
            return canFitInPosition(Point(x: position.x + 1, y: position.y), space: space)
        }
        
        func canRotate(position: Point, space: Matrix) -> Bool {
            let imaginedBrick = rotatedBrick()
            return imaginedBrick.canFitInPosition(position, space: space)
        }
        
        func canDrop(position: Point, space: Matrix) -> Bool {
            return canFitInPosition(Point(x: position.x, y: position.y + 1), space: space)
        }
        
        func canFall(position: Point, space: Matrix) -> Int {
            for i in 1 ..< space.size.height {
                if !canFitInPosition(Point(x: position.x, y: position.y + i), space: space) {
                    return i - 1
                }
            }
            return 0
        }
        
        func addToSpace(position: Point, space: Matrix) -> Matrix {
            for i in 0 ..< matrix.size.width {
                for j in 0 ..< matrix.size.height {
                    if matrix.value(i,j) {
                        space.setValue(position.x - pivit.x + i, position.y - pivit.y + j, value: true)
                    }
                }
            }
            return space
        }
    }
    
    let bricks: [Brick]
    var canvasWidth: Int
    var canvasHeight: Int
    var canvas: Matrix
    var currentBrick: Brick!
    var currentPosition: Point!
    
    var gameState: State = .Start
    var score: Int = 0
    var level: Int = 1
    
    var delegate: TetrisBrainDelegate!
    
    enum State {
        case Start, SelectBrick, Drop, Land, End
        
        mutating func change() {
            switch self {
            case .Start:
                self = .SelectBrick
            case .SelectBrick:
                self = .Drop
            case .Drop:
                self = .Drop
            case .Land:
                self = .SelectBrick
            default:
                return
            }
        }
    }
    
    private func placeBrick() -> Point {
        var newPoint = Point(x: canvasWidth/2, y: 0)
        newPoint.y = currentBrick.pivit.y - currentBrick.matrix.size.height + 1
        print("Position: (\(newPoint.x),\(newPoint.y))")
        return newPoint
    }
    
    private func randomBrick() -> Brick {
        let randNum = Int(arc4random_uniform(UInt32(bricks.count)))
        print("Brick #\(randNum) added.")
        return bricks[randNum]
    }
    
    private func checkLines() -> [Int] {
        var linesThatCanBeCleared: [Int] = []
        for currentLine in 0 ..< canvas.size.height {
            var canBeCleared = true
            for i in 0 ..< canvas.size.width {
                if canvas.value(i, currentLine) == false {
                    canBeCleared = false
                    break
                }
            }
            if canBeCleared {
                linesThatCanBeCleared.append(currentLine)
            }
        }
        score += level * linesThatCanBeCleared.count * 10
        level = score/100 + 1
        if linesThatCanBeCleared.count != 0 {
            delegate.scoreDidChange()
        }
        return linesThatCanBeCleared
    }
    
    private func clearLine(matrix: Matrix, line: Int) -> Matrix {
        let newMatrix = matrix
        for (var currentLine: Int = line - 1; currentLine >= 0; currentLine--) {
            for i in 0 ..< canvas.size.width {
                newMatrix.setValue(i, currentLine + 1, value: matrix.value(i, currentLine))
            }
        }
        for i in 0 ..< canvas.size.width {
            newMatrix.setValue(i, 0, value: false)
        }
        return newMatrix
    }
    
    private func clearLines(matrix: Matrix, lines: [Int]) -> Matrix {
        var newMatrix = matrix
        for i in lines {
            newMatrix = clearLine(newMatrix, line: i)
        }
        return newMatrix
    }
    
    private func checkGameOver() -> Bool {
        if canvas.value(canvasWidth/2 - 1, 0) || canvas.value(canvasWidth/2, 0) ||
            canvas.value(canvasWidth/2 + 1, 0) || canvas.value(canvasWidth/2 + 2, 0) {
            return true
        }
        return false
    }
    
    func moveLeft() {
        if gameState == .Drop && currentBrick.canMoveLeft(currentPosition, space: canvas) {
            currentPosition.x--
        }
    }
    
    func moveRight() {
        if gameState == .Drop && currentBrick.canMoveRight(currentPosition, space: canvas) {
            currentPosition.x++
        }
    }
    
    func moveDown() {
        if gameState == .Drop {
            let fallCount = currentBrick.canFall(currentPosition, space: canvas)
            if fallCount > 0 {
                currentPosition.y += fallCount
            }
            changeState()
        }
    }
    
    func rotate() {
        if gameState == .Drop && currentBrick.canRotate(currentPosition, space: canvas) {
            currentBrick = currentBrick.rotatedBrick()
        }
    }
    
    func currentBrickIsAtPosition(x: Int, _ y: Int) -> Bool {
        if gameState == .Drop {
            for i in 0 ..< currentBrick.matrix.size.width {
                for j in 0 ..< currentBrick.matrix.size.height {
                    if currentPosition.x - currentBrick.pivit.x + i == x && currentPosition.y - currentBrick.pivit.y + j == y && currentBrick.matrix.value(i,j) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func changeState() {
        switch gameState {
        case .Start:
            score = 0
            level = 1
        case .SelectBrick:
            currentBrick = randomBrick()
            currentPosition = placeBrick()
        case .Drop:
            if currentBrick.canDrop(currentPosition, space: canvas) {
                currentPosition.y++
            } else {
                //print("Cannot Drop!!!")
                gameState = .Land
                fallthrough
            }
            //print("Position: (\(currentPosition.x),\(currentPosition.y))")
        case .Land:
            canvas = currentBrick.addToSpace(currentPosition, space: canvas)
            canvas = clearLines(canvas, lines: checkLines())
            if checkGameOver() {
                gameState = .End
                fallthrough
            }
        case .End:
            delegate.gameDidEnd()
        }
        gameState.change()
    }
    
    init(width: Int, height: Int) {
        canvasWidth = width
        canvasHeight = height
        canvas = Matrix(size: Size(width: canvasWidth, height: canvasHeight))
        
        bricks = [
            
            Brick(matrix: Matrix(size: Size(width: 2, height: 2),   // X X
                data: [true,true,true,true]),                       // X X
                pivit: Point(x: 0,y: 0)),
            
            Brick(matrix: Matrix(size: Size(width: 1, height: 4),   // X
                data: [true,true,true,true]),                       // X
                pivit: Point(x: 1,y: 2)),                           // X
            Brick(matrix: Matrix(size: Size(width: 4, height: 1),   // X
                data: [true,true,true,true]),
                pivit: Point(x: 2,y: 1)),
            
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),   //   X
                data: [false,true,true,true,false,true]),           // X X X
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),
                data: [true,false,true,true,true,false]),
                pivit: Point(x: 0,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [false,true,false,true,true,true]),
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [true,true,true,false,true,false]),
                pivit: Point(x: 1,y: 0)),
            
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),   // X X
                data: [false,true,true,true,true,false]),           //   X X
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),
                data: [true,false,true,true,false,true]),
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [false,true,true,true,true,false]),
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [true,true,false,false,true,true]),
                pivit: Point(x: 1,y: 1)),
            
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),   // X
                data: [true,true,true,false,true,false]),           // X X X
                pivit: Point(x: 0,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),
                data: [false,true,false,true,true,true]),
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [true,false,false,true,true,true]),
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [true,true,true,false,false,true]),
                pivit: Point(x: 1,y: 0)),
            
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),   //     X
                data: [true,true,false,true,false,true]),           // X X X
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 2, height: 3),
                data: [true,false,true,false,true,true]),
                pivit: Point(x: 0,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [false,false,true,true,true,true]),
                pivit: Point(x: 1,y: 1)),
            Brick(matrix: Matrix(size: Size(width: 3, height: 2),
                data: [true,true,true,true,false,false]),
                pivit: Point(x: 1,y: 0))
        ]
    }

}
