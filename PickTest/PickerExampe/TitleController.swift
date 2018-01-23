//
//  TitleController.swift
//  PickTest
//
//  Created by Risa KAKAZU on 2017/11/19.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import UIKit

class TitleController: UIViewController {
    
    var musicController = MusicController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        musicController.readMusicFile(musicName: "title", repeatCount: -1)
        musicController.play(name: "title")
    }
    
    
    @IBAction func startButton(_ sender: Any) {
        musicController.stop(name: "title")
    }
    
    
    
    
}


