//
//  ScreenOverView.swift
//  karupasu
//
//  Created by El You on 2021/10/26.
//

import UIKit

class ScreenOverView: UIView {
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .appMain
        view.alpha = 0.9
        return view
    }()
    
    
    let logoImageView: UIImageView = {
        let view = UIImageView(image: AppImage.ob_1())
        return view
    }()
    
    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontBoldOfSize(14)
        lbl.text = AppText.matchMessage()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        return lbl
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundView)
        addSubview(logoImageView)
        addSubview(messageLbl)
        backgroundColor = .appMain
        initLayout()
    }
    
    func initLayout() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.height.equalTo(179)
        }
        
        messageLbl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(9)
            make.width.equalToSuperview().inset(34)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */

}
