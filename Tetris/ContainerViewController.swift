//
//  ContainerViewController.swift
//  Tetris
//
//  Created by Day Day Up on 7/2/16.
//  Copyright © 2016 Jingyun Yang. All rights reserved.
//

import UIKit

protocol ContainerViewControllerDelegate {
    func leaveGame()
    func replayGame()
}

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var noticeLabel: UILabel!
    var delegate: ContainerViewControllerDelegate!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
    }
    
    @IBAction func backButton(sender: UIButton) {
        delegate.leaveGame()
    }
    
    @IBAction func replayButton(sender: UIButton) {
        delegate.replayGame()
    }

}
