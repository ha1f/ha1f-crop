//
//  CroppingView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class CroppingView: UIView {
    private lazy var holedView = UIView(frame: self.bounds)
    private lazy var holeView = GridView(frame: self.holeFrame)
    
    var holeFrame: CGRect = CGRect.zero {
        didSet {
            _updateAnchorPositions()
            holedView.mask(withoutRect: holeFrame)
            self.setNeedsLayout()
        }
    }
    
    private func _updateAnchorPositions() {
        lt.center = CGPoint(x: holeFrame.minX + CroppingView.anchorWidth / 2 - CroppingView.anchorLineWidth,
                            y: holeFrame.minY + CroppingView.anchorWidth / 2 - CroppingView.anchorLineWidth)
        lb.center = CGPoint(x: holeFrame.minX + CroppingView.anchorWidth / 2 - CroppingView.anchorLineWidth,
                            y: holeFrame.maxY - CroppingView.anchorWidth / 2 + CroppingView.anchorLineWidth)
        rt.center = CGPoint(x: holeFrame.maxX - CroppingView.anchorWidth / 2 + CroppingView.anchorLineWidth,
                            y: holeFrame.minY + CroppingView.anchorWidth / 2 - CroppingView.anchorLineWidth)
        rb.center = CGPoint(x: holeFrame.maxX - CroppingView.anchorWidth / 2 + CroppingView.anchorLineWidth,
                            y: holeFrame.maxY - CroppingView.anchorWidth / 2 + CroppingView.anchorLineWidth)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.holedView.frame = self.bounds
        self.holeView.frame = self.holeFrame
    }
    
    // MARK: Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    private func _setup() {
        holeView.isUserInteractionEnabled = false
        holedView.isUserInteractionEnabled = true
        holedView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        addSubview(holedView)
        addSubview(holeView)
        
        /// resizing
        [lt, lb, rt, rb].forEach { view in
            holedView.addSubview(view)
        }
    }
    
    /// resizing
    static let anchorWidth: CGFloat = 30
    static let anchorLineWidth: CGFloat = 3
    
    private let lt = _buildAnchorView()
    private let lb = _buildAnchorView()
    private let rt = _buildAnchorView()
    private let rb = _buildAnchorView()
    
    private static func _buildAnchorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: anchorWidth, height: anchorWidth)
        return view
    }
    
    private func isAnchorView(_ view: UIView) -> Bool {
        return [lt, lb, rt, rb].contains(view)
    }
    
    // Ignore user interaction except anchor
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        guard isAnchorView(view) else {
            return nil
        }
        return view
    }
    
    private var movingAnchorView: UIView? = nil
    private var trackingTouch: UITouch? = nil
    private var cornerDiff = CGPoint.zero
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1, let firstTouch = touches.first else {
            movingAnchorView = nil
            self.trackingTouch = nil
            return
        }
        let touchPosition = firstTouch.location(in: self)
        if let touchedView = self.hitTest(firstTouch.location(in: self), with: event) {
            if  isAnchorView(touchedView) {
                self.trackingTouch = firstTouch
                movingAnchorView = touchedView
                
                switch touchedView {
                case lt:
                    cornerDiff = CGPoint(x: holeFrame.minX - touchPosition.x, y: holeFrame.minY - touchPosition.y)
                case lb:
                    cornerDiff = CGPoint(x: holeFrame.minX - touchPosition.x, y: holeFrame.maxY - touchPosition.y)
                case rt:
                    cornerDiff = CGPoint(x: holeFrame.maxX - touchPosition.x, y: holeFrame.minY - touchPosition.y)
                case rb:
                    cornerDiff = CGPoint(x: holeFrame.maxX - touchPosition.x, y: holeFrame.maxY - touchPosition.y)
                default:
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let trackingTouch = self.trackingTouch, touches.contains(trackingTouch) else {
            return
        }
        updateToPosition(with: trackingTouch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let trackingTouch = self.trackingTouch, touches.contains(trackingTouch) else {
            return
        }
        updateToPosition(with: trackingTouch)
        self.trackingTouch = nil
        self.movingAnchorView = nil
    }
    
    private func updateToPosition(with touch: UITouch) {
        guard let movingView = movingAnchorView else {
            return
        }
        let position = touch.location(in: self).offsetBy(dx: cornerDiff.x, dy: cornerDiff.y)
        switch movingView {
        case lt:
            holeFrame = holeFrame.withMovingTopLeft(to: position)
        case lb:
            holeFrame = holeFrame.withMovingBottomLeft(to: position)
        case rt:
            holeFrame = holeFrame.withMovingTopRight(to: position)
        case rb:
            holeFrame = holeFrame.withMovingBottomRight(to: position)
        default:
            break
        }
    }
}
