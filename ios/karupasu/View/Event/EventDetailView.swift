//
//  EventDetailView.swift
//  karupasu
//
//  Created by El You on 2021/08/21.
//

import UIKit

class EventDetailView: UIView {
    let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.image = nil
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .appGray
        return view
    }()

    let bookmarkBtn: UIButtonSwitch = {
        let btn = UIButtonSwitch(type: .custom)
        btn.setSwitchBtn(on: AppImage.button_bookmark_big_yellow(), off: AppImage.button_bookmark_big_white())
        return btn
    }()

    let numberLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.font = .appFontOfSize(11)
        return lbl
    }()

    let genreLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Genre"
        lbl.font = .appFontBoldOfSize(14)
        lbl.textAlignment = .left
        lbl.textColor = .appMain
        lbl.backgroundColor = .clear
//        lbl.lineBreakMode = .byWordWrapping
        return lbl
    }()

    let placeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Place"
        lbl.font = .appFontBoldOfSize(14)
        lbl.textAlignment = .left
        lbl.textColor = .appMain
        lbl.backgroundColor = .clear
        return lbl
    }()

    let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Title"
        lbl.font = .appFontBoldOfSize(22)
        lbl.textAlignment = .left
        lbl.textColor = .black
        lbl.backgroundColor = .clear
        lbl.numberOfLines = 2
        lbl.lineBreakMode = .byTruncatingMiddle
        return lbl
    }()

    let applyBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .appMain
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.apply(), for: .normal)
        btn.setTitleColor(.white, for: .normal)
//        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        return btn
    }()

    let cancelBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.titleLabel?.font = .appFontBoldOfSize(14)
        btn.setTitle(AppText.cancel(), for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 24
        btn.layer.borderColor = UIColor.gray.cgColor
        btn.isHidden = true
        return btn
    }()

    let barView: UIView = {
        let view = UIView()
        view.backgroundColor = .appGray
        return view
    }()

    let memberLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = AppText.participant()
        lbl.font = .monospacedSystemFont(ofSize: 19, weight: .black)// Robotoがいい
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.backgroundColor = .clear
        return lbl
    }()

    let memberTableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.tableFooterView = .init(frame: .zero)
        return view
    }()

    var isJoined: Bool = false {
        willSet {
            applyBtn.isHidden = newValue
            cancelBtn.isHidden = !newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(thumbnailImage)
        addSubview(bookmarkBtn)
        addSubview(numberLbl)
        addSubview(genreLbl)
        addSubview(placeLbl)
        addSubview(titleLbl)
        addSubview(applyBtn)
        addSubview(cancelBtn)
        addSubview(barView)
        addSubview(memberLbl)
        addSubview(memberTableView)
        initLauout()
    }
    
    func initLauout() {
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(snp.width).multipliedBy(0.64)
        }
        
        bookmarkBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(thumbnailImage).inset(16)
            make.width.height.equalTo(44)
        }
        
        numberLbl.snp.makeConstraints { (make) in
            make.edges.equalTo(bookmarkBtn)
        }
        
        genreLbl.snp.makeConstraints { (make) in
            make.top.equalTo(thumbnailImage.snp.bottom).offset(16)
            make.left.equalToSuperview().inset(16)
//            make.width.equalTo(98)
            make.height.equalTo(26)
        }
        
        placeLbl.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(genreLbl)
            make.left.equalTo(genreLbl.snp.right).offset(24)
        }
        
        titleLbl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            //            make.height.equalTo(80)
            make.top.equalTo(genreLbl.snp.bottom).offset(4)
        }
        
        applyBtn.snp.makeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(48)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLbl.snp.bottom).offset(16)
        }
        
        cancelBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(applyBtn)
        }
        
        barView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(cancelBtn.snp.bottom).offset(24)
        }
        
        memberLbl.snp.makeConstraints { (make) in
            make.top.equalTo(barView.snp.bottom).offset(16)
            make.left.equalTo(16)
//            make.width.equalTo(58)
            make.height.equalTo(33)
        }
        
        memberTableView.snp.makeConstraints { (make) in
            make.top.equalTo(memberLbl.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let navigationHeight = safeAreaInsets.top
        thumbnailImage.snp.updateConstraints { (make) in
            make.top.equalTo(navigationHeight)
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
