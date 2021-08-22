//
//  RegistrationView.swift
//  karupasu
//
//  Created by El You on 2021/08/19.
//

import UIKit

class RegistrationView: UIView {
    let backBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(AppImage.navi_back_gray(), for: .normal)
        btn.tintColor = .appGray
        return btn
    }()
    
    let registrationLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontBoldOfSize(22)
        lbl.text = AppText.signUp()
        lbl.textAlignment = .center
        return lbl
    }()
    
    let passwordTxf: LoginProcessTextField = {
        let txf = LoginProcessTextField(placeHolderText: AppText.passwordDammy())
        txf.layer.cornerRadius = 5
        txf.isSecureTextEntry = true
        txf.keyboardType = .alphabet
        return txf
    }()
    
    let passwordLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontOfSize(14)
        lbl.text = AppText.password()
        return lbl
    }()
    
    let mailaddressTxf: LoginProcessTextField = {
        let txf = LoginProcessTextField(placeHolderText: AppText.mailAddressDammy())
        txf.layer.cornerRadius = 5
        txf.keyboardType = .emailAddress
        return txf
    }()
    
    let mailaddressLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontOfSize(14)
        lbl.text = AppText.mailAddress()
        return lbl
    }()
    
    let nameTxf: LoginProcessTextField = {
        let txf = LoginProcessTextField(placeHolderText: AppText.nameDammy())
        txf.layer.cornerRadius = 5
        return txf
    }()
    
    let nameLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontOfSize(14)
        lbl.text = AppText.name()
        return lbl
    }()
    
    let signupBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appMain
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.registration(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        btn.layer.borderColor = UIColor.white.cgColor
        return btn
    }()
    
    let signinBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appMain
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.login(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .appFontOfSize(11)
        lbl.text = AppText.or()
        lbl.backgroundColor = .appMain
        lbl.textAlignment = .center
        return lbl
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(registrationLbl)
        addSubview(passwordTxf)
        addSubview(passwordLbl)
        addSubview(mailaddressTxf)
        addSubview(mailaddressLbl)
        addSubview(nameTxf)
        addSubview(nameLbl)
        addSubview(signupBtn)
        addSubview(signinBtn)
        addSubview(barView)
        addSubview(messageLbl)
        addSubview(backBtn)
        initLayout()
    }
    
    func initLayout() {
        passwordTxf.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
        }
        
        passwordLbl.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(passwordTxf.snp.top).offset(-8)
        }
        
        mailaddressTxf.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(passwordTxf.snp.top).offset(-50)
        }
        
        mailaddressLbl.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mailaddressTxf.snp.top).offset(-8)
        }
        
        nameTxf.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(mailaddressTxf.snp.top).offset(-50)
        }
        
        nameLbl.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(nameTxf.snp.top).offset(-8)
        }
        
        registrationLbl.snp.makeConstraints { (make) in
            make.width.equalTo(132)
            make.centerX.equalToSuperview()
            make.top.lessThanOrEqualTo(safeAreaInsets.top)
            make.bottom.equalTo(nameLbl.snp.top)
        }
        
        signupBtn.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordTxf.snp.bottom).offset(48)
        }
        
        signinBtn.snp.makeConstraints { (make) in
            make.width.equalTo(56)
            make.height.equalTo(26)
            make.centerX.equalToSuperview()
            make.top.equalTo(signupBtn.snp.bottom).offset(83)
        }
        
        barView.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(1)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(signinBtn.snp.top).offset(-16)
        }
        
        messageLbl.snp.makeConstraints { (make) in
            make.center.equalTo(barView)
            make.width.equalTo(50)
            make.height.equalTo(19)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(30)
            make.top.equalTo(10 + safeAreaInsets.top)
            make.left.equalTo(16)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backBtn.snp.updateConstraints { (make) in
            make.width.height.equalTo(30)
            make.top.equalTo(10 + safeAreaInsets.top)
            make.left.equalTo(16)
        }
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
