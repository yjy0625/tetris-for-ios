//
//  MenuViewController.swift
//  Tetris
//
//  Created by Day Day Up on 7/1/16.
//  Copyright © 2016 Jingyun Yang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var creditsBtn: UIButton!

    @IBAction func play(sender: UIButton) {
        playBtn.enabled = false
        optionsBtn.enabled = false
        creditsBtn.enabled = false
        UIView.animateWithDuration(0.5, animations: {
            self.setContentAlpha(0.0)
            }, completion: { _ in
                self.performSegueWithIdentifier("Start Game", sender: self.playBtn)
            }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentAlpha(0.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.5, animations: {
            self.setContentAlpha(1.0)
            })
    }
    
    private func setContentAlpha(alpha: CGFloat) {
        titleLabel.alpha = alpha
        playBtn.alpha = alpha
        optionsBtn.alpha = alpha
        creditsBtn.alpha = alpha
    }

}

