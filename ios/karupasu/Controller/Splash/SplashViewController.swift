//
//  SplashViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio

final class SplashViewController: UIViewController {

    let viewStream: SplashViewStreamType = SplashViewStream()
    private let disposeBag = DisposeBag()
    private var splashFlag = false
    private let animationTime = 2

    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func animation() {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: .init(self?.animationTime ?? 0),  animations: {
                for _ in 0...1 {
                    self?.logoView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/180*180)
                    self?.logoView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/180*360)
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        splashFlag = true
        DispatchQueue.global().async { [weak self] in
            while self?.splashFlag ?? false {
                DispatchQueue.global().async {
                    self?.animation()
                }
                sleep(UInt32(self?.animationTime ?? 0))
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        splashFlag = false
    }
}
