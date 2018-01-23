//
//  WorldModel.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/11/01.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

class WorldModel : NSObject, SCNPhysicsContactDelegate
{
    var sceneController : SceneController
    
    init(sceneController controller:SceneController) {
        sceneController = controller
        super.init()

    }
    
    //出したいオブジェクトを用意
    func make() {
        sceneController.makeSceneFundamentals()

        sceneController.importScene(withName: "art.scnassets/house.scn")
        sceneController.makePhysicsBodies()
        
        //sceneController.scene.physicsWorld.contactDelegate = self

        //アニメーションするオブジェクトもdynamicでOK
        guard let node = sceneController.importNode(name: "toy2_anime", extention:"scn", nodeName: "Box001_003") else {
            fatalError()
        }
        SceneController.makePhysicsBodies(node) // static methodなので「クラス名」を使う
        //位置も変更可能です
        node.position.y += 0
        node.position.x += 1
        
        sceneController.scene.rootNode.printChildren()
        

    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        var placed : SCNNode!
        
        if contact.nodeA == sceneController.floorNode {
            placed = contact.nodeB
        }else if contact.nodeB == sceneController.floorNode {
            placed = contact.nodeA
        }
        
        if let placed_node = placed {
            //placed_node.position = placed_node.presentation.position
            
            
            if(placed_node.isTagged(name: "droped")) {
                print (placed_node.name as Any)
         //       placed_node.position = placed_node.presentation.position
                placed_node.removeTag(name: "droped")
                
                if let parent = placed_node.parent {
                    parent.position = parent.convertPosition(placed_node.presentation.position, to: sceneController.worldNode)
                    placed_node.position = SCNVector3()
                    
                    placed_node.removeFromParentNode()
                    placed_node.physicsBody = nil
                    SceneController.makePhysicsBodies(placed_node)
                    parent.addChildNode(placed_node)
                }
            }
        }
    }
}
