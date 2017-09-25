//
//  UIImage+Extension.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let imgRef = cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imgRef, scale: scale, orientation: imageOrientation)
    }
    
    func aspectFitRect(inside rect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: self.size, insideRect: rect)
    }
}
