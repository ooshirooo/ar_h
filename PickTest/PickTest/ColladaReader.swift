//
//  DaeReader.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/11/14.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

class ColladaReader
{
    var scene: SCNScene!
    
    func open(forResource name:String, withExtension ext:String)
    {
        let url = Bundle.main.url(forResource: name, withExtension: ext)
        
        let scene_source = SCNSceneSource(url:url!, options:nil)
        scene = scene_source?.scene(options:nil)
        
        if(scene == nil)
        {
            fatalError()
        }
    }
    
    func getNode(withName name:String) -> SCNNode!
    {
        //読み込んだシーンから必要なノードを取り出す
        guard let node = scene.rootNode.childNode(withName: name, recursively: true) else {
            fatalError("the node is not found")
        }
        
//        let parent = SCNNode()
//        parent.addChildNode(node.clone())
        
        return node.clone()
    }
    
}
