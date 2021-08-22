//
//  FirstTeamView.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import UIKit

class FirstTeamView: UIView {
    let teamCodeTxf: LoginProcessTextField = {
        let txf = LoginProcessTextField(placeHolderText: AppText.teamCodeDammy())
        txf.layer.cornerRadius = 5
        txf.keyboardType = .alphabet
        return txf
    }()
    
    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontOfSize(14)
        lbl.text = AppText.teamCodeMessage()
        return lbl
    }()
    
    let logoImageView: UIImageView = {
        let view = UIImageView(image: AppImage.logo())
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(teamCodeTxf)
        addSubview(messageLbl)
        addSubview(logoImageView)
        initLayout()
    }
    
    func initLayout() {
        teamCodeTxf.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
        }
        
        messageLbl.snp.makeConstraints { (make) in
            make.width.equalTo(teamCodeTxf)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(teamCodeTxf.snp.top).offset(-8)
        }
        
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(170)
            make.bottom.equalTo(messageLbl.snp.top).offset(-25)
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
