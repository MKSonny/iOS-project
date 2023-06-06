//
//  AddPostViewController.swift
//  project-sangsanggram-1771130-sonminkyu
//
//  Created by son on 2023/06/05.
//

import UIKit

class AddPostViewController: UIViewController {

    @IBOutlet weak var addPostImageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addPostImageView.image = image
    }
}
