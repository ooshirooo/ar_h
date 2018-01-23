//
//  ObjectPicker.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/10/27.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import SceneKit
import CoreGraphics

extension SCNNode {
    func body() -> SCNNode! {
        return childNode(withName: "body", recursively: false)
    }
    
    func view() -> SCNNode! {
        return childNode(withName: "view", recursively: false)
    }
    
    func hook() -> SCNNode! {
        return childNode(withName: "hook", recursively: false)
    }
}

class ObjectPicker : NSObject {
    
    enum PickingState {
        case picking
        case dropped
    }
    
    static let TYPE_CHANGED_TAG = "type_changed"
    
    var renderer : SCNSceneRenderer!
    var worldNode : SCNNode!
    
    private var state : PickingState = .dropped
    private var pickedPosition : SCNVector3 = SCNVector3(0,0,0)
    private var pickedObjectNode : SCNNode!
    private var pickerObjectNode : SCNNode!
    private var rodNode : SCNNode!
    
    private var hinge : SCNPhysicsBehavior!
    
    private var observedObjects : Set<SCNNode> = []
    private var replacingObjects : Set<SCNNode> = []
    
    func scene() -> SCNScene {
        if let scene = renderer.scene {
            return scene
        }
        fatalError()
    }
    
    func cameraNode() -> SCNNode
    {
        guard let cam = renderer.pointOfView else {
            fatalError()
        }
        
        return cam
    }
    
   // var timer : Timer!
    

    
    func pick(at pos:CGPoint)
    {
        let pt = pos
        
        let opts = [SCNHitTestOption.searchMode : SCNHitTestSearchMode.all.rawValue]
        let founds = renderer.hitTest(pt, options:  opts)
        
        print(founds.count)
        for found in founds {
            
            guard let found_node = found.node.findParentPhysicsNode() else {
                continue
            }
            
            if found_node.isStatic() {
                continue
            }
            
            print (found_node.name as Any)

            

            pickedObjectNode = found_node
            
            found_node.position = found_node.presentation.position
            
//            let picked_position = worldNode.convertPosition(found.localCoordinates, from:found.node)//pickedObjectNode.presentation.position
            let picked_position = worldNode.convertPosition(found.worldCoordinates, from:nil)

            
            
//            let picked_scale = pickedObjectNode.scale
          //  let picked_geometry = pickedObjectNode.geometry
            let parent = pickedObjectNode.parent

            //引っ掛ける位置を算出(掴むオブジェクトのワールド座標)
            
            //var rod_pos : SCNVector3// = worldNode.convertPosition(hook_pos, from:pickedObjectNode)
            var hook_pos : SCNVector3
            
            //引っ掛ける位置が指定されていればそれを使う
            if let hook_node = pickedObjectNode.hook() {
                hook_pos = worldNode.convertPosition(SCNVector3(), from: hook_node)
                
            }else { //なければ計算
                hook_pos = pickedObjectNode.convertPosition(SCNVector3(), to:worldNode)
                
                let bbox = pickedObjectNode.body().boundingBox
                let len = bbox.max.y
                hook_pos.y += len
                
            }
            
            //掴む装置の位置(ワールド座標)
            var rod_pos = hook_pos
            rod_pos.y += 0.1
            
            /// for debug
//            let dummy = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0))
//            dummy.position = rod_pos
//            worldNode.addChildNode(dummy)
            ///

            print("picked obj",pickedObjectNode.name as Any, "parent",parent!.name as Any)
            print("pick pos",picked_position)
            print("hook pos",hook_pos)
            print("rod pos",rod_pos)

            //dynamic bodyでないと掴めないので，変更する
            if(pickedObjectNode.physicsBody?.type != .dynamic) {
                pickedObjectNode.removeFromParentNode()
//            pickedObjectNode = SCNNode(geometry: picked_geometry)
//            pickedObjectNode.position = picked_position
//            pickedObjectNode.scale = picked_scale
                pickedObjectNode.physicsBody = nil
                pickedObjectNode.makePhysicsBody(type: .dynamic)
                pickedObjectNode.physicsBody?.angularDamping = 1
                pickedObjectNode.physicsBody?.rollingFriction = 1
                
                pickedObjectNode.addTag(name: ObjectPicker.TYPE_CHANGED_TAG)
                parent?.addChildNode(pickedObjectNode)
            }
            
            let rod_in_camera = cameraNode().convertPosition(rod_pos, from:worldNode)
            //makeRod(to: rod_in_camera)

            pickedPosition = rod_in_camera
            
            if let old_picker = pickerObjectNode {
                old_picker.removeFromParentNode()
            }
            
            pickerObjectNode = SCNNode()
            pickerObjectNode.name = "__picker"
            pickerObjectNode.position = rod_pos
            pickerObjectNode.geometry = SCNSphere(radius: CGFloat(0.01))
            worldNode.addChildNode(pickerObjectNode)

            pickerObjectNode.makePhysicsBody(type: .kinematic)

            guard let ba = pickerObjectNode.findParentPhysicsBody(),
                let bb = pickedObjectNode.findParentPhysicsBody() else {
                fatalError()
            }
            hinge = SCNPhysicsBallSocketJoint(bodyA: ba,
                                                  anchorA: SCNVector3(0,-0.02,0),
                                                  bodyB: bb,
                                                  anchorB: pickedObjectNode.convertPosition(hook_pos, from:worldNode))
            
            scene().physicsWorld.addBehavior(hinge)
 
            
            state = .picking
            
//            if(timer == nil) {
//                timer = Timer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
//                timer.fire()
//            }

            break
        }
    }
    
    func drop()
    {
        if(state == .picking) {
            state = .dropped
            
            guard let picker = pickerObjectNode else {
                return
            }
            
            picker.removeFromParentNode()
            if let rod = rodNode {
                rod.removeFromParentNode()
            }
            
            if (hinge != nil) {
                scene().physicsWorld.removeBehavior(hinge)
            }
            
            pickedObjectNode.addTag(name: "droped")
            pickedObjectNode.physicsBody?.angularDamping = 0.1
            pickedObjectNode.physicsBody?.rollingFriction = 0.1

            if pickedObjectNode.isTagged(name: ObjectPicker.TYPE_CHANGED_TAG) {
                observedObjects.insert(pickedObjectNode)
            }
        }
    }
    
    func makeRod(to : SCNVector3)
    {
        //guard let scene = renderer.scene else { return }
        
        let rod = SCNTube(innerRadius: 0.01, outerRadius: 0.1, height: dot(to,to).squareRoot())
        let rod_node = SCNNode(geometry:rod)
        
//        renderer.scene?.rootNode.addChildNode(rod_node)
        rod_node.position = SCNVector3(0,0.1,0)
        rod_node.rotation = SCNVector4(1,0,0, CGFloat.pi / 180 * 90)
        cameraNode().addChildNode(rod_node)
        
        rodNode = rod_node
    }
    
    func updateInRenderLoop()
    {
        //print (cameraNode().rotation)
        if(state == .picking) {
            let drag_to = worldNode.convertPosition(pickedPosition, from: cameraNode())
            
            pickerObjectNode.position = drag_to
        }
        
        let REST_THRE = 0.01 as CGFloat
        for node in observedObjects {
            
            
            let vel = node.physicsBody!.velocity
            print (vel)
            if  sqrt(vel*vel) < REST_THRE {
                
                print(node.name as Any, "resting")
                                
                observedObjects.remove(node)
                replacingObjects.insert(node)
            }
        }
    }
    
    func updateOutofRenderLoop() {
        for node in replacingObjects {
            replaceNode(node)
            replacingObjects.remove(node)
        }
    }
    
    // 下記は，全ての物理オブジェクトに親ノードを作成したことで不要になった．(dynamicでもアニメーション可能)
    ////_x 物理エンジンで移動するとアニメーション開始時に原点に戻るのでそれを防ぐ処理
    ////_x さらに，physicsbody.typeを強制的に変更する(普通に変更すると落ちるので，一旦シーンから削除して戻す)
    func replaceNode(_ node: SCNNode) {
      //  if let parent = node.parent {

            //parent.position = parent.convertPosition(node.presentation.position, to: worldNode)
            //node.position = SCNVector3()
            
     /*       node.removeFromParentNode()
            node.physicsBody = nil
            
            node.printChildren()
            SceneController.makePhysicsBodies(node)
            parent.addChildNode(node) */
     //   }
    }
    
}
