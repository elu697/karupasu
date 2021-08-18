//
//  RootViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio

final class RootViewController: UIViewController {

    let viewStream: RootViewStreamType = RootViewStream()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

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
