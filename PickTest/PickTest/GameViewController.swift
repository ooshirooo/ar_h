//
//  GameViewController.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/10/27.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController, SCNSceneRendererDelegate {
    
    var appCore = AppCore()

    var picker : ObjectPicker = ObjectPicker()
    var pickState : Bool = false
    
    var timer : Timer!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appCore.makeWorldModel()

        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = appCore.getScene()
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        //scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.blue
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
        
        scnView.delegate = self
        
        picker.renderer = scnView
        picker.worldNode = appCore.getWorldNode()
        
        
        timer = Timer(timeInterval: 0.1, target: self, selector: #selector(self.onTimer), userInfo: nil, repeats: true)
        timer.fire()
        
        RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
        
//          Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(GameViewController.foundCenter), userInfo: nil, repeats: true)
    }
    
    @objc func onTimer(timer: Timer){
        picker.updateOutofRenderLoop()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        picker.updateInRenderLoop()
    }
    
    override func keyDown(with event: NSEvent) {
        if let key = event.characters {
            if(key == " ") {
                if !pickState {
                    
                    let pos = CGPoint(x:view.frame.width/2, y:view.frame.height/2)
                    
                    picker.pick(at: pos)
                    pickState = true
                    print("pick")
                }else {
                    picker.drop()
                    pickState = false
                    print("drop")

                }
            }
        }
    }
    
    
    @objc func foundCenter(){
        let scnView = self.view as! SCNView
        if let hitResults:[SCNHitTestResult] = scnView.hitTest(CGPoint(x:view.frame.width/2, y:view.frame.height/2), options: [:]){
            
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // retrieved the first clicked object
                let result = hitResults[0]
                
                // get its material
//                if result.node.name == "body"{
                let material = result.node.geometry!.firstMaterial!
                let pre_material = result.node.geometry!.firstMaterial?.diffuse.contents
                
                print(pre_material)
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                  
                    
                    SCNTransaction.commit()
                }
               // result.node.geometry!.firstMaterial!.diffuse.contents = NSColor.red
                result.node.geometry!.firstMaterial!.diffuse.contents = NSColor.red
                //material.emission.contents = NSColor.red
                
                SCNTransaction.commit()
            //}
            }
            
        }
    }
    
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
    
    
}
