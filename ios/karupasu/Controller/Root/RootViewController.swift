//
//  RootViewController.swift
//  karupasu
//
//  Created by El You on 2021/08/18.
//

import RxSwift
import UIKit
import Unio
import SVProgressHUD
//import FirebaseAppDistribution

/// スプラッシュとかログインとかホームを切り替える用のRootVC
final class RootViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    enum initializeStatus {
        case success
        case notLogin
        case error(type: errorType)
    }
    enum errorType {
        case login
    }
    
    enum presentViewType {
        case normal
        case splash
        case login
        case error(type: errorType)
    }

    private let viewStream: RootViewStreamType = RootViewStream()
    private let disposeBag = DisposeBag()
    private var currentViewController: UIViewController?

    private var tabBarMenuViewController: TabBarMenuViewController {
        return TabBarMenuViewController(rootViewStream: viewStream)
    }

    private var loginProcessViewController: BaseNavigationViewController {
        return .init(rootViewController: FirstTeamViewController(viewStream: self.viewStream))
    }

    private var eventCreateViewController: BaseNavigationViewController {
        return .init(rootViewController: EventCreateViewController())
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.popoverPresentationController?.delegate = self

        let input = viewStream.input
        let output = viewStream.output

        showSplashView()

        output.initializedApp
            .subscribe { [weak self] status in
                guard let me = self,
                    let status = status.element else { return }
                switch status {
                    case .success:
                        me.switchViewType(type: .normal)
                    case .notLogin:
                        me.switchViewType(type: .login)
                    case .error(let type):
                        me.switchViewType(type: .error(type: type))
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            input.launchApp(())
                        }
                }
            }
            .disposed(by: disposeBag)

        output.eventCreate
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.presentModal(to: me.eventCreateViewController)
            }
            .disposed(by: disposeBag)

        output.showLoginProcess
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.switchViewType(type: .login)
            }
            .disposed(by: disposeBag)
        
        output.switchView
            .subscribe { [weak self] type in
                guard let me = self,
                      let type = type.element else { return }
                me.switchViewType(type: type)
            }
            .disposed(by: disposeBag)
        
        checkFirebase { ok in
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                input.launchApp(())
            }
        }
    }
}

extension RootViewController {
    private func showSplashView() {
        if let vc = R.storyboard.splashViewController.instantiateInitialViewController() {
            self.transitionCurrentViewController(to: vc)
        }
    }
    
    private func checkFirebase(ok: @escaping (Bool) -> ()) {
//        AppDistribution.appDistribution().checkForUpdate(completion: { release, error in
//            guard let release = release else {
//                return
//            }
//            let title = "New Version Available"
//            let message = "Version \(release.displayVersion)(\(release.buildVersion)) is available."
//            let uialert = UIAlertController(title: title,message: message, preferredStyle: .alert)
//            
//            uialert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default) {
//                _ in
//                UIApplication.shared.open(release.downloadURL)
//            })
//            uialert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
//                _ in
//            })
//            self.present(uialert, animated: true, completion: nil)
//        })
        ok(true)
    }

    private func switchViewType(type: presentViewType) {
        switch type {
            case .login:
                let vc = loginProcessViewController
                self.transitionViewController(to: vc)
                break
            case .error:
                let vc = tabBarMenuViewController
//                self.transitionViewController(to: vc)
                SVProgressHUD.showError(withStatus: "通信エラーです\n再試行します")
                SVProgressHUD.dismiss(withDelay: 2)
                break
            case .normal:
                let vc = tabBarMenuViewController
                self.transitionViewController(to: vc)
                break
            case .splash:
                showSplashView()
        }
    }

    private func showLoginProcess() {
        let vc = loginProcessViewController
        currentViewController?.present(vc, animated: true, completion: nil)
    }

    private func transitionViewController(to: UIViewController) {
        guard let from = currentViewController else {
            return
        }
        addChild(to)
        transition(from: from, to: to, duration: 0.25, options: [.curveEaseIn, .transitionCrossDissolve, .preferredFramesPerSecond60]) {
        } completion: { (comp) in
            self.currentViewController = to
            from.removeFromParent()
        }
    }

    private func transitionCurrentViewController(to: UIViewController) {
        let from = currentViewController
        currentViewController = to
        self.addChild(to)
        view.addSubview(to.view)
        self.didMove(toParent: self)
        from?.removeFromParent()
    }

    private func presentModal(to: UIViewController) {
        to.modalPresentationStyle = .fullScreen
        currentViewController?.present(to, animated: true, completion: nil)
    }

    private func presentJoinTeam() {

    }

    private func presentLoginView() {

    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    // デフォルトの代わりにnoneを返すことで、iPhoneでもpopover表示ができるようになる
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    // Popoverの外をタップしたら閉じるべきかどうかを指定できる（吹き出し内のボタンで閉じたい場合に利用）
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}
