//
//  CroppingView.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/10/18.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

struct TouchState {
    let trackingTouch: UITouch
    private let firstTouchLocation: CGPoint
    private let gestureView: UIView
    
    private var _currentLocation: CGPoint {
        return trackingTouch.location(in: gestureView)
    }
    
    var relativeVector: CGVector {
        return CGVector(dx: _currentLocation.x - firstTouchLocation.x,
                        dy: _currentLocation.y - firstTouchLocation.y)
    }
    
    init(touch: UITouch, in gestureView: UIView, with event: UIEvent?) {
        self.trackingTouch = touch
        self.firstTouchLocation = touch.location(in: gestureView)
        self.gestureView = gestureView
    }
    
    func doOnValidTouch(_ touches: Set<UITouch>, processWithRelativePosition: (CGVector) -> Void) {
        guard touches.contains(trackingTouch) else {
            return
        }
        processWithRelativePosition(self.relativeVector)
    }
}

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
        let cornerViewOffset = CroppingView.anchorWidth / 2 - CroppingView.anchorLineWidth
        lt.center = holeFrame.getPoint(of: .topLeft).offsetBy(dx: cornerViewOffset, dy: cornerViewOffset)
        lb.center = holeFrame.getPoint(of: .bottomLeft).offsetBy(dx: cornerViewOffset, dy: -cornerViewOffset)
        rt.center = holeFrame.getPoint(of: .topRight).offsetBy(dx: -cornerViewOffset, dy: cornerViewOffset)
        rb.center = holeFrame.getPoint(of: .bottomRight).offsetBy(dx: -cornerViewOffset, dy: -cornerViewOffset)
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
    
    private var cornerDiff = CGPoint.zero
    private var movingAnchorView: UIView? = nil
    private var movingAnchorInitialPosition: CGPoint?
    private var draggingState: TouchState? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1, let firstTouch = touches.first else {
            movingAnchorView = nil
            draggingState = nil
            return
        }
        if let touchedView = self.hitTest(firstTouch.location(in: self), with: event) {
            if  isAnchorView(touchedView) {
                draggingState = TouchState(touch: firstTouch, in: self, with: event)
                movingAnchorView = touchedView
                
                switch touchedView {
                case lt:
                    movingAnchorInitialPosition = holeFrame.getPoint(of: .topLeft)
                case lb:
                    movingAnchorInitialPosition =  holeFrame.getPoint(of: .bottomLeft)
                case rt:
                    movingAnchorInitialPosition = holeFrame.getPoint(of: .topRight)
                case rb:
                    movingAnchorInitialPosition = holeFrame.getPoint(of: .bottomRight)
                default:
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        draggingState?.doOnValidTouch(touches) { relativePosition in
            updateToPosition(to: movingAnchorInitialPosition!.offsetBy(relativePosition))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        draggingState?.doOnValidTouch(touches) { relativePosition in
            updateToPosition(to: movingAnchorInitialPosition!.offsetBy(relativePosition))
        }
        self.draggingState = nil
        self.movingAnchorView = nil
    }
    
    private func updateToPosition(to point: CGPoint) {
        guard let movingView = movingAnchorView else {
            return
        }
        switch movingView {
        case lt:
            holeFrame = holeFrame.withMovingCorner(of: .topLeft, to: point)
        case lb:
            holeFrame = holeFrame.withMovingCorner(of: .bottomLeft, to: point)
        case rt:
            holeFrame = holeFrame.withMovingCorner(of: .topRight, to: point)
        case rb:
            holeFrame = holeFrame.withMovingCorner(of: .bottomRight, to: point)
        default:
            break
        }
    }
}
