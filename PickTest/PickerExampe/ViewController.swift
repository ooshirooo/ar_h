//
//  ViewController.swift
//  PickerExampe
//
//  Created by Yuhei Akamine on 2017/11/01.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ImageIO

class ViewController: UIViewController, ARSCNViewDelegate, SCNSceneRendererDelegate {

    
    @IBOutlet weak var pickButton: UIButton!
    
    @IBOutlet weak var imageGIFView: UIImageView!
    
    @IBOutlet var sceneView: ARSCNView!
    
    var label = UILabel()
    
    var sceneController : SceneController = SceneController()
    var musicController = MusicController()

    var appCore = AppCore()
    var picker : ObjectPicker = ObjectPicker()
    var visionHelper : VisionHelper = VisionHelper()
    var timer : Timer!

    var planeFound : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
       // sceneView.showsStatistics = true
        
        //デバッグ用のてんてん
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints

        
        //sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the scene to the view
        sceneView.scene = appCore.getScene()
        
        picker.renderer = sceneView
        picker.worldNode = appCore.getWorldNode()
        
        timer = Timer(timeInterval: 2, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
        timer.fire()
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)

        //gameBGM
        musicController.readMusicFile(musicName: "okataduke", repeatCount: -1)
        musicController.play(name: "okataduke")
        
        //tapSEの準備
        musicController.readMusicFile(musicName: "pick", repeatCount:1)
        musicController.readMusicFile(musicName: "drop", repeatCount: 1)
        
        
        // add a tap gesture recognizer
        let tapGesture = UILongPressGestureRecognizer(target:self, action: #selector(ViewController.handleTap(sender:)))
        tapGesture.minimumPressDuration = 0
        //sceneView.addGestureRecognizer(tapGesture)
        pickButton.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func backToTitleButton(_ sender: Any) {
        musicController.stop(name: "okataduke")
    }
    
    @objc func onTimer(timer : Timer) {
        picker.updateOutofRenderLoop()
        
        if view != nil && visionHelper.view != nil {
            visionHelper.applyHelper(position: CGPoint(x:view.frame.width/2, y:view.frame.height/2))
            visionHelper.update()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        visionHelper.view = sceneView
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let image = UIImage.gif(name: "IPhoneImage")
        imageGIFView.image = image
        
        // Lavelに関する設定
        // Labelを作成.
        label.frame = CGRect(x:150, y:200, width:600, height:70)
        // 背景色を指定する.
        label.backgroundColor = UIColor(red: 1.0, green:0.373, blue:0.812, alpha: 1.0)
        // 枠を丸くする.
        label.layer.masksToBounds = true
        // コーナーの半径.
        label.layer.cornerRadius = 20.0
        // Labelに文字を代入.
        label.text = "えほんに　まほうを　かけよう"
        
        // フォントのサイズを変更
        label.font = UIFont.systemFont(ofSize: 36)
        
        // 文字の色を白にする.
        label.textColor = UIColor.white
        // Textを中央寄せにする.
        label.textAlignment = NSTextAlignment.center
        // 配置する座標を設定する.
        label.layer.position = CGPoint(x: self.view.bounds.width/2,y: 120)
        // ViewにLabelを追加.
        self.view.addSubview(label)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        print("plane found")
//        if !planeFound {
//            //sceneController.world.simdTransform = anchor.transform.
//            print("world placed")
//            planeFound = true
//
//            appCore.sceneController.replaceBaseNode( SCNMatrix4(anchor.transform))
//            appCore.makeWorldModel()
//
//            return SCNNode()
//        }
//        return nil
//    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // DispatchQueue.main.async {
        if planeFound != true {
                // 平面を表現するノードを追加する
                //node.addChildNode(PlaneNode(anchor: planeAnchor) )
                
                
                self.planeFound = true
                sceneView.debugOptions.remove(sceneView.debugOptions)
                DispatchQueue.main.async {
                 if (self.imageGIFView != nil) { self.imageGIFView.isHidden = true }
                 self.label.isHidden = true;
                }
            self.appCore.sceneController.replaceBaseNode( SCNMatrix4(anchor.transform))
                self.self.appCore.makeWorldModel()
//                self.sceneController.replaceBaseNode( SCNMatrix4(anchor.transform))
//                self.sceneController.makePhysicsBodies()
            }
            
            
    //115    }
    }

    
    @objc func handleTap(sender: UITapGestureRecognizer) {

        if sender.state == .began {
            
            print("pick")
            musicController.play(name: "pick")
            pickButton.setImage(UIImage(named: "pick_button"), for: .normal)
            //pickButton.setBackgroundImage(UIImage(named : "pick_button"), for: .normal)
            pickButton.setBackgroundImage(UIImage(named : "pick_button"), for: .normal)
            print(view.bounds)
            let loc = CGPoint(x:view.bounds.width/2, y:view.bounds.height/2)
//            let loc = sender.location(in: self.sceneView)
            picker.pick(at:loc)
        }else if sender.state == .ended {
            print("drop")
            musicController.play(name: "drop")
            //handImage.image = UIImage(named : "drop")
            pickButton.setImage(UIImage(named: "drop_button"), for: .normal)
            pickButton.setBackgroundImage(UIImage(named: "drop_button"), for: UIControlState.normal)
            picker.drop()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        picker.updateInRenderLoop()

    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    

}
