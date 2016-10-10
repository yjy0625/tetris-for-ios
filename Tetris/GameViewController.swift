//
//  GameViewController.swift
//  Tetris
//
//  Created by Day Day Up on 7/2/16.
//  Copyright © 2016 Jingyun Yang. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, GameViewDataSource, TetrisBrainDelegate, ContainerViewControllerDelegate {

    @IBOutlet weak var myGameView: GameView!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    
    @IBOutlet weak var title0: UILabel!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var myContainerView: UIView!
    
    @IBAction func pauseBtn(sender: UIButton) {
        if myContainerView.hidden && myBrain.gameState != .End {
            containingViewController.noticeLabel.textColor = UIColor.whiteColor()
            containingViewController.noticeLabel.text = "Paused"
            pauseGame()
        }
        else if !myContainerView.hidden && myBrain.gameState != .End {
            continueGame()
        }
    }
    
    var timer: NSTimer!
    var myBrain: TetrisBrain!
    var currentScore: Int = 0
    var containingViewController: ContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetGame()
        setGestureRecognizers()
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.5, animations: { self.setContentAlpha(1.0) })
    }
    
    func setContentAlpha(alpha: CGFloat) {
        myGameView.alpha = alpha
        title0.alpha = alpha
        title1.alpha = alpha
        title2.alpha = alpha
        button.alpha = alpha
        scoreLabel.alpha = alpha
        levelLabel.alpha = alpha
        plusLabel.alpha = alpha / 2
        myContainerView.alpha = alpha
    }
    
    func setGestureRecognizers() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "moveLeft")
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "moveRight")
        rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        let downSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "moveDown")
        downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "rotate")
        myGameView.addGestureRecognizer(leftSwipeGestureRecognizer)
        myGameView.addGestureRecognizer(rightSwipeGestureRecognizer)
        myGameView.addGestureRecognizer(downSwipeGestureRecognizer)
        myGameView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func resetGame() {
        myBrain = TetrisBrain(width: 10, height: 20)
        myBrain.delegate = self
        
        myGameView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        myGameView.brickWidth = myBrain.canvasWidth
        myGameView.brickHeight = myBrain.canvasHeight
        myGameView.borderLength = 3.0
        myGameView.dataSource = self
        
        setContentAlpha(0.0)
        plusLabel.font = UIFont.systemFontOfSize(24.0, weight: UIFontWeightLight)
        plusLabel.text = "Tap to Start"
        currentScore = 0
        scoreLabel.text = "0"
        levelLabel.text = "1"
        
        myContainerView.hidden = true
        
        timer = NSTimer(timeInterval: 2.0/(Double(myBrain.level)+1.0), target: self, selector: "update", userInfo: nil, repeats: true)
        timer.invalidate()
    }
    
    func startGame() {
        timer.invalidate()
        timer = NSTimer(timeInterval: 2.0/(Double(myBrain.level)+1.0), target: self, selector: "update", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    func pauseGame() {
        timer.invalidate()
        myGameView.userInteractionEnabled = false
        myContainerView.alpha = 0.0
        myContainerView.hidden = false
        UIView.animateWithDuration(0.2, animations: { self.myContainerView.alpha = 1.0 })
    }
    
    func continueGame() {
        UIView.animateWithDuration(0.2, animations: { self.myContainerView.alpha = 0.0 }, completion: { _ in
            self.myContainerView.hidden = true
            self.myGameView.userInteractionEnabled = true
            if self.myBrain.gameState != .Start {
                self.startGame()
            }
        })
    }
    
    // - MARK Container View Controller Delegate
    
    func leaveGame() {
        UIView.animateWithDuration(0.5, animations: { self.setContentAlpha(0.0) }, completion: { _ in
            self.performSegueWithIdentifier("Leave Game", sender: self)
            })
    }
    
    func replayGame() {
        UIView.animateWithDuration(0.5, animations: { self.setContentAlpha(0.0) }, completion: {
            _ in
            self.resetGame()
            self.updateDisplay()
            self.myGameView.userInteractionEnabled = true
            UIView.animateWithDuration(0.5, animations: { self.setContentAlpha(1.0) })
        })
    }
    
    // Updates & Gestures
    
    func update() {
        myBrain.changeState()
        updateDisplay()
    }
    
    func updateDisplay() {
        myGameView.setNeedsDisplay()
    }
    
    func moveLeft() {
        myBrain.moveLeft()
        updateDisplay()
    }
    
    func moveRight() {
        myBrain.moveRight()
        updateDisplay()
    }
    
    func moveDown() {
        myBrain.moveDown()
        updateDisplay()
    }
    
    func rotate() {
        if myBrain.gameState == .Drop {
            myBrain.rotate()
            updateDisplay()
        } else if myBrain.gameState == .Start && !timer.valid {
            plusLabel.alpha = 1.0
            UIView.animateWithDuration(1.0, animations: { self.plusLabel.alpha = 0.0 }, completion: { _ in
                self.plusLabel.font = UIFont.systemFontOfSize(48.0, weight: UIFontWeightLight)
            })
            startGame()
        }
    }
    
    // - MARK Game View Data Source
    
    func drawForPosition(x: Int, _ y: Int) -> Bool {
        return myBrain.canvas.value(x,y)
    }
    
    func drawBrickForPosition(x: Int, _ y: Int) -> Bool {
        return myBrain.currentBrickIsAtPosition(x,y)
    }
    
    // - MARK Tetris Brain Delegate
    
    func scoreDidChange() {
        let plus = myBrain.score - currentScore
        plusLabel.text = "+\(plus)"
        plusLabel.alpha = 1.0
        UIView.animateWithDuration(1.0, animations: { self.plusLabel.alpha = 0.0 })
        currentScore = myBrain.score
        scoreLabel.text = "\(myBrain.score)"
        levelLabel.text = "\(myBrain.level)"
        
        timer.invalidate()
        startGame()
    }
    
    func gameDidEnd() {
        containingViewController.noticeLabel.textColor = UIColor.redColor()
        containingViewController.noticeLabel.text = "Game Over"
        pauseGame()
    }
    
    // - MARK Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dvc = segue.destinationViewController as? ContainerViewController {
            containingViewController = dvc
            containingViewController.delegate = self
        }
    }
}
