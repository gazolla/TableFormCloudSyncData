//
//  Sync.swift
//  TableFormCloudSyncData
//
//  Created by Sebastiao Gazolla Costa Junior on 14/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation

class Sync<T> {
    
    fileprivate let localRepository: Repository!
    fileprivate let remoteRepository: Repository!
    fileprivate var objectsToSave = [Employee]()
    fileprivate var objectsToDelete = [Employee]()
    
    init (localRepository: Repository, remoteRepository: Repository) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func start (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        
        objectsToSave = localRepository.queryUnsyncedEmployees()
        print("1. unsyncedEmployees = \(self.objectsToSave.count)")
        localRepository.queryDeletedEmployees { deletedEmployees in
            print("1. deletedEmployees = \(deletedEmployees.count)")
            self.objectsToDelete = deletedEmployees
            self.syncNext { (success) in
                self.getLatestServerChanges(completion)
            }
        }
    }
    
    // Send to CloudKit the changes recursivelly then call the completion block
    fileprivate func syncNext (_ completion: @escaping ((_ success: Bool) -> Void)) {
        
        var employee = objectsToSave.first
        if employee != nil {
            objectsToSave.remove(at: 0)
            saveEmployee(employee!, completion: { (success) in
                self.syncNext(completion)
            })
        } else {
            employee = objectsToDelete.first
            if employee != nil {
                objectsToDelete.remove(at: 0)
                deleteEmployee(employee!, completion: { (success) in
                    self.syncNext(completion)
                })
            } else {
                UserDefaults.standard.localChangeDate = Date()
                completion(true)
            }
        }
    }
    
    func saveEmployee (_ employee: Employee, completion: @escaping ((_ success: Bool) -> Void)) {
        
        print("sync save \(employee)")
        _ = remoteRepository.saveEmployee(employee) { (uploadedEmployee) in
            print("save uploadedEmployee \(uploadedEmployee)")
            // After employee was saved to server update it to local datastore
            _ = self.localRepository.saveEmployee(uploadedEmployee, completion: { (employee) in
                completion(true)
            })
        }
    }
    
    func deleteEmployee (_ employee: Employee, completion: @escaping ((_ success: Bool) -> Void)) {
        
        print("sync delete \(employee)")
        _ = remoteRepository.deleteEmployee(employee, permanently: true) { (uploadedEmployee) in
            // After employee was saved to server update it to local datastore
            _ = self.localRepository.deleteEmployee(employee, permanently: true, completion: { (employee) in
                completion(true)
            })
        }
    }
    
    fileprivate func getLatestServerChanges (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        
        print("2. getLatestServerChanges")
        remoteRepository.queryUpdates { changedEmployees, deletedEmployeesIds, error in
            for employee in changedEmployees {
                self.localRepository.saveEmployee(employee, completion: { (employee) in
                    print("saved to local db")
                })
            }
            for remoteId in deletedEmployeesIds {
                self.localRepository.deleteEmployee(objectId: remoteId, completion: { (success) in
                    print(">>>>  deleted from local db: \(remoteId) \(success)")
                })
            }
            completion(changedEmployees.count > 0 || deletedEmployeesIds.count > 0)
        }
    }
}
