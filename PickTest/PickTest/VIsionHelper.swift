//
//  VIsionHelper.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/11/29.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

/*
#if os (OSX)
    import Cocoa
    typealias XColor = NSColor
    typealias XImage = NSImage
#elseif os(iOS)
    import UIKit
    typealias XColor = UIColor
    typealias XImage = UIImage
#endif
*/

class VisionHelper
{
    var view : SCNView!
    private var lastDate: Date?
    
    private var translucentObjects : [SCNNode:Double] = [:]
    
    func elapsedTime() -> Double {
        let now = Date()
        if let date = lastDate {
            let elapsed = now.timeIntervalSince(date)
            lastDate = now
            
            return elapsed
        }
        
        lastDate = now
        return 0
    }
    
    func applyHelper(position : CGPoint) {
        
        let hitResults : [SCNHitTestResult] =
            view.hitTest(position, options: [:])
        
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let hit_node = hitResults.first!.node
            
            //透明化ノードか？
            if let parent = hit_node.parent, let name = parent.name {
                if name == "translucent" {
                    makeTranslucent(node:hit_node)
                }else {
                    indicatePicking(node: hit_node)
                }
            }
        }
    }
    
    //中心のオブジェクトを赤く
    func indicatePicking(node : SCNNode) {
        if node.name == "view", let material = node.geometry!.firstMaterial{
            // highlight it
            let pre_material = [material.diffuse.contents]
            print(pre_material)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.multiply.contents = XColor.white
              //  material.emission.contents = XColor.black
             
              //  material.diffuse.contents = pre_material
                SCNTransaction.commit()
            }
            
            
//            material.diffuse.contents = XColor.red.withAlphaComponent(0.9)
//            material.emission.contents = XColor.red
            material.multiply.contents = XColor.red
           // material.diffuse.contents = XColor.red
            print(material.name)
            SCNTransaction.commit()
        }
    }
    
    //手前の壁を透明に(親が"translucent"のノードだけ)
    func makeTranslucent(node : SCNNode) {
        if translucentObjects[node] == nil {
            translucentObjects[node] = 2.0
            
            animateOpacity(node: node, target: 0.01, dur:0.5)
        }else {
            translucentObjects[node] = 2.0
        }
    }
    

    
    func update() {
        let time = elapsedTime()
        
        //print (translucentObjects)
        for item in translucentObjects {
            translucentObjects[item.key] = item.value - time
            
            if item.value < 0 {
                animateOpacity(node: item.key, target: 1.0, dur:0.5)
                translucentObjects.removeValue(forKey: item.key)
            }
        }
    }
    
    func animateOpacity(node : SCNNode, target : CGFloat, dur : Double) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = dur
        
        node.opacity = target
        
        // on completion - unhighlight
        SCNTransaction.completionBlock = {
            SCNTransaction.begin()
            SCNTransaction.commit()
        }

        SCNTransaction.commit()
    }
    
    
}

