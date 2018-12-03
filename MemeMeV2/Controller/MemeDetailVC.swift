//
//  MemeDetailVC.swift
//  MemeMeV2
//
//  Created by Saud Alhelali on 03/12/2018.
//  Copyright © 2018 Saud. All rights reserved.
//

import UIKit

class MemeDetailVC: UIViewController {

    @IBOutlet weak var image: UIImageView!
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateUI()
    }
    
    func updateUI() {
        image.image = meme.memedImage
    }

}
