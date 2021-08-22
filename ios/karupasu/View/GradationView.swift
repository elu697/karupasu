//
//  GradationView.swift
//  karupasu
//
//  Created by El You on 2021/08/23.
//

import UIKit

class GradationView: UIView {
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    func setGradation() {
        guard let gradientLayer = self.layer as? CAGradientLayer else {
            return
        }
        gradientLayer.type = .axial
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
    }
}
