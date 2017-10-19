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
        imageView.backgroundColor = .black
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
    
    private lazy var croppingView = CroppingView(frame: self.view.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        view.addSubview(croppingView)
        scrollView.addSubview(imageView)
        
        croppingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            croppingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            croppingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            croppingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            croppingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
            ])
        
        let holeSize = CGRect(origin: .zero, size: imageView.sizeThatFits(view.bounds.size)).insetBy(dx: 50, dy: 50).size
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: holeSize.width),
            scrollView.heightAnchor.constraint(equalToConstant: holeSize.height)
            ])
        
        imageView.frame = CGRect(origin: .zero, size: holeSize)
        
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
    
    override func viewDidLayoutSubviews() {
        // scrollView position is equal to hole
        // TODO: adjust scrollView size to holeFrame
        croppingView.holeFrame = scrollView.frame
            .offsetBy(dx: -croppingView.frame.minX, dy: -croppingView.frame.minY)
    }
    
    @objc func crop() {
        guard let image = imageView.image else {
            return
        }
        let visibleRect = imageView.convert(scrollView.bounds, from: scrollView)
        let scale: CGFloat = image.size.width / (imageView.frame.width / scrollView.zoomScale)
        let scaledRect = CGRect(x: visibleRect.minX * scale,
                                y: visibleRect.minY * scale,
                                width: visibleRect.width * scale,
                                height: visibleRect.height * scale)
        let croppedImage = image.cropped(to: scaledRect)
        imageView.image = croppedImage
        scrollView.setZoomScale(1.0, animated: false)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
