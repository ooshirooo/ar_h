//
//  SCNNodeExtention.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/10/31.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    func findGeometry() -> (SCNGeometry?, SCNNode?) {
        if let geo = geometry {
            return (geo,self)
        }else {
            for child in childNodes {
                return child.findGeometry()
            }
            return (nil,nil)
        }
    }
    
    func findParentPhysicsBody() -> SCNPhysicsBody! {
        
        if let body = physicsBody  {
            return body
        }else {
            if let par = parent {
                return par.findParentPhysicsBody()
            }else {
                return nil
            }
        }
    }
    
    func findParentPhysicsNode() -> SCNNode! {
        
        if let body = physicsBody  {
            return self
        }else {
            if let par = parent {
                return par.findParentPhysicsNode()
            }else {
                return nil
            }
        }
    }
    
    func makePhysicsBody(withName name:String, type:SCNPhysicsBodyType) {
        if let node = childNode(withName: name, recursively: true) {
            node.makePhysicsBody(type: type)
        }else {
            print(name + " is not found")
        }
    }
    
    func makePhysicsBody(type:SCNPhysicsBodyType, recursive:Bool = false) {
        let (opt_geo,node) = findGeometry()
        if let geo = opt_geo {
            if physicsBody == nil {
                let phy = SCNPhysicsBody(type: type,
                                             shape: SCNPhysicsShape(geometry:geo, options:[SCNPhysicsShape.Option.type:SCNPhysicsShape.ShapeType.convexHull,
                                                  SCNPhysicsShape.Option.collisionMargin:0,
                                                  SCNPhysicsShape.Option.scale:node!.scale]))
                phy.contactTestBitMask = 1
                
                physicsBody = phy
            }
        }
        
        if(recursive) {
            for child in childNodes {
                child.makePhysicsBody(type: type, recursive:true)
            }
        }
    }
    
    func isStatic() -> Bool {
        if let body = physicsBody {
            return body.type == .static
        }
        return false
    }
}


extension SCNNode {
    
    //アニメーションの実行，停止をboolで指定できるように
    func ctrlAnimation(forKey: String, play:Bool)
    {
        if let anim = animationPlayer(forKey: forKey) {
            if (play)
            {anim.play()}
            else
            {anim.stop()}
        }
    }
    
    //自分と子ノードのすべてのアニメーションをコントロールするコンビニエンス関数
    func ctrlAnimationOfAllChildren(do_play:Bool, anim_id:String = "")
    {
        for child in childNodes {
            child.ctrlAnimationOfAllChildren(do_play:do_play, anim_id:anim_id)
        }
        
        //anim_idが空文字列の場合，nodeの最初のアニメーションidを取得する
        if anim_id == "" && animationKeys.count > 0 {
            for key in animationKeys {
                ctrlAnimation(forKey: key, play:do_play)
            }
        }else {
            ctrlAnimation(forKey: anim_id, play: do_play)
        }
        
        
    }
    
    private func tagName(_ name:String) -> String {
        return "__" + name + "__"
    }
    
    //フラグを設定，取得
    func addTag(name:String)
    {
        let tag_node = SCNNode()
        tag_node.name = tagName(name)
        
        addChildNode(tag_node)
    }
    
    func removeTag(name:String)
    {
        if let tag_node = childNode(withName: tagName(name), recursively: false) {
            tag_node.removeFromParentNode()
        }
    }
    
    func isTagged(name:String) -> Bool
    {
        if childNode(withName: tagName(name), recursively: false) != nil {
            return true
        }else{
            return false
        }
    }
    
    //自分と子ノードに設定されているすべてのアニメーションのkey(識別子)をprintする
    func printAllAnimationKeys ()
    {
        for child in childNodes {
            child.printAllAnimationKeys()
        }
        
        let node_name:String
        node_name = (name != nil) ? name! : "no name"
        
        print ( node_name, animationKeys)
    }
    
    func printChildren (_ depth : Int = 0)
    {
        var indent = ""
        for _ in 0..<depth {
            indent += " "
        }
        
        print (indent, name)
        
        for child in childNodes {
            child.printChildren(depth+1)
        }
        

    }
}

