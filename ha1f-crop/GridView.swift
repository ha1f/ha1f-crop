//
//  GridView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

struct GridConfiguration {
    var verticalBlocksCount: Int = 3
    var horizontalBlocksCount: Int = 3
    var showDiagonal: Bool = true
    
    static let ruleOfThirds = GridConfiguration(verticalBlocksCount: 3,
                                                horizontalBlocksCount: 3,
                                                showDiagonal: false)
    static let cross = GridConfiguration(verticalBlocksCount: 2,
                                         horizontalBlocksCount: 2,
                                         showDiagonal: false)
    static let slantedCross = GridConfiguration(verticalBlocksCount: 1,
                                                horizontalBlocksCount: 1,
                                                showDiagonal: true)
    static let railman = GridConfiguration(verticalBlocksCount: 1,
                                           horizontalBlocksCount: 4,
                                           showDiagonal: true)
}

class GridView: UIView {
    /// The color of grid
    var lineColor: UIColor = UIColor(displayP3Red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
    /// The color of border
    var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            return layer.borderColor.map { UIColor(cgColor: $0) }
        }
    }
    var config: GridConfiguration = GridConfiguration.ruleOfThirds {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
    }
    
    /// The default implementation of draw(_:) does nothing,
    /// so thre is no need to call super.draw(_:)
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.clear(self.bounds)
        
        context.setLineWidth(1)
        context.setStrokeColor(lineColor.cgColor)
        
        // 縦線
        for i in 1..<max(config.horizontalBlocksCount, 1) {
            let xValue = bounds.width / CGFloat(config.horizontalBlocksCount) * CGFloat(i)
            context.move(to: CGPoint(x: xValue, y: 0))
            context.addLine(to: CGPoint(x: xValue, y: bounds.height))
        }
        
        // 横線
        for i in 1..<max(config.verticalBlocksCount, 1) {
            let yValue = bounds.height / CGFloat(config.verticalBlocksCount) * CGFloat(i)
            context.move(to: CGPoint(x: 0, y: yValue))
            context.addLine(to: CGPoint(x: bounds.width, y: yValue))
        }
        
        // 対角線
        if config.showDiagonal {
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
            context.move(to: CGPoint(x: bounds.width, y: 0))
            context.addLine(to: CGPoint(x: 0, y: bounds.height))
        }
        
        context.strokePath()
    }
}
