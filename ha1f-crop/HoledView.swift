//
//  HoledView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class CroppingView: UIView {
    private lazy var holedView = HoledView(frame: self.bounds)
    private lazy var holeView = GridView(frame: self.holeFrame)
    
    var holeFrame: CGRect = CGRect.zero {
        didSet {
            self.holedView.holeFrame = holeFrame
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.holedView.frame = self.bounds
        self.holeView.frame = self.holeFrame
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        holeView.isUserInteractionEnabled = false
        holedView.isUserInteractionEnabled = true
        holedView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        addSubview(holedView)
        addSubview(holeView)
    }
}

class HoledView: UIView {
    static let anchorWidth: CGFloat = 30
    static let anchorLineWidth: CGFloat = 3
    
    fileprivate var holeFrame: CGRect = CGRect.zero {
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
    
    var isResizingEnabled: Bool = true {
        didSet {
            self.isUserInteractionEnabled = isResizingEnabled
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
    }
}
