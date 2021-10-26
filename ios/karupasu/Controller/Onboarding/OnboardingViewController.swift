//
//  OnboardingViewController.swift
//  karupasu
//
//  Created by El You on 2021/10/25.
//

import RxSwift
import UIKit
import Unio
import paper_onboarding

final class OnboardingViewController: UIViewController {

    let viewStream: OnboardingViewStreamType = OnboardingViewStream()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        let onboarding = PaperOnboarding()
        onboarding.dataSource = self
        onboarding.delegate = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        setRightCloseBarButtonItem(image: AppImage.close_gray())
        // add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
}

extension OnboardingViewController: PaperOnboardingDelegate {
    func onboardingWillTransitonToLeaving() {
        dismissView()
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
//        item
    }
    
}

extension OnboardingViewController: PaperOnboardingDataSource {
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        
        return [
            OnboardingItemInfo(informationImage: AppImage.ob_1()!,
                               title: "マッチマッチとは？",
                               description: "主催者がいない交流会\n参加者マッチングサービス。\nチームの仲を深めるお手伝いをします。",
                               pageIcon: AppImage.ob_1()!,
                               color: .appMain,
                               titleColor: .white,
                               descriptionColor: .white,
                               titleFont: .appFontBoldOfSize(20),
                               descriptionFont: .appFontBoldOfSize(14)),
            
            OnboardingItemInfo(informationImage: AppImage.ob_2()!,
                               title: "STEP1",
                               description: "まずは交流会のアイデアを\n匿名で投稿してみよう",
                               pageIcon: AppImage.ob_1()!,
                               color: .appMain,
                               titleColor: .white,
                               descriptionColor: .white,
                               titleFont: .appFontBoldOfSize(20),
                               descriptionFont: .appFontBoldOfSize(14)),
            
            OnboardingItemInfo(informationImage: AppImage.ob_3()!,
                               title: "STEP2",
                               description: "みんなが投稿した交流会の中から\n気になるものを探そう！",
                               pageIcon: AppImage.ob_1()!,
                               color: .appMain,
                               titleColor: .white,
                               descriptionColor: .white,
                               titleFont: .appFontBoldOfSize(20),
                               descriptionFont: .appFontBoldOfSize(14)),
            
            OnboardingItemInfo(informationImage: AppImage.ob_4()!,
                               title: "STEP3",
                               description: "参加したいボタンを押そう！\n確認や修正もできます",
                               pageIcon: AppImage.ob_1()!,
                               color: .appMain,
                               titleColor: .white,
                               descriptionColor: .white,
                               titleFont: .appFontBoldOfSize(20),
                               descriptionFont: .appFontBoldOfSize(14)),
            
            OnboardingItemInfo(informationImage: AppImage.ob_5()!,
                               title: "STEP4",
                               description: "人数が集まったらマッチ！\nグループチャットで詳しい計画をしよう",
                               pageIcon: AppImage.ob_1()!,
                               color: .appMain,
                               titleColor: .white,
                               descriptionColor: .white,
                               titleFont: .appFontBoldOfSize(20),
                               descriptionFont: .appFontBoldOfSize(14))
        ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 5
    }
    
    func onboardingPageItemColor(at index: Int) -> UIColor {
        return .white
    }
    
    func onboardinPageItemRadius() -> CGFloat {
        return 8
    }
    
    func onboardingPageItemSelectedRadius() -> CGFloat {
        return 22
    }
}
