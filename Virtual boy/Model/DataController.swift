//
//  DataController.swift
//  Virtual boy
//
//  Created by Fish on 07/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static let shared = DataController()

    private let persistentContainer: NSPersistentContainer

    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext:NSManagedObjectContext!

    private init() {
        persistentContainer = NSPersistentContainer(name: "Virtual_boy")
    }
    
    func configureContexts() {
        backgroundContext = persistentContainer.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

// MARK: - Autosaving

extension DataController {
    private func autoSaveViewContext(interval:TimeInterval = 30) {
        let timeInterval = interval > 0 ? interval : 30
        if interval <= 0 {
            // just informing the developer that something wrong has happened
            print("time interval should be greater than 0, will use the default time interval")
        }

        if viewContext.hasChanges {
            try? viewContext.save()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) {
            self.autoSaveViewContext(interval: timeInterval)
        }
    }
    
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
      
      func performBackgroundBatchOperation(_ batch: @escaping Batch) {
          
          backgroundContext.perform() {
              
              batch(self.backgroundContext)
              
              // Save it to the parent context, so normal saving
              // can work
              do {
                  try self.backgroundContext.save()
              } catch {
                  fatalError("Error while saving backgroundContext: \(error)")
              }
          }
      }
    
}

