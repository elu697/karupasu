//
//  TalkRoomTableViewCell.swift
//  karupasu
//
//  Created by El You on 2021/10/22.
//

import UIKit


class TalkRoomTableViewCell: UITableViewCell {
    let thumbnailImage: UIImageView = {
        let view = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        view.image = AppImage.mock_thumb()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .appWhiteGray
        view.layer.cornerRadius = 28
        return view
    }()
    
    let placeLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .appFontBoldOfSize(11)
        lbl.textColor = .appMain
        lbl.textAlignment = .left
        return lbl
    }()
    
    let titleLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .appFontBoldOfSize(14)
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()
    
    let dateLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .appFontOfSize(9)
        lbl.textColor = .appTextGray
        lbl.textAlignment = .right
        return lbl
    }()
    
    let messageLbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .appFontOfSize(9)
        lbl.textColor = .appTextGray
        lbl.textAlignment = .left
        return lbl
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(thumbnailImage)
        addSubview(placeLbl)
        addSubview(titleLbl)
        addSubview(titleLbl)
        addSubview(dateLbl)
        addSubview(messageLbl)
        setupLayout()
    }
    
    private func setupLayout() {
        thumbnailImage.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(56)
            make.centerY.equalToSuperview()
        }
        
        placeLbl.snp.makeConstraints { make in
            make.height.equalTo(19)
            make.top.equalTo(11)
            make.left.equalTo(88)
        }
        
        titleLbl.snp.makeConstraints { make in
            make.height.equalTo(22)
            make.top.equalTo(28)
            make.left.equalTo(88)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setModel(model: ChatModel.Room) {
        thumbnailImage.setImageByKingfisher(with: .init(string: model.imageUrl))
        placeLbl.text = "\(model.prefecture) \(model.participantsCount)人"
        titleLbl.text = "\(model.title)"
        // 最新のトークをRxで購読したい
    }
}
