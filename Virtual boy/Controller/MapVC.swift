//
//  ViewController.swift
//  Virtual boy
//
//  Created by Fish on 07/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var trashButton: UIBarButtonItem!
    var editMode = false
    
    var pins = [Pin]()
    
    enum UserDefaultsKeys: String {
        case Lat = "Latitude"
        case Lon = "Longitude"
        case latDel = "LatitudeDelta"
        case lonDel = "LongitudeDelta"
        case firstLaunch = "FirstLaunch"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        fetch()
        setGesture()
        
        //API.getInstance().getPhotos(lat: 0, lon: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func fetch() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "lon", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            pins = try DataController.shared.viewContext.fetch(fetchRequest)
        } catch {
            displayALert(title: "NO!", alert: "It won't load!", sender: self)
        }
        
        updatePins(pins)
    }
    
    
    func updatePins(_ pins: [Pin]) {
        
        var annotations = [MKPointAnnotation]()
       
        for pin in pins {
            let lat = CLLocationDegrees(pin.lat)
            let long = CLLocationDegrees(pin.lon)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            annotations.append(annotation)
        }
        
        self.map.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "annotation"
        var view: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func setUpMap() {
        
        map.delegate = self
        let defaults = UserDefaults.standard
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.firstLaunch.rawValue) {
            let centerLatitude  = defaults.double(forKey: UserDefaultsKeys.Lat.rawValue)
            let centerLongitude = defaults.double(forKey: UserDefaultsKeys.Lon.rawValue)
            let latitudeDelta   = defaults.double(forKey: UserDefaultsKeys.latDel.rawValue)
            let longitudeDelta  = defaults.double(forKey: UserDefaultsKeys.lonDel.rawValue)
            let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
            let spanCoordinate = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
            
            performOnMain {
                self.map.setRegion(region, animated: true)
            }
        } else {
            defaults.set(true, forKey: UserDefaultsKeys.firstLaunch.rawValue)
        }
    }
    
    // Save the region everytime we change the map
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(self.map.region.center.latitude, forKey: UserDefaultsKeys.Lat.rawValue)
        defaults.set(self.map.region.center.longitude, forKey: UserDefaultsKeys.Lon.rawValue)
        defaults.set(self.map.region.span.latitudeDelta, forKey: UserDefaultsKeys.latDel.rawValue)
        defaults.set(self.map.region.span.longitudeDelta, forKey: UserDefaultsKeys.lonDel.rawValue)
    }
    
    @objc func longPressed(_ sender: Any) {
        
        let lpg = sender as? UILongPressGestureRecognizer
        
        let pressPoint = lpg?.location(in: map)
        let pressCoordinate = map.convert(pressPoint!, toCoordinateFrom: map)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = pressCoordinate
        
        let annotations = map.annotations
        
        var isFound = false
        for annotationEntry in annotations {
            if (annotationEntry.coordinate.latitude == pressCoordinate.latitude && annotationEntry.coordinate.longitude == pressCoordinate.longitude) {
                isFound = true
                break
            }
        }
        
        if !isFound {
            
            // Add map annotation
            self.map.addAnnotation(annotation)
            
            // Persist the location to the core data
            let pin = Pin(context: DataController.shared.viewContext)
            pin.lat = annotation.coordinate.latitude
            pin.lon = annotation.coordinate.longitude
            try? DataController.shared.viewContext.save()
            pins.append(pin)
            importUrls(pin: pin)
            
        }
        
    }
    
    private func importUrls(pin: Pin) {
        API.getInstance().getPhotos(lat: pin.lat, lon: pin.lon, completionHandler: { (resultUrls, resultTitles, pages, error ) in
            if (error == nil) {
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
            }
            else {
                displayALert(title: "i can't see past your phone", alert: "there is some networky thing wrong", sender: self )
            }
        })
    }
    
    private func setGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        longPressGesture.minimumPressDuration = 1.0
        self.map.addGestureRecognizer(longPressGesture)
    }
    
    @IBAction func trashPins(_ sender: Any) {
        if !editMode {
            editMode = true
            trashButton.title = "Done"
        } else {
            editMode = false
            trashButton.title = "Edit"
        }
    }
    
}

extension MapVC {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        let coordinate = view.annotation?.coordinate
        if editMode {
            // Delete
            let annotations = map.annotations
            for pin in annotations {
                if pin.coordinate.latitude == (coordinate!.latitude) && pin.coordinate.longitude == (coordinate!.longitude) {
                    
                    let annotationToRemove = view.annotation
                    self.map.removeAnnotation(annotationToRemove!)
                    let fetchedPin = getPin(lon: coordinate!.longitude, lat: coordinate!.latitude)
                    if let pinTodelete = fetchedPin {
                        DataController.shared.viewContext.delete(pinTodelete)
                        try? DataController.shared.viewContext.save()
                    }
                    break
                }
            }
        } else {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "AlbumVC") as! AlbumVC
            // Grab the location object from Core Data
            let selctedPin = self.getPin(lon: coordinate!.longitude, lat: coordinate!.latitude)
            if let pinToPass = selctedPin {
                vc.pin = pinToPass
                
                self.navigationController?.pushViewController(vc, animated: false)
            }
        }
    }
    
    private func getPin(lon: Double, lat: Double) -> Pin? {
        for pin in pins {
            if pin.lat == lat && pin.lon == lon {
                return pin
            }
        }
        return nil
    }
}



