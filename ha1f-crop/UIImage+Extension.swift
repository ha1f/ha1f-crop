//
//  UIImage+Extension.swift
//  ha1f-crop
//
//  Created by ST20591 on 2017/09/25.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit

extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self * CGFloat.pi / 180
    }
}

// この透過カットやってみたい
// https://github.com/tomohisa/UIImage-Trim
extension UIImage {
    func cropped(to rect: CGRect) -> UIImage? {
        var cgImage: CGImage? = self.cgImage
        if cgImage == nil {
            if let ciImage = self.ciImage ?? CIImage(image: self) {
                let context = CIContext(options: nil)
                cgImage = context.createCGImage(ciImage, from: ciImage.extent)
            }
        }
        guard let unwrappedCGImage = cgImage else {
            print("converting cgimage error")
            return nil
        }
        guard let imgRef = unwrappedCGImage.cropping(to: rect) else {
            print("cropping error")
            return nil
        }
        return UIImage(cgImage: imgRef, scale: scale, orientation: imageOrientation)
    }
    
    /// https://stackoverflow.com/questions/40389215/swift-rotate-an-image-then-zoom-in-and-crop-to-keep-width-height-aspect-ratio
    func rotatedAndCropped(angle: CGFloat) -> UIImage? {
        let ciImage = self.ciImage ?? CIImage(image: self)
        let rotated = ciImage?.applyingFilter("CIStraightenFilter", parameters: [kCIInputAngleKey: -angle])
        return rotated.map { UIImage(ciImage: $0) }
    }
    
    /// http://blogs.innovationm.com/image-croprotateresize-handling-in-ios/
    func rotated(angle: CGFloat, flipVertical: CGFloat = 0.0, flipHorizontal: CGFloat = 0.0) -> UIImage? {
        let ciImage = self.ciImage ?? CIImage(image: self)
        
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
    
    static func empty(size: CGSize, color: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static func circle(size: CGSize, color: UIColor, backgroundColor: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        
        // background
        context.setFillColor(backgroundColor.cgColor)
        context.fill(frame)
        
        // circle
        context.setFillColor(color.cgColor)
        context.setLineWidth(0)
        context.addEllipse(in: frame)
        context.fillPath()
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func withSettingBackground(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        context.draw(self.cgImage!, in: frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// black or transparent
    func blacked(inverse: Bool = false) -> UIImage? {
        if inverse {
            guard let mask = UIImage.empty(size: size, color: .white)?.masked(with: self)?.withSettingBackground(color: .black) else {
                return nil
            }
            return UIImage.empty(size: size, color: .black)?.masked(with: mask)
        } else {
            return UIImage.empty(size: size, color: .black)?.masked(with: self)
        }
    }
    
    func withTransparentWhite() -> UIImage? {
        return self.masked(with: self)
    }
    
    func masked(with image: UIImage) -> UIImage? {
        guard let maskRef = image.cgImage,
            let ref = cgImage,
            let dataProvider = maskRef.dataProvider else {
                return nil
        }
        
        let mask = CGImage(maskWidth: maskRef.width,
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
}
