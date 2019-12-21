//
//  TimelineCell.swift
//  Virtual boy
//
//  Created by Fish on 20/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

//a protocol that delegates the cell's button excution
protocol TimelineCellDelegate {
    func deleteAndUpdate(forMedia media: Memory)
}

class TimelineCell: UICollectionViewCell, DetailsContainerDelegate {
    
    var cellDelegate: TimelineCellDelegate?
    
    var media: Memory?  {
        didSet {
            //update the cell once the media is set
            if let data = media?.binary {
                pictureContainer.image = UIImage(data: data)
                detailsContainer.updateUI(title: media?.place ?? " ", date: media?.date?.timeIntervalSince1970 ?? 0 * 1000)
            }
        }
    }
    
    let pictureContainer: UIImageView =
    {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var detailsContainer: StatisticsContainer =
    {
        let view = StatisticsContainer()
        view.buttonsDelegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        //add and constraint views
        addSubview(pictureContainer)
        addSubview(detailsContainer)
        
        
        addConstraints([
            pictureContainer.topAnchor.constraint(equalTo: topAnchor),
            pictureContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            pictureContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            pictureContainer.heightAnchor.constraint(equalToConstant: frame.height * 0.90)
        ])
        
        addConstraints([
            detailsContainer.topAnchor.constraint(equalTo: pictureContainer.bottomAnchor),
            detailsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            detailsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            detailsContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    func deleteButtonClicked(_ sender: UIButton) {
        guard let media = media else { return }
        cellDelegate?.deleteAndUpdate(forMedia: media)
    }
    
}
