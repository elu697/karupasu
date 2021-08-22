//
//  MemberTableViewCell.swift
//  karupasu
//
//  Created by El You on 2021/08/26.
//

import UIKit


class MemberTableViewCell: UITableViewCell {

    let containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()

    let titleView: MemberTitleView = {
        let view = MemberTitleView()
        return view
    }()

    let detailView: MemberDetailView = {
        let view = MemberDetailView()
        view.isHidden = true
        return view
    }()

    var isOpen: Bool = false {
        didSet {
            titleView.openBtn.rotate(degrees: !isOpen ? -90 : 90, animated: true)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        detailView.isHidden = true
        containerView.axis = .vertical
        addSubview(containerView)
        containerView.addArrangedSubview(titleView)
        containerView.addArrangedSubview(detailView)
        setupLayout()
    }

    private func setupLayout() {
        containerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().priority(.low)
            make.height.equalTo(48).priority(.low)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MemberTableViewCell {
    var isDetailViewHidden: Bool {
        return detailView.isHidden
    }

    func showDetailView() {
        detailView.isHidden = false
    }

    func hideDetailView() {
        detailView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
        if isDetailViewHidden, selected {
            showDetailView()
            isOpen = true
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.hideDetailView()
            }
            isOpen = false
        }
    }
}
