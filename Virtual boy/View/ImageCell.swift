//
//  ImageCell.swift
//  Virtual boy
//
//  Created by Fish on 08/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit
import CoreData

class ImageCell: UICollectionViewCell {
    
    var saveObserverToken: Any?
    
    let canvas: UIImageView =
    {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var image: Photo?  {
        didSet {
//            photoID = image?.objectID
//            performOnMain {
//                self.canvas.image = nil
//                self.loadingIndicator.startAnimating()
//            }
//            if let imageData = image?.binary {
//                performOnMain {
//                    self.canvas.image = UIImage(data: imageData as Data)
//                    self.loadingIndicator.stopAnimating()
//                }
//            } else {
//                //let backgroundPhoto = DataController.shared.backgroundContext.object(with: self.photoID!) as! Photo
//                API.getInstance().downloadPhoto(imageURL: (image?.url)!, completionHandler: { (data , error) in
//                    if (error == nil) {
//                        DataController.shared.viewContext.perform {
//                            self.image?.binary = data
//                            try? DataController.shared.viewContext.save()
//                            performOnMain {
//                                self.canvas.image =  UIImage(data: self.image!.binary!)
//                                self.loadingIndicator.stopAnimating()
//                            }
//                        }
//                    }
//                })
//            }
        }
    }
    
    var photoID: NSManagedObjectID?
    
    let loadingIndicator: UIActivityIndicatorView =
    {
        let lod = UIActivityIndicatorView()
        lod.translatesAutoresizingMaskIntoConstraints = false
        return lod
    }()
    
    var taskToCancelifCellIsReused: URLSessionTask? {
          
          didSet {
              if let taskToCancel = oldValue {
                  taskToCancel.cancel()
              }
          }
      }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addSaveNotificationObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeSaveNotificationObserver()
    }
    
    func setupViews()
    {
        addSubview(canvas)
        addSubview(loadingIndicator)
        
        //constraint for image view
        addConstraints([
            canvas.topAnchor.constraint(equalTo: self.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
}

extension ImageCell {
    func addSaveNotificationObserver() {
        removeSaveNotificationObserver()
        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: DataController.shared.viewContext, queue: nil, using: handleSaveNotification(notification:))
    }
    
    func removeSaveNotificationObserver() {
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    func handleSaveNotification(notification: Notification) {
        // change in design lead to this method not being used - on later versions if the download image task moved to the background thread it might be used
    }
}
