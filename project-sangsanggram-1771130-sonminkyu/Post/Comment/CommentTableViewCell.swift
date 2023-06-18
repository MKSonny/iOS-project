//
//  CommentTableViewCell.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/17.
//

import UIKit

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        usernameLabel.font = UIFont.boldSystemFont(ofSize: 16)
//                commentLabel.font = UIFont.systemFont(ofSize: 16)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
        
        // Apply constraints
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            profileImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -1),
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            contentView.heightAnchor.constraint(equalToConstant: 60),
//            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            usernameLabel.bottomAnchor.constraint(lessThanOrEqualTo: commentLabel.topAnchor, constant: -1),

            commentLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            commentLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
//            commentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            commentLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(profileUrl: String?, username: String?, comment: String?) {
        if let urlStr = profileUrl, let url = URL(string: urlStr) {
            downloadImage(imageView: profileImageView, url: url)
        } else {
            profileImageView.image = UIImage(named: "default_profile_image")
        }
        usernameLabel.text = username
        commentLabel.text = comment
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}


