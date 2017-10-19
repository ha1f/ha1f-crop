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
            croppingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
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
    }
    
    override func viewDidLayoutSubviews() {
        croppingView.holeFrame = CGRect(x: scrollView.frame.minX - croppingView.frame.minX,
                                        y: scrollView.frame.minY - croppingView.frame.minY,
                                        width: scrollView.frame.width,
                                        height: scrollView.frame.height)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
