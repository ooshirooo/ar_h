//
//  AppCore.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/11/15.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

class AppCore
{
    var sceneController : SceneController = SceneController()
    var worldModel : WorldModel!
    
    func prepareScene() {
    }
    
    func makeWorldModel() {
        worldModel = WorldModel(sceneController: sceneController)
        worldModel.make()
    }
    
    func getScene() -> SCNScene {
        return sceneController.scene
    }
    
    func getWorldNode() -> SCNNode {
        return sceneController.worldNode
    }
    
}
