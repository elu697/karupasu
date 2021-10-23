//
// Swift usefull extensions
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

extension UIViewController {
    /// Push ViewController on new NavigationController

    /// Sets the navigation bar menu on the left bar button.
    /// Also add the left gesture.
    internal func setLeftBackBarButtonItem(action: Selector = #selector(tappedBackButton), image: UIImage? = nil) {
        let barButtonItem = UIBarButtonItem()
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40)
        button.setImage(image, for: .normal)
        button.tintColor = .appMain
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: action, for: .touchUpInside)
        barButtonItem.customView = button
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 40).isActive = true
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.navigationItem.leftBarButtonItem = barButtonItem
    }

    /// Sets the navigation bar menu on the left bar button.
    /// Also add the left gesture.
    internal func setRightCloseBarButtonItem(action: Selector = #selector(tappedCloseButton), image: UIImage? = nil) {
        let barButtonItem = UIBarButtonItem()
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        button.setImage(image, for: .normal)
        button.tintColor = .appMain
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: action, for: .touchUpInside)
        barButtonItem.customView = button
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        self.navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc
    private func tappedBackButton() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc
    private func tappedCloseButton() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    internal func setSearchBar() -> UISearchBar? {
        if let navigationBarFrame = navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: AppText.inputKeyword(),
                                                                                 attributes: [NSAttributedString.Key.font: UIFont.appFontOfSize(11)])
            searchBar.searchTextField.layer.cornerRadius = navigationBarFrame.height * 0.4
            searchBar.searchTextField.layer.masksToBounds = true
            searchBar.searchTextField.font = .appFontOfSize(14)
            searchBar.tintColor = UIColor.gray
            searchBar.keyboardType = UIKeyboardType.default
            searchBar.searchTextField.clearButtonMode = .whileEditing

            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            return searchBar
        } else {
            return .none
        }
    }

    internal func setNavigationBarTitleString(title: String) {
        let titleLbl = UILabel()
        titleLbl.font = .appFontBoldOfSize(18)
        titleLbl.text = title
        titleLbl.sizeToFit()
        titleLbl.textColor = .appMain
        titleLbl.textAlignment = .center
        titleLbl.contentMode = .scaleAspectFit
        self.navigationItem.titleView = titleLbl
    }

    internal func hideNavigationWhenSwipeView() {
        let _: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dissmissView))

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dissmissView))
        swipe.direction = .down
        swipe.cancelsTouchesInView = false
        view.addGestureRecognizer(swipe)
    }
    
    func setSwipeBack() {
        let target = self.navigationController?.value(forKey: "_cachedInteractionController")
        let recognizer = UIPanGestureRecognizer(target: target, action: Selector(("handleNavigationTransition:")))
        self.view.addGestureRecognizer(recognizer)
    }

    internal func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        pan.cancelsTouchesInView = false
        view.addGestureRecognizer(pan)
    }

    @objc
    internal func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc
    internal func dissmissView() {
        self.dismiss(animated: true, completion: nil)
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    internal func pushNewNavigationController(rootViewController: UIViewController, completion: (() -> ())? = nil) {
//        let vc = UINavigationController(rootViewController: rootViewController)
        let vc = BaseNavigationViewController(rootViewController: rootViewController)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: completion)
    }

    internal func showAlert(title: String?, message: String?, _ okAction: @escaping ((UIAlertAction) -> Void), cancelAction: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "OK", style: .default, handler: okAction)
        let action2 = UIAlertAction(title: "キャンセル", style: .cancel, handler: cancelAction)

        alert.addAction(action1)
        if cancelAction != nil {
            alert.addAction(action2)
        }
        present(alert, animated: true, completion: nil)
    }

    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    var karupasu: Karupasu {
        return appDelegate.karupasu
    }
}


extension Reactive where Base: UIViewController {
    var viewWillAppear: Observable<Void> {
        return sentMessage(#selector(base.viewWillAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }

    var viewDidAppear: Observable<Void> {
        return sentMessage(#selector(base.viewDidAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }

    var viewWillDisappear: Observable<Void> {
        return sentMessage(#selector(base.viewWillDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }

    var viewDidDisappear: Observable<Void> {
        return sentMessage(#selector(base.viewDidDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
}

extension Reactive where Base: UIViewController {
    var viewWillAppearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewWillAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }

    var viewDidAppearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewDidAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }

    var viewWillDisappearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewWillDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }

    var viewDidDisappearInvoked: Observable<Void> {
        return methodInvoked(#selector(base.viewDidDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
}
