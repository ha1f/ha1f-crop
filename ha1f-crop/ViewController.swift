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
    
    private lazy var holeView = GridView()
    
    private lazy var holedDimView: HoledView = {
        let holedDimView = HoledView(frame: self.view.bounds)
        holedDimView.isUserInteractionEnabled = false
        holedDimView.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.5)
        return holedDimView
    }()
    
    var holeFrame: CGRect {
        set {
            holedDimView.holeFrame = newValue
            holeView.frame = newValue
        }
        get {
            return holedDimView.holeFrame
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(holedDimView)
        view.addSubview(holeView)
        
        let width: CGFloat = 300
        holeFrame = CGRect(x: (holedDimView.bounds.width - width) / 2,
                           y: (holedDimView.bounds.height - width) / 2,
                           width: width,
                           height: width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = imageView.image?.aspectFitRect(inside: view.bounds) ?? imageView.frame
    }
}

