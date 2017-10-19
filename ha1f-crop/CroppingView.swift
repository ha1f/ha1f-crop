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
    let firstTouchLocation: CGPoint
    private let gestureView: UIView
    
    var currentTouchLocation: CGPoint {
        return trackingTouch.location(in: gestureView)
    }
    
    var relativeVector: CGVector {
        return CGVector(dx: currentTouchLocation.x - firstTouchLocation.x,
                        dy: currentTouchLocation.y - firstTouchLocation.y)
    }
    
    init(touch: UITouch, in gestureView: UIView, with event: UIEvent?) {
        self.trackingTouch = touch
        self.firstTouchLocation = touch.location(in: gestureView)
        self.gestureView = gestureView
    }
    
    func containsValidTouch(_ touches: Set<UITouch>) -> Bool {
        return touches.contains(trackingTouch)
    }
}

class CroppingView: UIView {
    private lazy var holedView = UIView(frame: self.bounds)
    private lazy var holeView = GridView(frame: self.holeFrame)
    
    var holeFrame: CGRect = CGRect.zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.holedView.frame = self.bounds
        self.holeView.frame = self.holeFrame
        _updateCornerViewLayouts()
        holedView.mask(withoutRect: holeFrame)
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
        holedView.isUserInteractionEnabled = self.isResizingEnabled
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
    
    var isResizingEnabled: Bool = false {
        didSet {
            self.isUserInteractionEnabled = isResizingEnabled
            holedView.isUserInteractionEnabled = isResizingEnabled
        }
    }
    
    private static func _buildAnchorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: anchorWidth, height: anchorWidth)
        return view
    }
    
    private func _cornerPosition(of cornerView: UIView) -> CornerPosition? {
        switch cornerView {
        case lt:
            return .topLeft
        case lb:
            return .bottomLeft
        case rt:
            return .topRight
        case rb:
            return .bottomRight
        default:
            return nil
        }
    }
    
    private func _updateCornerViewLayouts() {
        let cornerViewOffset = CroppingView.anchorWidth / 2 - CroppingView.anchorLineWidth
        lt.center = holeFrame.getPoint(of: .topLeft).offsetBy(dx: cornerViewOffset, dy: cornerViewOffset)
        lb.center = holeFrame.getPoint(of: .bottomLeft).offsetBy(dx: cornerViewOffset, dy: -cornerViewOffset)
        rt.center = holeFrame.getPoint(of: .topRight).offsetBy(dx: -cornerViewOffset, dy: cornerViewOffset)
        rb.center = holeFrame.getPoint(of: .bottomRight).offsetBy(dx: -cornerViewOffset, dy: -cornerViewOffset)
    }
    
    private func _isAnchorView(_ view: UIView) -> Bool {
        return _cornerPosition(of: view) != nil
    }
    
    // Ignore user interaction except anchor
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        guard _isAnchorView(view) else {
            return nil
        }
        return view
    }
    
    struct MovingCornerState {
        let initialiPoint: CGPoint
        let cornerPosition: CornerPosition
    }
    
    private var touchState: TouchState? = nil
    private var movingCornerState: MovingCornerState? = nil
    
    private func _invalidateTouchState() {
        touchState = nil
        movingCornerState = nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1, let firstTouch = touches.first else {
            _invalidateTouchState()
            return
        }
        if let touchedView = self.hitTest(firstTouch.location(in: self), with: event),
            let position = _cornerPosition(of: touchedView) {
            movingCornerState = MovingCornerState(initialiPoint: holeFrame.getPoint(of: position),
                                                  cornerPosition: position)
            touchState = TouchState(touch: firstTouch, in: self, with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touchState = self.touchState, touchState.containsValidTouch(touches) else {
            return
        }
        guard let state = movingCornerState else {
            return
        }
        holeFrame = holeFrame.withMovingCorner(of: state.cornerPosition, to: state.initialiPoint.offsetBy(touchState.relativeVector))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touchState = self.touchState, touchState.containsValidTouch(touches) else {
            return
        }
        guard let state = movingCornerState else {
            return
        }
        holeFrame = holeFrame.withMovingCorner(of: state.cornerPosition, to: state.initialiPoint.offsetBy(touchState.relativeVector))
        _invalidateTouchState()
    }
}
