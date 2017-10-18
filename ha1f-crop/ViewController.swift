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
        
        let width: CGFloat = 300
        croppingView.holeFrame = CGRect(x: (croppingView.bounds.width - width) / 2,
                           y: (croppingView.bounds.height - width) / 2,
                           width: width,
                           height: width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = imageView.image?.aspectFitRect(inside: view.bounds) ?? imageView.frame
    }
}

