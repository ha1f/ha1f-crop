//
//  CGRect+Extension.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGRect {
    func withMovingTopY(to value: CGFloat) -> CGRect {
        return CGRect(x: minX, y: min(value, maxY), width: width, height: abs(maxY - value))
    }
    func withMovingBottomY(to value: CGFloat) -> CGRect {
        return CGRect(x: minX, y: min(minY, value), width: width, height: abs(value - minY))
    }
    func withMovingLeftX(to value: CGFloat) -> CGRect {
        return CGRect(x: min(value, maxX), y: minY, width: abs(maxX - value), height: height)
    }
    func withMovingRightX(to value: CGFloat) -> CGRect {
        return CGRect(x: min(minX, value), y: minY, width: abs(value - minX), height: height)
    }
    
    // TODO: refactor to single call
    func withMovingTopLeft(to value: CGPoint) -> CGRect {
        return withMovingLeftX(to: value.x).withMovingTopY(to: value.y)
    }
    func withMovingTopRight(to value: CGPoint) -> CGRect {
        return withMovingRightX(to: value.x).withMovingTopY(to: value.y)
    }
    func withMovingBottomLeft(to value: CGPoint) -> CGRect {
        return withMovingLeftX(to: value.x).withMovingBottomY(to: value.y)
    }
    func withMovingBottomRight(to value: CGPoint) -> CGRect {
        return withMovingRightX(to: value.x).withMovingBottomY(to: value.y)
    }
}

