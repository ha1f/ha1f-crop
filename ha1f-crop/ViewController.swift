//
//  ViewController.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/22.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .red
        imageView.image = #imageLiteral(resourceName: "sample.png")
        return imageView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.center = view.center
        scrollView.clipsToBounds = false
        return scrollView
    }()
    
    private lazy var croppingView: CroppingView = {
        let view = CroppingView(frame: self.view.bounds)
        view.isResizingEnabled = true
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        view.addSubview(croppingView)
        scrollView.addSubview(imageView)
        
        croppingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            croppingView.topAnchor.constraint(equalTo: view.topAnchor),
            croppingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            croppingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            croppingView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
        
        resetHole()
        
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
        button.addTarget(self, action: #selector(self.crop), for: .touchUpInside)
    }
    
    private func resetHole() {
        let preferredSize = imageView.sizeThatFits(view.bounds.size)
        let preferredRect = CGRect(origin: .zero, size: preferredSize)
        let holeSize: CGSize
        if preferredRect.width > (view.bounds.width - 50) {
            holeSize = preferredRect.insetBy(dx: 50, dy: 50 / preferredSize.width * preferredSize.height).size
        } else if preferredRect.height > (view.bounds.height - 50) {
            holeSize = preferredRect.insetBy(dx: 50 / preferredSize.height * preferredSize.width, dy: 50 / preferredSize.width * preferredSize.height).size
        } else {
            holeSize = preferredSize
        }
        print("hole", holeSize, view.bounds.size, imageView.sizeThatFits(view.bounds.size), preferredSize)
        imageView.frame = CGRect(origin: .zero, size: holeSize)
        scrollView.frame = CGRect(origin: .zero, size: holeSize)
        scrollView.center = view.center
        croppingView.holeFrame = scrollView.frame.offsetBy(dx: -croppingView.frame.minX, dy: -croppingView.frame.minY)
        view.setNeedsLayout()
    }
    
    @objc func crop() {
        guard let image = imageView.image else {
            return
        }
        let visibleRect = imageView.convert(scrollView.bounds, from: scrollView)
        print("visible", visibleRect)
        let scale: CGFloat = image.size.width / (imageView.frame.width / scrollView.zoomScale)
        let scaledRect = CGRect(x: visibleRect.minX * scale,
                                y: visibleRect.minY * scale,
                                width: visibleRect.width * scale,
                                height: visibleRect.height * scale)
        print("scaled", scaledRect)
        print("image", image.size)
        let croppedImage = image.cropped(to: scaledRect)
        print("cropped", croppedImage!.size)
        imageView.image = croppedImage
        scrollView.setZoomScale(1.0, animated: false)
        resetHole()
    }
}

extension ViewController: CroppingViewDelegate {
    // TODO: shouldChangeで最大サイズを設定
    func croppingView(holeFrameDidChange cropingView: CroppingView, holeFrame: CGRect) {
        let oldFrame = scrollView.frame
        scrollView.frame = holeFrame.offsetBy(dx: croppingView.frame.minX, dy: croppingView.frame.minY)
        scrollView.contentOffset = scrollView.contentOffset.offsetBy(dx: scrollView.frame.minX - oldFrame.minX, dy: scrollView.frame.minY - oldFrame.minY)
        // I don't know why, but if this line is not present, we cannot scroll after resizing
        scrollView.setZoomScale(scrollView.zoomScale, animated: false)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
