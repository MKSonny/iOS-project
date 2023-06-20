//
//  TumbnailCollectionReusableView.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/06.
//

import UIKit
import FirebaseAuth

protocol ProfileInfoHeaderCollectionReusableViewDelegate: AnyObject {
    func didTapFollowingButton()
}

class ProfileInfoHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileInfoHeaderCollectionReusableView"
    public weak var delegate: ProfileInfoHeaderCollectionReusableViewDelegate?
    
    public let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public let postsCountLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let postsButton: UIButton = {
        let button = UIButton()
        button.setTitle("게시물", for: .normal)
        return button
    }()
    
    private let followingButton: UIButton = {
        let button = UIButton()
        button.setTitle("팔로잉", for: .normal)
        button.addTarget(self, action: #selector(didPressedFollowingButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didPressedFollowingButton() {
        delegate?.didTapFollowingButton()
    }
    
    private let followersButton: UIButton = {
        let button = UIButton()
        button.setTitle("팔로워", for: .normal)
        return button
    }()
    
    public func nameLabelText(name: String) {
        nameLabel.text = name
    }
    
    private let editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Your Profile", for: .normal)
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sonny"
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "explain"
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        backgroundColor = .systemBlue
        clipsToBounds = true
    }
    
    private func addSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(followersButton)
        addSubview(followingButton)
        addSubview(postsCountLabel)
        addSubview(postsButton)
        addSubview(bioLabel)
        addSubview(nameLabel)
        addSubview(editProfileButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let profilePhotoSize = width/4
        profilePhotoImageView.frame = CGRect(x: 5, y: 5, width: profilePhotoSize, height: profilePhotoSize).integral
        
        let buttonHeight = profilePhotoSize/2
        let countButtonWidth = (width - 10 - profilePhotoSize)/3
        
        let layoutYPos = CGFloat(45)
        
        postsButton.frame = CGRect(x: profilePhotoImageView.right, y: layoutYPos, width: countButtonWidth, height: buttonHeight).integral
        
        postsCountLabel.frame = CGRect(x: postsButton.center.x - 5, y: layoutYPos - 30, width: countButtonWidth, height: buttonHeight).integral
        
        profilePhotoImageView.layer.cornerRadius = profilePhotoSize/2.0
        
        followersButton.frame = CGRect(x: postsButton.right, y: layoutYPos, width: countButtonWidth, height: buttonHeight).integral
        
        followingButton.frame = CGRect(x: followersButton.right, y: layoutYPos, width: countButtonWidth, height: buttonHeight).integral
        
        editProfileButton.frame = CGRect(x: profilePhotoImageView.right, y: layoutYPos + buttonHeight, width: countButtonWidth * 3, height: buttonHeight).integral
        
        nameLabel.frame = CGRect(x: 5, y: 5 + profilePhotoImageView.bottom, width: width - 10, height: 50).integral
        
        let bioLabelSize = bioLabel.sizeThatFits(frame.size)
        
        bioLabel.frame = CGRect(x: 5, y: 5 + nameLabel.bottom, width: width - 10, height: bioLabelSize.height).integral
        
        editProfileButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }
    
    @objc func logOut() {
        try? Auth.auth().signOut()
    }
    
    
}
