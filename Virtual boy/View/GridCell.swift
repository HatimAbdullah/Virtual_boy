//
//  GridCell.swift
//  Virtual boy
//
//  Created by Fish on 20/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {
    
    var media: Memory?  {
        didSet {
            //update the cell once the media is set
            if let data = media?.binary {
                photo.image = UIImage(data: data)
            }
            
        }
    }
    
    let photo: UIImageView =
    {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .cyan
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews()
    {
        //add media view + video icon
        addSubview(photo)
        
        //constraint media view + video icon
        addConstraints([
            photo.topAnchor.constraint(equalTo: self.topAnchor),
            photo.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            photo.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
    }
}
