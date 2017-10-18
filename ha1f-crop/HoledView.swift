//
//  HoledView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}

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
    
    private func isAnchorView(_ view: UIView) -> Bool {
        return [lt, lb, rt, rb].contains(view)
    }
    
    /// Resizing
    private var movingAnchorView: UIView? = nil
    private var trackingTouch: UITouch? = nil
    private var cornerDiff = CGPoint.zero
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1, let firstTouch = touches.first else {
            movingAnchorView = nil
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
        guard let movingView = movingAnchorView else {
            return
        }
        let position = trackingTouch.location(in: self).offsetBy(dx: cornerDiff.x, dy: cornerDiff.y)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let trackingTouch = self.trackingTouch, touches.contains(trackingTouch) else {
            return
        }
        guard let movingView = movingAnchorView else {
            return
        }
        let position = trackingTouch.location(in: self).offsetBy(dx: cornerDiff.x, dy: cornerDiff.y)
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
        self.trackingTouch = nil
        self.movingAnchorView = nil
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
    
    private func setup() {
        [lt, lb, rt, rb].forEach { view in
            self.addSubview(view)
        }
        self.isUserInteractionEnabled = true
    }
}
