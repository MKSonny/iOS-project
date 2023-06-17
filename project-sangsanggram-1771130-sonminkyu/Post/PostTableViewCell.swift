//
//  PostTableViewCell.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/03.
//

import UIKit

// 다음과 같이 PostTableViewCellDelegate을 만든 이유는 이 클래스에는
// 파이어 스트리지와 연결되어 있지 않아 책임을 postGroupController로 넘김
protocol PostTableViewCellDelegate: AnyObject {
    func didTapLikeButton(post: Post)
    func didTapCommentButton(post: Post)
}

class PostTableViewCell: UITableViewCell {
    public weak var delegate: PostTableViewCellDelegate?
    
    // 게시글에 표시할 요소들을 위한 아웃렛 변수 선언
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // 이미지 원형으로 설정
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40/2.0
        return imageView
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let likeButton: UIButton = {
        let likeButton = UIButton()
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Create custom heart image with desired size for normal state
        let heartImage = UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate)
        let heartImageSize = CGSize(width: 30, height: 24)
        UIGraphicsBeginImageContextWithOptions(heartImageSize, false, 0)
        UIColor.red.setFill() // Set the fill color to red
        heartImage?.draw(in: CGRect(origin: .zero, size: heartImageSize))
        let resizedHeartImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        likeButton.setImage(resizedHeartImage, for: .normal)
        
        // Create custom heart image with desired size for selected state
        let filledHeartImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(heartImageSize, false, 0)
        UIColor.red.setFill() // Set the fill color to red
        filledHeartImage?.draw(in: CGRect(origin: .zero, size: heartImageSize))
        let resizedFilledHeartImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        likeButton.setImage(resizedFilledHeartImage, for: .selected)
        
        likeButton.tintColor = .red
        return likeButton
    }()
    
    let commentButton: UIButton = {
        let commentButton = UIButton()
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        // Create custom comment image with desired size
        let commentImage = UIImage(systemName: "message")?.withRenderingMode(.alwaysTemplate)
        let commentImageSize = CGSize(width: 27, height: 24)
        UIGraphicsBeginImageContextWithOptions(commentImageSize, false, 0)
        commentImage?.draw(in: CGRect(origin: .zero, size: commentImageSize))
        let resizedCommentImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        commentButton.setImage(resizedCommentImage, for: .normal)
        commentButton.tintColor = .black
        commentButton.addTarget(self, action: #selector(pushedCommentButton), for: .touchUpInside)
        return commentButton
    }()
    
    let dmButton: UIButton = {
        let dmButton = UIButton()
        dmButton.translatesAutoresizingMaskIntoConstraints = false
        // Create custom comment image with desired size
        let commentImage = UIImage(systemName: "paperplane")?.withRenderingMode(.alwaysTemplate)
        let commentImageSize = CGSize(width: 27, height: 24)
        UIGraphicsBeginImageContextWithOptions(commentImageSize, false, 0)
        commentImage?.draw(in: CGRect(origin: .zero, size: commentImageSize))
        let resizedCommentImage = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
        UIGraphicsEndImageContext()
        dmButton.setImage(resizedCommentImage, for: .normal)
        dmButton.tintColor = .black
        return dmButton
    }()

    
    let likesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    var post: Post? // Post 객체를 저장할 변수
    
    @objc func pushedLikeButton() {
        likeButton.isSelected = !likeButton.isSelected // 선택 상태 토글
        if likeButton.isSelected {
            post?.likes += 1
        } else {
            post?.likes -= 1
        }
        updateLikes() // 변경된 likes 값을 업데이트하여 화면에 반영
        delegate?.didTapLikeButton(post: post!)
    }
    
    @objc func pushedCommentButton() {
        delegate?.didTapCommentButton(post: post!)
    }
    
    private func updateLikes() {
        if let post = post {
            likesLabel.text = "\(post.likes)명이 좋아합니다"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.addTarget(self, action: #selector(pushedLikeButton), for: .touchUpInside)
        
        // 각 요소를 셀의 contentView에 추가
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(likesLabel)
        contentView.addSubview(dmButton)
        contentView.addSubview(captionLabel)
        contentView.addSubview(dateLabel)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            // 프로필 이미지뷰
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // 유저네임 레이블
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 8),
            usernameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            // 게시글 이미지뷰
            postImageView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor),
            
            // 좋아요 버튼
            likeButton.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12),
            likeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            commentButton.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12),
            commentButton.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 8),
            
            // dm 버튼
            dmButton.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 12),
            dmButton.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 8),
            
            // 좋아요 레이블
            likesLabel.topAnchor.constraint(equalTo: commentButton.bottomAnchor, constant: 8),
            likesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            
            // 캡션 레이블
            captionLabel.topAnchor.constraint(equalTo: likesLabel.bottomAnchor, constant: 6),
            captionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            captionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // 날짜 레이블
            dateLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setData(post: Post) {
        self.post = post
        downloadImage(imageView: profileImageView, url: URL(string: post.writerImage)!)
//        profileImageView.image = post.imageUrl
        usernameLabel.text = post.username
        downloadImage(imageView: postImageView, url: URL(string: post.imageUrl)!)
//        postImageView.image = post.imageUrl
        likesLabel.text = "\(post.likes)명이 좋아합니다"
        captionLabel.text = post.content
        dateLabel.text = post.date.toStringDateForPostTime()
        updateLikes()
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
