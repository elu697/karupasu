//
//  TabBarItemView.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import UIKit
import ESTabBarController_swift
import pop

class TabBarItemView: ESTabBarItemContentView {
    var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconColor = .appGray
        highlightIconColor = .appMain
        
        textColor = .clear
        highlightTextColor = .clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateLayout() {
        super.updateLayout()
        self.imageView.sizeToFit()
        self.imageView.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
    
    override func badgeChangedAnimation(animated: Bool, completion: (() -> ())?) {
        super.badgeChangedAnimation(animated: animated, completion: nil)
        notificationAnimation()
    }
    
    func notificationAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        impliesAnimation.values = [0.0 ,-8.0, 4.0, -4.0, 3.0, -2.0, 0.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = CAAnimationCalculationMode.cubic
        
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}
