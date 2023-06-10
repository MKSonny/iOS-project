//
//  FollowersTableViewCell.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import UIKit

class FollowersTableViewCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "hello world"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(usernameLabel)
        usernameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
