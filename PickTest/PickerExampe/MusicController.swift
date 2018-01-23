//
//  MusicController.swift
//  PickTest
//
//  Created by Risa KAKAZU on 2017/11/19.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import AVFoundation

class MusicController :NSObject, AVAudioPlayerDelegate {
    var audioPlayers : Dictionary<String, AVAudioPlayer> = [:]
    
    
    
    func readMusicFile (musicName: String, repeatCount: Int){
        
        let audioPath = Bundle.main.path(forResource: musicName, ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        
        var audioPlayer : AVAudioPlayer!
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            
        } catch let error as NSError {
            audioError = error
            audioError = nil
        }
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = repeatCount
        //audioPlayer.play()
        if audioPlayers[musicName] == nil{
        audioPlayers[musicName] = audioPlayer!
        }
    }
    
    func play(name:String)
    {
        if let player = audioPlayers[name] {
            player.play()
        }
    }
    
    func stop(name:String)
    {
        if let player = audioPlayers[name] {
            player.stop()
            
        }
    }
    
}



