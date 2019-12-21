//
//  TimelineContainerCell.swift
//  Virtual boy
//
//  Created by Fish on 20/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit
import CoreData

protocol PresentNewViews {
    func moveToTImelineView(index: IndexPath)
}

class TimelineContainerCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate, TimelineCellDelegate {
    
    //cell detailes
    let timelineCellId = "timelineCellId"
    
    var insertIndexes = [IndexPath]()
    var deleteIndexes = [IndexPath]()
    var updateIndexes = [IndexPath]()
    
    
    
    lazy var fetchedPhotosController: NSFetchedResultsController<Memory> = {
        let fetchRequest: NSFetchRequest<Memory> = Memory.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // TODO: create the fetched results controller
        let fetchedPhotosController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedPhotosController
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceVertical = true
        cv.backgroundColor = .white
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchedPhotosController.delegate = self
        fetch()
        setUpViews()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews(){
        //add the timeline collection view
        addSubview(collectionView)
        
        //constraint the timeline collection view
        addConstraints([
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        //register the timeline collection view cells
        collectionView.register(TimelineCell.self, forCellWithReuseIdentifier: timelineCellId)
        
    }
    
    func fetch() {
        do {
            try fetchedPhotosController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func deleteAndUpdate(forMedia media: Memory) {
        
        DataController.shared.viewContext.delete(media)
        // core data save. Fetch results controller will magically update the UI
        try? DataController.shared.viewContext.save()
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedPhotosController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //locate the correct media file
        let photo = fetchedPhotosController.object(at: indexPath)
        
        //dequeue and return cell
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineCellId, for: indexPath) as? TimelineCell {
            //assign the cell's media + delegate
            cell.cellDelegate = self
            cell.media = photo
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: frame.width, height: frame.height * 0.75)
    }
    
    
}

extension TimelineContainerCell: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reset indexes
        insertIndexes.removeAll()
        deleteIndexes.removeAll()
        updateIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Assigned all the indexes so that we can update the cell accordingly
        
        switch (type) {
        case .insert:
            insertIndexes.append(newIndexPath!)
        case .delete:
            deleteIndexes.append(indexPath!)
        case .update:
            updateIndexes.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates( {
            self.collectionView.insertItems(at: insertIndexes)
            self.collectionView.deleteItems(at: deleteIndexes)
            self.collectionView.reloadItems(at: updateIndexes)
        }, completion: nil)
    }
}
