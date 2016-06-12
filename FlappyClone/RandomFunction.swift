//
//  RandomFunction.swift
//  FlappyClone
//
//  Created by Maxim Kovalko on 11.06.16.
//  Copyright © 2016 Maxim Kovalko. All rights reserved.
//

import CoreGraphics

extension CGFloat {
    
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    public static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
    
}