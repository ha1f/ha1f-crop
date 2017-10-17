//
//  ViewController.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/22.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension UIView {
    func mask(path: UIBezierPath, fillRule: String = kCAFillRuleEvenOdd) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.fillRule = fillRule
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    func mask(withoutRect windowRect: CGRect) {
        let path = UIBezierPath(rect: self.bounds)
        path.append(UIBezierPath(rect: windowRect))
        
        self.mask(path: path)
    }
    
    func mask(rect windowRect: CGRect) {
        let path = UIBezierPath(rect: windowRect)
        
        self.mask(path: path)
    }
    
    func mask(image: UIImage) {
        let maskLayer = CALayer()
        maskLayer.frame = self.bounds
        maskLayer.contents = image.cgImage
        self.layer.mask = maskLayer
    }
}

class GridView: UIView {
    let lt = buildAnchorView()
    let lb = buildAnchorView()
    let rt = buildAnchorView()
    let rb = buildAnchorView()
    var anchorViews: [UIView] {
        return [lt, lb, rt, rb]
    }
    
    func updateFrame(_ frame: CGRect) {
        self.frame = frame
        self.lt.center = CGPoint(x: bounds.minX, y: bounds.minY)
        self.lb.center = CGPoint(x: bounds.minX, y: bounds.maxY)
        self.rt.center = CGPoint(x: bounds.maxX, y: bounds.minY)
        self.rb.center = CGPoint(x: bounds.maxX, y: bounds.maxY)
    }
    
    private static func buildAnchorView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return view
    }
    
    func setup() {
        backgroundColor = .clear
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        anchorViews.forEach { view in
            self.addSubview(view)
        }
    }
}

class ViewController: UIViewController {
    
    private lazy var pintchGestureRecoginizer: UIPinchGestureRecognizer = {
        let gestureRecognizer = UIPinchGestureRecognizer()
        return gestureRecognizer
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        imageView.image = #imageLiteral(resourceName: "sample.png")
        return imageView
    }()
    
    private lazy var gestureView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var holeView: GridView = {
        let view = GridView()
        view.setup()
        return view
    }()
    
    private lazy var holedDimView: UIView = {
        let holedDimView = UIView(frame: self.view.bounds)
        holedDimView.isUserInteractionEnabled = false
        holedDimView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        return holedDimView
    }()
    
    private func updateHole(windowRect: CGRect) {
        // mask layer
        let maskLayer = CAShapeLayer()
        maskLayer.frame = holedDimView.bounds
        let path = UIBezierPath(rect: holedDimView.bounds)
        path.append(UIBezierPath(rect: windowRect))
        
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.fillRule = kCAFillRuleEvenOdd
        maskLayer.path = path.cgPath
        holedDimView.layer.mask = maskLayer
    }
    
    var holeRect: CGRect = CGRect.zero {
        didSet {
            holedDimView.mask(withoutRect: holeRect)
            holeView.updateFrame(holeRect)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(holedDimView)
        view.addSubview(holeView)
        
        let width: CGFloat = 300
        holeRect = CGRect(x: (holedDimView.bounds.width - width) / 2, y: (holedDimView.bounds.height - width) / 2, width: width, height: width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = imageView.image?.aspectFitRect(inside: view.bounds) ?? imageView.frame
//        croppingRectView.frame = imageView.frame
    }

}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

