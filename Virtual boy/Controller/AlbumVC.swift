//
//  AlbumVC.swift
//  Virtual boy
//
//  Created by Fish on 07/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AlbumVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var renewButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var pin: Pin?
    var placeString: String?
    lazy var fetchedPhotosController: NSFetchedResultsController<Photo> = {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
        // TODO: create the fetched results controller
        let fetchedPhotosController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedPhotosController
    }()
    
    var photoToDelete = [IndexPath]()
    var insertIndexes = [IndexPath]()
    var deleteIndexes = [IndexPath]()
    var updateIndexes = [IndexPath]()
    var downloadCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedPhotosController.delegate = self
        fetch()
        setUpMap()
        configureCV()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //fetchedPhotosController = nil
    }
    
    private func setUpMap() {
        
        map.delegate = self
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin?.lat ?? 0
        annotation.coordinate.longitude = pin?.lon ?? 0
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: pin?.lat ?? 0, longitude: pin?.lon ?? 0)
        let spanCoordinate = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
        extractLocationName()
        
        performOnMain {
            self.map.setRegion(region, animated: true)
            self.map.addAnnotation(annotation)
        }
    }
    
    private func extractLocationName() {
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: pin?.lat ?? 0, longitude: pin?.lon ?? 0)
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Location name
            if let city = placeMark.subAdministrativeArea, let state = placeMark.administrativeArea, let country = placeMark.country {
                self.placeString = "\(country), \(state), \(city)"
            }
        })
    }
    
    func fetch() {
        do {
            try fetchedPhotosController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
        
        if fetchedPhotosController.fetchedObjects?.count == 0 {
            displayALert(title: "it's no use", alert: "no human ever stepped a foot on this land", sender: self)
        }
    }
    
    @IBAction func renewPhotos(_ sender: Any) {
        if (renewButton.title == "renew") {
            clearPin()
            let pages = Int("\(pin!.pages)")
            let page = Int.random(in: 0 ..< pages!)
            self.collectionView.isHidden = false
            importUrls(pin: pin!, page: page)
            downloadImages()
        } else {
            deleteSelectedImage()
        }
    }
    
    @IBAction func savePhoto(_ sender: Any) {
        var photo: Photo?
        for index in photoToDelete {
            photo = fetchedPhotosController.object(at: index)
        }
        
        DataController.shared.viewContext.perform {
            let memory = Memory(context: DataController.shared.viewContext)
            memory.binary = photo?.binary
            memory.place = self.placeString
            memory.date = Date()
            try? DataController.shared.viewContext.save()
        }
        // Update UI
        saveButton.isEnabled = false
        let cell = collectionView.cellForItem(at: photoToDelete[0])
        cell?.alpha = 1
        
        // reset indexes
        photoToDelete.removeAll()
        
    }
    
    
    private func clearPin() {
        if let objects = fetchedPhotosController.fetchedObjects {
            for object in objects {
                DataController.shared.viewContext.delete(object)
            }
            try? DataController.shared.viewContext.save()
        }
    }
    
    
    private func deleteSelectedImage() {
        
        for index in photoToDelete {
            DataController.shared.viewContext.delete(fetchedPhotosController.object(at: index))
        }
        // reset indexes
        photoToDelete.removeAll()
        // core data save. Fetch results controller will magically update the UI
        try? DataController.shared.viewContext.save()
        
        // Update UI
        renewButton.title = "renew"
        saveButton.isEnabled = false
    }
    
    private func importUrls(pin: Pin, page: Int) {
        API.getInstance().getPhotos(lat: pin.lat, lon: pin.lon, page: page,completionHandler: { (resultUrls, resultTitles, pages, error ) in
            if (error == nil) {
                if (resultUrls?.count == 0) {
                    performOnMain {
                        self.collectionView.isHidden = true
                    }
                }
                for urlString in resultUrls! {
                    DataController.shared.viewContext.perform {
                        let photo = Photo(context: DataController.shared.viewContext)
                        pin.pages = Int32(pages!)
                        photo.binary = nil
                        photo.url = urlString
                        photo.pin = pin
                        try? DataController.shared.viewContext.save()
                    }
                }
            } else {
                displayALert(title: "i can't see past your phone", alert: "there is some networky thing wrong", sender: self )
            }
        })
    }
    
    private func configureCV() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "imageCell")
        saveButton.isEnabled = false
    }
    
    private func downloadImages() {
        DataController.shared.performBackgroundBatchOperation { (workerContext) in
            for image in self.fetchedPhotosController.fetchedObjects! {
                if image.binary == nil {
                    _ = API.getInstance().downloadPhoto(imageURL: image.url!, completionHandler: { (imageData, error) in
                        
                        if (error == nil) {
                            image.binary = imageData
                        }
                        else {
                            print("***** Download error")
                        }
                    })
                }
            }
        }
    }
    
}

extension AlbumVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedPhotosController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        
        performOnMain {
            cell.canvas.image = nil
            cell.loadingIndicator.startAnimating()
        }
        
        let photo = fetchedPhotosController.object(at: indexPath)
        if let imageData = photo.binary {
            
            performOnMain {
                cell.canvas.image = UIImage(data: imageData as Data)
                cell.loadingIndicator.stopAnimating()
                
                if (self.downloadCounter > 0) {
                    self.downloadCounter = self.downloadCounter - 1
                }
                if self.downloadCounter == 0 {
                    self.renewButton.isEnabled = true
                }
                
            }
        }
        else {
            // Download image
            self.downloadCounter = self.downloadCounter + 1
            let task = API.getInstance().downloadPhoto(imageURL: photo.url!, completionHandler: { (imageData, error) in
                if (error == nil) {
                    
                    performOnMain {
                        // Note : No need to assign the cell image here. The core data save will trigger
                        // the event to update this cell anyway later.
                        cell.loadingIndicator.stopAnimating()
                        if (self.downloadCounter > 0) {
                            self.renewButton.isEnabled = false
                        }
                    }
                    
                    DataController.shared.viewContext.perform {
                        photo.binary = imageData
                    }
                } else {
                    print("***** Download error")
                }
            })
            cell.taskToCancelifCellIsReused = task
        }
        
        //cell.image = photo
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellDimension = (view.frame.width/3) - 2
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Get the specific cell
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        if (!photoToDelete.contains(indexPath)) {
            // Add to selected index
            photoToDelete.append(indexPath)
            // Change selected cell color
            cell?.alpha = 0.5
        } else {
            // Remove index from selected indexes
            let index = photoToDelete.firstIndex(of: indexPath)
            photoToDelete.remove(at: index!)
            // Change selected cell color
            cell?.alpha = 1
        }
        
        // Whenever user selects one or more cells, the bar button changes to Remove seleceted pictures
        // else set to default title
        if (photoToDelete.count == 0) {
            saveButton.isEnabled = false
            renewButton.title = "renew"
        } else {
            saveButton.isEnabled = true
            renewButton.title = "remove!"
        }
    }
}

extension AlbumVC: NSFetchedResultsControllerDelegate {
    
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

