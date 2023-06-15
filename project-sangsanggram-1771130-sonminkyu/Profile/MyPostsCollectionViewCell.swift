//
//  MyPostsCollectionViewCell.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/15.
//

import UIKit

class MyPostsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postImageView: UIImageView!
    
    public func configure(withImage imageName: String) {
        downloadImage(imageView: postImageView, url: URL(string: imageName)!)
    
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
