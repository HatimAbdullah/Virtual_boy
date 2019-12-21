//
//  GridContainerCell.swift
//  Virtual boy
//
//  Created by Fish on 20/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit
import CoreData

class GridContainerCell: UICollectionViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //cell detailes
    let gridCellId = "gridCellId"
    
    var insertIndexes = [IndexPath]()
    var deleteIndexes = [IndexPath]()
    var updateIndexes = [IndexPath]()
    
    var presentDelgate: PresentNewViews!
    
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
        layout.minimumInteritemSpacing = 1
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
    
    private func setUpViews(){
        //add grid collection view
        addSubview(collectionView)
        
        //set the collection's constraint
        addConstraints([
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        //register cells for the collection view
        collectionView.register(GridCell.self, forCellWithReuseIdentifier: gridCellId)
        
    }
    
    func fetch() {
        do {
            try fetchedPhotosController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellId, for: indexPath) as? GridCell {
            //assign the cell's media
            cell.media = photo
            return cell
        }
        return UICollectionViewCell()
    }
    
    //called in case an item was selected
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //present to the user the timeline view of the selected media
            presentDelgate.moveToTImelineView(index: indexPath)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //set the cell size to a third of the width
        let cellDimension = (frame.width/3) - 1
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GridContainerCell: NSFetchedResultsControllerDelegate {
    
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

