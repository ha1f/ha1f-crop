//
//  CornerPosition.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/19.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

enum CornerPosition: UInt8 {
    case topLeft = 0b00
    case topRight = 0b01
    case bottomLeft = 0b10
    case bottomRight = 0b11
    
    private static let _bottom: UInt8 = 0b10
    private static let _right: UInt8 = 0b01
    
    var isTopEdge: Bool {
        return !isBottomEdge
    }
    var isLeftEdge: Bool {
        return !isRightEdge
    }
    var isBottomEdge: Bool {
        return (rawValue & CornerPosition._bottom) != 0
    }
    var isRightEdge: Bool {
        return (rawValue & CornerPosition._right) != 0
    }
}

extension CGRect {
    func getPoint(of corner: CornerPosition) -> CGPoint {
        switch corner {
        case .topLeft:
            return CGPoint(x: minX, y: minY)
        case .topRight:
            return CGPoint(x: maxX, y: minY)
        case .bottomLeft:
            return CGPoint(x: minX, y: maxY)
        case .bottomRight:
            return CGPoint(x: maxX, y: maxY)
        }
    }
}
