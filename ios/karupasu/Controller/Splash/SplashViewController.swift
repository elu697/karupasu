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

    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIView.animate(withDuration: 10,  animations: { [weak self] in
            for _ in 0...100 {
                self?.logoView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/180*180)
                self?.logoView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/180*360)
            }
        })
        /*
         *  EXAMPLE:
         *
         *  let input = viewStream.input
         *
         *  button.rx.tap
         *      .bind(to: input.accept(for: \.buttonTap))
         *      .disposed(by: disposeBag)
         */

        /*
         *  EXAMPLE:
         *
         *  let output = viewStream.output
         *
         *  output.observable(for: \.isEnabled)
         *      .bind(to: button.rx.isEnabled)
         *      .disposed(by: disposeBag)
         *
         *  print("rawValue of isEnabled = \(output.value(for: \.isEnabled))")
         */
    }
}
