//
//  WorldView.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/11/01.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit
import QuartzCore

#if os (OSX)
    import Cocoa
    typealias XColor = NSColor
    typealias XImage = NSImage
#elseif os(iOS)
    import UIKit
    typealias XColor = UIColor
    typealias XImage = UIImage
#endif



class SceneController
{
    var scene : SCNScene = SCNScene()
    var worldNode : SCNNode = SCNNode()
    var floorNode : SCNNode!
    
    static let physicsTypePrefixLen = 2
    static let physicsTypePrefixStatic = "S_"
    static let physicsTypePrefixNoPhysics = "N_"
    static let physicsTypePrefixKinematic = "K_"
    
    static func prefixToType(_ name : String) -> SCNPhysicsBodyType! {
        
        switch String(name.prefix(physicsTypePrefixLen)) {
        case physicsTypePrefixStatic:
            return .static
        case physicsTypePrefixNoPhysics:
            return nil
        case physicsTypePrefixKinematic:
            return .kinematic
        default:
            return .dynamic
        }
    }
    
    static func makePhysicsBodies(_ node : SCNNode) {


        if let name = node.name, let type = prefixToType(name) {
            if node.childNode(withName: "view", recursively: false) != nil {

                let phy : SCNPhysicsBody
                
                if let body = node.childNode(withName: "body", recursively: false) {
                    guard let body_geo = body.geometry else {
                        fatalError("body must have geometry("+name+")")
                    }
                    phy = SCNPhysicsBody(type: type,
                                         shape: SCNPhysicsShape(geometry:body_geo, options:[SCNPhysicsShape.Option.type:SCNPhysicsShape.ShapeType.boundingBox,
                                                                                            SCNPhysicsShape.Option.collisionMargin:0.0]))
                } else {
                    fatalError("a physics body node is required")
                }
                
                phy.contactTestBitMask = 1
                node.physicsBody = phy
            }
        }else {
            for n in node.childNodes {
                makePhysicsBodies(n)
            }
        }
    }
    
    
    static func isPhysicsTypeCorrect(_ node:SCNNode) -> Bool {
        if let name = node.name, let body = node.physicsBody {
            return prefixToType(name) == body.type
        }
        return true
    }
    
    init()
    {
        worldNode.name = "N_simulation_world_node"
        
        scene.rootNode.addChildNode(worldNode)

    }
    
    func importScene(withName name:String)
    {
        // create a new scene
        let read_scene = SCNScene(named: name)!
        
        for n in read_scene.rootNode.childNodes {
            worldNode.addChildNode(n)
        }
        
    }
    
    func importNode(name:String, extention:String, nodeName:String) -> SCNNode!
    {
        let reader = ColladaReader()
        reader.open(forResource: name, withExtension: extention)
        
        let node = reader.getNode(withName: nodeName)
        
        //blenderの座標系とSceneKitの座標系が異なるので変換する
        //node?.rotation = SCNVector4(1,0,0, -Float.pi/2)
//        anim_node?.makePhysicsBody(type: .dynamic, recursive:false)
        
        //let base = SCNNode()
        //base.name = node!.name! + "_base"
        //base.addChildNode(node!)
        worldNode.addChildNode(node!)
        
        return node
    }
    
    func replaceBaseNode(_ transform:SCNMatrix4)
    {
        worldNode.transform = transform
    }
    
    func makeSceneFundamentals()
    {
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        camera.zFar = 100
        camera.zNear = 0.001
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 1)
        cameraNode.rotation = SCNVector4(1,0,0, CGFloat.pi / 180 * -45)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = XColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

       // scene.physicsWorld.
        
        let ar_material = SCNMaterial()
        ar_material.colorBufferWriteMask = .alpha
        
        let floor = SCNFloor()
        floor.firstMaterial = ar_material
        let floor_node = SCNNode(geometry:floor)
        floor_node.name = "S_Floor"
        floor_node.makePhysicsBody(type: .static)
        worldNode.addChildNode(floor_node)
        
        floorNode = floor_node
    }
    
    func makePhysicsBodies()
    {
        SceneController.makePhysicsBodies(scene.rootNode)
    }


    
    func makeField()
    {
        
    }
    
    func makeBox()
    {
        
    }
}
