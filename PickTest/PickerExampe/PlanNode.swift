//
//  PlanNode.swift
//  PickTest
//
//  Created by Risa KAKAZU on 2017/11/19.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class PlaneNode: SCNNode {
    
    fileprivate override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        geometry = SCNPlane(width: CGFloat(2 * anchor.extent.x), height: CGFloat( 2 * anchor.extent.z))
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIImage(named:"ground")
        let planeNode = SCNNode(geometry: geometry)
        
        planeNode.geometry?.firstMaterial = planeMaterial
        planeNode.makePhysicsBody(type: .static)
        SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        
        physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: geometry!, options: nil))
        physicsBody?.friction = 1
        physicsBody?.categoryBitMask = 2
    }
    
    func update(anchor: ARPlaneAnchor) {
        (geometry as! SCNPlane).width = CGFloat(anchor.extent.x)
        (geometry as! SCNPlane).height = CGFloat(anchor.extent.z)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
    }
}
