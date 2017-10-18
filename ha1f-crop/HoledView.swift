//
//  HoledView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class HoledView: UIView {
    static let anchorWidth: CGFloat = 30
    static let anchorLineWidth: CGFloat = 3
    
    var holeFrame: CGRect = CGRect.zero {
        didSet {
            lt.center = CGPoint(x: holeFrame.minX + HoledView.anchorWidth / 2 - HoledView.anchorLineWidth,
                                     y: holeFrame.minY + HoledView.anchorWidth / 2 - HoledView.anchorLineWidth)
            lb.center = CGPoint(x: holeFrame.minX + HoledView.anchorWidth / 2 - HoledView.anchorLineWidth,
                                     y: holeFrame.maxY - HoledView.anchorWidth / 2 + HoledView.anchorLineWidth)
            rt.center = CGPoint(x: holeFrame.maxX - HoledView.anchorWidth / 2 + HoledView.anchorLineWidth,
                                     y: holeFrame.minY + HoledView.anchorWidth / 2 - HoledView.anchorLineWidth)
            rb.center = CGPoint(x: holeFrame.maxX - HoledView.anchorWidth / 2 + HoledView.anchorLineWidth,
                                     y: holeFrame.maxY - HoledView.anchorWidth / 2 + HoledView.anchorLineWidth)
            mask(withoutRect: holeFrame)
        }
    }
    
    let lt = buildAnchorView()
    let lb = buildAnchorView()
    let rt = buildAnchorView()
    let rb = buildAnchorView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private static func buildAnchorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: anchorWidth, height: anchorWidth)
        return view
    }
    
    private func setup() {
        [lt, lb, rt, rb].forEach { view in
            self.addSubview(view)
        }
    }
}
