//
//  CommentViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/16.
//

import UIKit
import FirebaseAuth

class CommentViewController: UIViewController {
    
    var commentTableView: UITableView!
    var post: Post!
    var commentKeys: [String]!
    var commentTextField: UITextField!
    var postGroup: PostGroup!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "댓글"
        
        view.backgroundColor = .white
        
        commentTableView = UITableView()
        commentTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(commentTableView)
        commentTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "CommentTableViewCell")
        
        NSLayoutConstraint.activate([
            commentTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            commentTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            commentTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            commentTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50), // Adjusted bottom anchor to make room for commentTextField
        ])
        
        commentTextField = UITextField()
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        commentTextField.placeholder = "댓글 달기..."
        view.addSubview(commentTextField)
        
        let commentButton = UIButton(type: .system)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setTitle("보내기", for: .normal)
        commentButton.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        view.addSubview(commentButton)
        
        NSLayoutConstraint.activate([
            commentTextField.topAnchor.constraint(equalTo: commentTableView.bottomAnchor, constant: 8),
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            commentTextField.trailingAnchor.constraint(equalTo: commentButton.leadingAnchor, constant: -8),
            
            commentButton.topAnchor.constraint(equalTo: commentTextField.topAnchor),
            commentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            commentButton.widthAnchor.constraint(equalToConstant: 80),
            commentButton.heightAnchor.constraint(equalTo: commentTextField.heightAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentTableView.dataSource = self
        commentKeys = post.comments.compactMap { $0.keys.first }
    }
    
    @objc func postComment() {
        guard let comment = commentTextField.text, !comment.isEmpty else {
            return
        }
        
        // Add the comment to the post's comments dictionary
        let currentUserUID = Auth.auth().currentUser?.uid
        let newComment: [String: String] = [
            currentUserUID!: comment
        ]
        post.comments.append(newComment)
        postGroup.saveChange(post: post, action: .Modify)
        
        // Clear the comment text field
        commentTextField.text = nil
        
        // Reload the table view to reflect the updated comments
        commentTableView.reloadData()
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        let commentDictionary = post.comments[indexPath.row]
        let commentKey = commentDictionary.keys.first
        let commentValue = commentDictionary[commentKey!]
            
        
        MyUserFirebaseDatabase.shared.findUsernameAndProfileImageWithUid(with: commentKey!) { username, profileUrl in
            cell.setData(profileUrl: profileUrl, username: username, comment: commentValue)
        }
        return cell
    }
}

