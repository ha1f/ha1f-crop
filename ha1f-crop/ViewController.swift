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
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .red
        imageView.image = #imageLiteral(resourceName: "sample.png")
        return imageView
    }()
    
    private lazy var croppingView = CroppingView(frame: self.view.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(croppingView)
        
        croppingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            croppingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            croppingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            croppingView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            croppingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            ])
        let sampleHoleRectWidth: CGFloat = 200
        let sampleHoleFrame = CGRect(x: (croppingView.bounds.width - sampleHoleRectWidth) / 2,
                                     y: (croppingView.bounds.height - sampleHoleRectWidth) / 2,
                                     width: sampleHoleRectWidth,
                                     height: sampleHoleRectWidth)
        croppingView.holeFrame = sampleHoleFrame
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = imageView.image?.aspectFitRect(inside: view.bounds) ?? imageView.frame
    }
}

