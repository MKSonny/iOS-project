//
//  FollowingTableViewCell.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/09.
//

import UIKit

class FollowingTableViewCell: UITableViewCell {
    
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
        contentView.addSubview(profileImageView)
        // Set up constraints for profileImageView
        contentView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true // Set desired width
        profileImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true // Set desired height
        // Set up constraints for usernameLabel
        usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10).isActive = true
        usernameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
    }
    
    func setData(profileUrl: String?, username: String?) {
        if let urlStr = profileUrl, let url = URL(string: urlStr) {
            downloadImage(imageView: profileImageView, url: url)
        } else {
            profileImageView.image = UIImage(named: "default_profile_image")
        }
        usernameLabel.text = username
    }
    
    override func layoutSubviews() {
            super.layoutSubviews()
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2 // Set the corner radius after the frame has been determined
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
