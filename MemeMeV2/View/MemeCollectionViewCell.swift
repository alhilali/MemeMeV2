//
//  MemeCollectionViewCell
//  MemeMeV2
//
//  Created by Saud Alhelali on 03/12/2018.
//  Copyright © 2018 Saud. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    
    var meme: Meme! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        image.image = meme.memedImage
    }
    
}
