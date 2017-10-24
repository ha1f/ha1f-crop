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
    
    func withCentering(in superview: UIView) -> CGRect {
        let center = CGPoint(x: (superview.bounds.width - width) / 2, y: (superview.bounds.height - height) / 2)
        return CGRect(origin: center, size: size)
    }
    
    // TODO: refactor to single call
    func withMovingCorner(of position: CornerPosition, to point: CGPoint) -> CGRect {
        switch position {
        case .topLeft:
            return withMovingLeftX(to: point.x).withMovingTopY(to: point.y)
        case .topRight:
            return withMovingRightX(to: point.x).withMovingTopY(to: point.y)
        case .bottomLeft:
            return withMovingLeftX(to: point.x).withMovingBottomY(to: point.y)
        case .bottomRight:
            return withMovingRightX(to: point.x).withMovingBottomY(to: point.y)
        }
    }
}

