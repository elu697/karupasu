//
//  UIImageViewEx.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setImageByKingfisher(with url: URL?) {
        self.kf.setImage(with: url)
    }
    
//    func rotatedBy(degree: CGFloat, isCropped: Bool = true) -> UIImage {
//        let radian = -degree * CGFloat.pi / 180
//        var rotatedRect = CGRect(origin: .zero, size: self.size)
//        if !isCropped {
//            rotatedRect = rotatedRect.applying(CGAffineTransform(rotationAngle: radian))
//        }
//        UIGraphicsBeginImageContext(rotatedRect.size)
//        let context = UIGraphicsGetCurrentContext()!
//        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
//        context.scaleBy(x: 1.0, y: -1.0)
//        
//        context.rotate(by: radian)
//        context.draw(self.cgImage!, in: CGRect(x: -(self.size.width / 2), y: -(self.size.height / 2), width: self.size.width, height: self.size.height))
//        
//        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return rotatedImage
//    }
}
