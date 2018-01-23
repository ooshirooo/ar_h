//
//  tutorialController.swift
//  PickTest
//
//  Created by yuka kiyuna on 2017/12/06.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class tutorialController : UIViewController {
    
    var musicController = MusicController()
    

    @IBOutlet weak var navigationText: UIImageView!
    
    var playerLayer : AVPlayerLayer?
    var playerItem : AVPlayerItem?
    var videoPlayer : AVPlayer!
    let movieList = ["heimenkenchi","navigate_pick"]
    let textlist = ["move_text1.txt","move_text2.txt"]
    var playcount = 0
    let buttonforward = UIButton()
    let buttonback = UIButton()
    
    override func viewDidLoad() {
        
        musicController.readMusicFile(musicName: "tutorial", repeatCount: -1)
        musicController.play(name: "tutorial")
        
        musicController.readMusicFile(musicName: "tap", repeatCount: 1)
        playVideo(fileName: movieList[playcount], type:"mp4")
        
        playcount = 0
        
        // ボタンの設置座標とサイズを設定する.
        buttonforward.frame = CGRect(x:self.view.frame.size.width*(6/7), y:self.view.frame.size.height*(4/5), width:100, height:100)
        // buttonにimageを添付
        buttonforward.setImage(UIImage(named: "next_2"), for: .normal)
        // 実際にviewに表示する
        view.addSubview(buttonforward)
        // buttonforwardが押された際のアクション
        buttonforward.addTarget(self, action: #selector(tutorialController.countup(sender: )), for: .touchUpInside)
        
        buttonback.frame = CGRect(x:self.view.frame.size.width*(1/22), y:self.view.frame.size.height*(4/5), width:100, height:100)
        buttonback.setImage(UIImage(named: "back_2"), for: .normal)
        view.addSubview(buttonback)
        buttonback.addTarget(self, action: #selector(tutorialController.countdown(sender: )), for: .touchUpInside)
        
    }
    
    @objc func countup(sender: Any) { // buttonの色を変化させるメソッド
        videoPlayer.pause()
        playcount += 1
        musicController.play(name: "tap")
        if playcount == 1 {
            buttonforward.setImage(UIImage(named: "play"), for: .normal)
        }
        if playcount == movieList.count{ //もし動画全部終わったらAR画面に遷移する
            change_screen()
            musicController.stop(name: "tutorial")
            
        }else{
            
            changeNavigateText(textname:textlist[playcount])
            playVideo(fileName:movieList[playcount], type:"mp4")
            
        }
    }
    
    @objc func countdown(sender: Any) {
        videoPlayer.pause()
        playcount -= 1
        musicController.play(name: "tap")
        if playcount == 1 {
            buttonforward.setImage(UIImage(named: "play"), for: .normal)
        }else{
            buttonforward.setImage(UIImage(named: "next_2"), for: .normal)
        }
        if playcount < 0 {//movieList.count //もし動画全部終わったらAR画面に遷移する
            back_screen()
            musicController.stop(name: "tutorial")
            
        }else{
            changeNavigateText(textname:textlist[playcount])
            playVideo(fileName:movieList[playcount], type:"mp4")
            
        }
    }
    
    //    @IBAction func playNextVideo(_ sender: Any) {
    //        videoPlayer.pause()
    //        playcount += 1
    //        if playcount == movieList.count{ //もし動画全部終わったらAR画面に遷移する
    //           change_screen()
    //
    //
    //        }else{
    //            changeNavigateText()
    //            playVideo(fileName:movieList[playcount], type:"mp4")}
    //    }
    
    
    //    @IBOutlet weak var backButton: UIButton!
    
    //    @IBAction func backScreen(_ sender: Any) {
    //    back_screen()
    //    }
    
    
    func playVideo(fileName:String,type:String) {
        if let path = Bundle.main.path(forResource: fileName, ofType: type)
        {
            let fileURL = URL(fileURLWithPath: path)
            let avAsset = AVAsset(url: fileURL)
            
            // AVPlayerに再生させるアイテムを生成
            playerItem = AVPlayerItem(asset: avAsset)
            // AVPlayerを生成
            videoPlayer = AVPlayer(playerItem: playerItem)
            
            playerLayer = AVPlayerLayer(player: videoPlayer)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            //playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
            
            //サイズを決める
            //playerLayer?.frame = CGRect(x:100, y:10, width:self.view.frame.size.width*(4/5), height:self.view.frame.size.height*(4/5))
            playerLayer?.frame = CGRect(x:300, y:150, width:600, height:375)
            
            self.view.layer.addSublayer(playerLayer!)
            
            videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none;
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.stateEnd),
                                                   name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"),
                                                   object: videoPlayer.currentItem)
            
            videoPlayer.play()
            
            
        }
    }
    
    @objc func stateEnd(notification: NSNotification) {
        let avPlayerItem = notification.object as? AVPlayerItem
        avPlayerItem?.seek(to: kCMTimeZero)
    }
    
    //画面を遷移させる
    func change_screen(){
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AR") as! ViewController
        self.present(nextView, animated: true, completion: nil)
    }
    
    func back_screen(){
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "Title") as! TitleController
        self.present(nextView, animated: true, completion: nil)
    }
    
    //次のテキストを出す
    func changeNavigateText(textname:String) {
        navigationText.image = UIImage(named: textname)
    }
    
    
}
