//
//  ViewController.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/22.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.maximumZoomScale = 8.0
        scrollView.minimumZoomScale = 1.0
        scrollView.contentMode = .center
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        imageView.image = #imageLiteral(resourceName: "sample.png")
        return imageView
    }()
    
    let gridView: UIView = {
        let view = UIView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.frame = self.view.bounds
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
            ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = imageView.image?.aspectFitRect(inside: scrollView.bounds) ?? imageView.frame
    }

}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

