//
//  UIViewEx.swift
//  karupasu
//
//  Created by El You on 2021/08/25.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift


extension UIView {
    enum Direction {
        case top
        case bottom
    }

    func addShadow(direction: Direction) {
        switch direction {
        case .top:
            self.layer.shadowOffset = CGSize(width: 0.0, height: -2)
        case .bottom:
            self.layer.shadowOffset = CGSize(width: 0.0, height: 2)
        }
        self.layer.shadowRadius = 1.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
    }
    
    @objc
    internal func didTap() { }
}


protocol Rotatable {
    var transform: CGAffineTransform { get set }

    func rotate(degrees: CGFloat, animated: Bool)
    func rotate(radians: CGFloat, animated: Bool)

    var rotation: (radians: CGFloat, degrees: CGFloat) { get }
}

extension UIView: Rotatable {
    func rotate(degrees: CGFloat, animated: Bool = false) {
        rotate(radians: degreesToRadians(value: degrees), animated: animated)
    }

    func rotate(radians: CGFloat, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform(rotationAngle: radians)
            }
        } else {
            transform = CGAffineTransform(rotationAngle: radians)
        }
    }

    var rotation: (radians: CGFloat, degrees: CGFloat) {
        let radians = CGFloat(atan2f(Float(transform.b), Float(transform.a)))

        return (radians, radiansToDegrees(value: radians))
    }

    func degreesToRadians(value: CGFloat) -> CGFloat {
        return CGFloat.pi * value / 180.0
    }

    func radiansToDegrees(value: CGFloat) -> CGFloat {
        return value * 180 / CGFloat.pi
    }
}

extension Reactive where Base: UIView {
    var viewTap: Observable<Void> {
        base.addGestureRecognizer(UITapGestureRecognizer(target: base, action: #selector(UIView.didTap)))
        return sentMessage(#selector(base.didTap))
            .map { _ in ()}
            .share(replay: 1)
    }
}
