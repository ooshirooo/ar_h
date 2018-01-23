//
//  Vector3.swift
//  PickTest
//
//  Created by Yuhei Akamine on 2017/10/31.
//  Copyright © 2017年 赤嶺有平. All rights reserved.
//

import Foundation
import SceneKit

func dot(_ a : SCNVector3, _ b : SCNVector3) -> CGFloat
{
    return CGFloat(a.x*b.x+a.y*b.y+a.z*b.z)
}

func + (_ a : SCNVector3, _ b : SCNVector3) -> SCNVector3
{
    return SCNVector3(a.x+b.x, a.y+b.y, a.z+b.z)
}

public func * (left: SCNVector3, right: SCNVector3) -> CGFloat {
    return CGFloat(left.x * right.x + left.y * right.y + left.z * right.z)
}

func mult (_ a : SCNVector3, _ b : SCNVector3) -> SCNVector3
{
    return SCNVector3(a.x*b.x, a.y*b.y, a.z*b.z)
}
