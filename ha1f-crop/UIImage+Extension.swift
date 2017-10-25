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
    func radiansToDegrees() -> CGFloat {
        return self / CGFloat.pi * 180
    }
}

// この透過カットやってみたい
// https://github.com/tomohisa/UIImage-Trim
extension UIImage {
    var safeCiImage: CIImage? {
        return self.ciImage ?? CIImage(image: self)
    }
    
    var safeCgImage: CGImage? {
        if let cgImge = self.cgImage {
            return cgImge
        }
        if let ciImage = safeCiImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }
    
    /// Create UIImage by cropping current image with the specified rectangle.
    ///
    /// - parameter rect: The rectangle to crop
    ///
    /// - returns: The cropped image. Nil on error.
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = safeCgImage else {
            debugPrint("converting cgimage error")
            return nil
        }
        guard let imgRef = cgImage.cropping(to: rect) else {
            debugPrint("cropping error")
            return nil
        }
        return UIImage(cgImage: imgRef, scale: scale, orientation: imageOrientation)
    }
    
    /// Create UIImage by rotating current image and crop center to keep image-size.
    /// The image size may not be changed
    /// https://stackoverflow.com/questions/40389215/swift-rotate-an-image-then-zoom-in-and-crop-to-keep-width-height-aspect-ratio
    ///
    /// - parameter angle: Angle to rotate
    ///
    /// - returns: The rotated image. Nil on error.
    func rotatedAndCropped(angle: CGFloat) -> UIImage? {
        guard let ciImage = safeCiImage else {
            return nil
        }
        let rotated = ciImage.applyingFilter("CIStraightenFilter", parameters: [kCIInputAngleKey: -angle])
        return UIImage(ciImage: rotated)
    }
    
    
    /// Create UIImage by rotating current image.
    /// The image size may changed to covert as rectangle
    /// http://blogs.innovationm.com/image-croprotateresize-handling-in-ios/
    ///
    /// - parameter angle: Angle to rotate
    /// - parameter flipVertical: Whether the image will be flipped vertically or not. Defaults to false
    /// - parameter flipHorizontal: Whether the image will be flipped horizontally or not. Defaults to false
    ///
    /// - returns: The rotated image. Nil on error.
    func rotated(angle: CGFloat, flipVertical: Bool = false, flipHorizontal: Bool = false) -> UIImage? {
        guard let ciImage = safeCiImage else {
            return nil
        }
        
        guard let filter = CIFilter(name: "CIAffineTransform") else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setDefaults()
        
        let newAngle = angle * CGFloat(-1)
        
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        transform = CATransform3DRotate(transform, (flipVertical ? 1.0 : 0) * CGFloat.pi, 0, 1, 0)
        transform = CATransform3DRotate(transform, (flipHorizontal ? 1.0 : 0) * CGFloat.pi, 1, 0, 0)
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        
        filter.setValue(NSValue(cgAffineTransform: affineTransform), forKey: kCIInputTransformKey)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        let context = CIContext(options: [kCIContextUseSoftwareRenderer: true])
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Create UIImage by drawing current image on colored context.
    ///
    /// - parameter color: Color of the background context
    ///
    /// - returns: The created image. Nil on error.
    func withSettingBackground(color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        guard let cgImage = safeCgImage else {
            return nil
        }
        let frame = CGRect(origin: .zero, size: size)
        context.clear(frame)
        context.setFillColor(color.cgColor)
        context.fill(frame)
        context.draw(cgImage, in: frame)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create UIImage of black or transparent.
    /// CIImage-masking treats white as transparent, while CALayer-masking
    /// treats transparent as transparent.
    /// For this reason, we should make white of UIImage transparent to use
    /// the CIImage-masking image for CALayer-masking image.
    ///
    /// - parameter inverse: Invert transparent area or not
    ///
    /// - returns: The created image. Nil on error.
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
    
    /// Create UIImage by masking current image with another image.
    /// Treat white as transparent.
    ///
    /// - parameter image: Image for masking
    ///
    /// - returns: The created image. Nil on error.
    func masked(with image: UIImage) -> UIImage? {
        guard let maskRef = image.safeCgImage,
            let ref = safeCgImage,
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
    
    func transformed(angle: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        guard let cgImage = safeCgImage else {
            return nil
        }
        
        let frame = CGRect(origin: .zero, size: size)
        
        // clear
        context.clear(frame)
        
        // background
        context.setFillColor(UIColor.black.cgColor)
        context.fill(frame)
        
        // rotate
        context.translateBy(x: frame.midX, y: frame.midY)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: angle)
        
        // image
        context.draw(cgImage, in: frame.offsetBy(dx: -frame.midX, dy: -frame.midY))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImage {
    
    /// Create UIImage filled with a color.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color to fill
    ///
    /// - returns: The created image. Nil on error.
    static func empty(size: CGSize, color: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
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
    
    /// Create UIImage of circle.
    ///
    /// - parameter size: Size of output image
    /// - parameter color: Color of the circle
    /// - parameter backgroundColor: Background color of the image
    ///
    /// - returns: The created image. Nil on error.
    static func circle(size: CGSize, color: UIColor, backgroundColor: UIColor = .clear) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
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
    
    /// Create UIImage by drawing text.
    ///
    /// - parameter text: string to draw
    /// - parameter fontSize: size of text
    ///
    /// - returns: The created image. Nil on error.
    static func fromText(text: String, fontSize: CGFloat) -> UIImage? {
        let attributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.paragraphStyle: NSMutableParagraphStyle.default
        ]
        let imageSize = (text as NSString).size(withAttributes: attributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.setTextDrawingMode(CGTextDrawingMode.fill)
        
        let textRect = CGRect(origin: .zero, size: imageSize)
        text.draw(in: textRect, withAttributes: attributes)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
