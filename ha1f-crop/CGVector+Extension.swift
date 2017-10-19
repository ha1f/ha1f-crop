//
//  CGVector+Extension.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/19.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGVector {
    init(from: CGPoint, to: CGPoint) {
        self.init(dx: to.x - from.x, dy: to.y - from.y)
    }
}
