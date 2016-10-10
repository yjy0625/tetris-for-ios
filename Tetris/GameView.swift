//
//  GameView.swift
//  Tetris
//
//  Created by Day Day Up on 7/2/16.
//  Copyright © 2016 Jingyun Yang. All rights reserved.
//

import UIKit

protocol GameViewDataSource: class {
    func drawForPosition(x: Int, _ y: Int) -> Bool
    func drawBrickForPosition(x: Int, _ y: Int) -> Bool
}

class GameView: UIView {
    
    enum BrickType {
        case Falling, Landed
    }

    var dataSource: GameViewDataSource!
    var brickWidth: Int = 0
    var brickHeight: Int = 0
    var borderLength: CGFloat = 0.0
    
    private func drawAtPosition(x: Int, _ y: Int, brickType: BrickType) {
        let drawWidth: CGFloat = self.frame.width/CGFloat(brickWidth) - borderLength*2
        let drawHeight: CGFloat = self.frame.height/CGFloat(brickHeight) - borderLength*2
        let startingPoint: CGPoint = CGPointMake(self.frame.width/CGFloat(brickWidth)*CGFloat(x) + borderLength, self.frame.height/CGFloat(brickHeight)*CGFloat(y) + borderLength)
        let newPath: UIBezierPath = UIBezierPath(rect: CGRectMake(startingPoint.x, startingPoint.y, drawWidth, drawHeight))
        UIColor.whiteColor().set()
        switch brickType {
        case .Landed:
            newPath.fill()
        case .Falling:
            newPath.lineWidth = 3.0
            newPath.stroke()
        }
    }
    
    override func drawRect(rect: CGRect) {
        for x in 0 ..< brickWidth {
            for y in 0 ..< brickHeight {
                if dataSource.drawForPosition(x,y) {
                    drawAtPosition(x,y, brickType: .Landed)
                }
                if dataSource.drawBrickForPosition(x,y) {
                    drawAtPosition(x,y, brickType: .Falling)
                }
            }
        }
    }
    
}
