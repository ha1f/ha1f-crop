//
//  ViewController.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/22.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension UIScrollView {
    /// Used for scrollView to works as if scrollView frame is actualFrame.
    /// The advantage of thissolution is to extend scrollable area.
    /// Note: Need to set scrollView.contentInsetAdjustmentBehavior = .never to work properly.
    var actualFrame: CGRect {
        set {
            let top = newValue.minY
            let left = newValue.minX
            let bottom = bounds.height - newValue.maxY
            let right = bounds.width - newValue.maxX
            self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            self.scrollIndicatorInsets = self.contentInset
        }
        get {
            let width = bounds.width - (contentInset.left + contentInset.right)
            let height = bounds.height - (contentInset.top + contentInset.bottom)
            return CGRect(origin: CGPoint(x: contentInset.left, y: contentInset.top), size: CGSize(width: width, height: height))
        }
    }
}

class ViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.center = view.center
        scrollView.clipsToBounds = false
        
        let gestureRecognizer = UIRotationGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(self.onRotated(gestureRecognizer:)))
        scrollView.addGestureRecognizer(gestureRecognizer)
        return scrollView
    }()
    
    private lazy var croppingView: CroppingView = {
        let view = CroppingView(frame: self.view.bounds)
        view.isResizingEnabled = false
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        view.addSubview(croppingView)
        scrollView.addSubview(imageView)
        
        // TODO: re-layout
        croppingView.frame = view.bounds
        scrollView.frame = view.bounds
        
        originalImage = #imageLiteral(resourceName: "sample.png")
        
        setupButton()
    }
    
    var originalImage = #imageLiteral(resourceName: "sample.png") {
        didSet {
            currentRotation = 0.0
            setImage(originalImage)
        }
    }
    var currentRotation: CGFloat = 0.0 {
        didSet {
            setImage(originalImage.rotated(angle: currentRotation)!, fitHole: false)
        }
    }
    
    private func setupButton() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        button.setTitle("CROP!", for: .normal)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 50),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
            ])
        button.addTarget(self, action: #selector(self.onCropButtonTapped), for: .touchUpInside)
    }
    
    @objc func onCropButtonTapped() {
        if let result = crop() {
            originalImage = result
        }
    }
    
    private var initialTransform: CGAffineTransform = CGAffineTransform.identity
    @objc func onRotated(gestureRecognizer: UIRotationGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            initialTransform = imageView.transform
            imageView.transform = initialTransform.rotated(by: gestureRecognizer.rotation)
        case .changed:
            imageView.transform = initialTransform.rotated(by: gestureRecognizer.rotation)
        case .ended:
            currentRotation += gestureRecognizer.rotation
            imageView.transform = CGAffineTransform.identity
        case .failed, .cancelled:
            imageView.transform = initialTransform
        case .possible:
            break
        }
    }
    
    /// Set image to imageView, and resizes hole to fit properly in the screen
    func setImage(_ image: UIImage, fitHole: Bool = true) {
        scrollView.setZoomScale(1.0, animated: false)
        
        // Layout imageView
        imageView.image = image
        
        let preferredSize = imageView.sizeThatFits(view.bounds.size)
        let preferredRect = CGRect(origin: .zero, size: preferredSize)
        let holeSize: CGSize
        if preferredRect.width > (croppingView.bounds.width - 50) {
            holeSize = preferredRect.insetBy(dx: 50, dy: 50 / preferredSize.width * preferredSize.height).size
        } else if preferredRect.height > (croppingView.bounds.height - 50) {
            holeSize = preferredRect.insetBy(dx: 50 / preferredSize.height * preferredSize.width, dy: 50 / preferredSize.width * preferredSize.height).size
        } else {
            holeSize = preferredSize
        }
        imageView.frame = CGRect(origin: .zero, size: holeSize)
        
        // Set holeFrame to cover imageView
        if fitHole {
            
            let holeFrame = CGRect(origin: .zero, size: holeSize).withCentering(in: croppingView)
            croppingView.holeFrame = holeFrame
            croppingView.holeMask = UIImage.circle(size: croppingView.holeFrame.size, color: .black, backgroundColor: .white)
            setHoleFrame()
        }
        
        imageView.center = CGPoint(x: croppingView.holeFrame.width / 2, y: croppingView.holeFrame.height / 2)
        scrollView.contentSize = croppingView.holeFrame.size
        
        view.setNeedsLayout()
        
    }
    
    private func setHoleFrame() {
        scrollView.actualFrame = croppingView.holeFrame
            .offsetBy(dx: croppingView.frame.minX - scrollView.frame.minX, dy: croppingView.frame.minY - scrollView.frame.minY)
        scrollView.setZoomScale(scrollView.zoomScale, animated: false)
    }
    
    func crop() -> UIImage? {
        guard let image = imageView.image else {
            debugPrint("no image")
            return nil
        }
        let visibleRect = imageView.convert(scrollView.actualFrame.offsetBy(dx: scrollView.bounds.minX, dy: scrollView.bounds.minY), from: scrollView)
        let actualImageViewWidth = imageView.frame.width / scrollView.zoomScale
        let scale: CGFloat = image.size.width / actualImageViewWidth
        let scaledRect = CGRect(x: visibleRect.minX * scale,
                                y: visibleRect.minY * scale,
                                width: visibleRect.width * scale,
                                height: visibleRect.height * scale)
        guard let croppedImage = image.cropped(to: scaledRect) else {
            debugPrint("some error occured in cropped")
            return nil
        }
        if let mask = croppingView.holeMask {
            return croppedImage.masked(with: mask)
        } else {
            return croppedImage
        }
    }
}

extension ViewController: CroppingViewDelegate {
    // TODO: shouldChangeで最大サイズを設定
    func croppingView(holeFrameDidChange cropingView: CroppingView, holeFrame: CGRect) {
        setHoleFrame()
    }
}

extension ViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
