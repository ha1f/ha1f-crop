//
//  UIImage+Extension.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit
import AVFoundation

extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self * CGFloat.pi / 180
    }
}

extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        guard let imgRef = cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: imgRef, scale: scale, orientation: imageOrientation)
    }
    
    /// https://stackoverflow.com/questions/40389215/swift-rotate-an-image-then-zoom-in-and-crop-to-keep-width-height-aspect-ratio
    func rotateAndCropped(degree: CGFloat) -> UIImage? {
        guard let ciImage = self.ciImage else {
            return nil
        }
        let rotated = ciImage.applyingFilter("CIStraightenFilter", parameters: [kCIInputAngleKey: degree.degreesToRadians()])
        return UIImage(ciImage: rotated)
    }
    
    /// http://blogs.innovationm.com/image-croprotateresize-handling-in-ios/
    func rotated(image: UIImage, angle: CGFloat, flipVertical: CGFloat, flipHorizontal: CGFloat) -> UIImage? {
        let ciImage = CIImage(image: image)
        
        guard let filter = CIFilter(name: "CIAffineTransform") else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setDefaults()
        
        let newAngle = angle * CGFloat(-1)
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        transform = CATransform3DRotate(transform, flipVertical * CGFloat.pi, 0, 1, 0)
        transform = CATransform3DRotate(transform, flipHorizontal * CGFloat.pi, 1, 0, 0)
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        
        filter.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
        
        let contex = CIContext(options: [kCIContextUseSoftwareRenderer: true])
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        guard let cgImage = contex.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    func masked(with image: UIImage) -> UIImage? {
        guard let maskRef = image.cgImage,
            let ref = cgImage,
            let dataProvider = maskRef.dataProvider else {
                return nil
        }
        
        let mask = CGImage(
            maskWidth: maskRef.width,
            height: maskRef.height,
            bitsPerComponent: maskRef.bitsPerComponent,
            bitsPerPixel: maskRef.bitsPerPixel,
            bytesPerRow: maskRef.bytesPerRow,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false)
        
        return mask
            .flatMap { ref.masking($0) }
            .map { UIImage(cgImage: $0) }
    }
    
    func aspectFitRect(inside rect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: self.size, insideRect: rect)
    }
}
