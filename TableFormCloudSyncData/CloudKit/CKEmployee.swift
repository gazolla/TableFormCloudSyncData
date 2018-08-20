//
//  CKEmployee.swift
//  TableFormCloudSyncData
//
//  Created by Gazolla on 20/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation
import CloudKit

class CKEmployee:Repo{
    typealias T = CKRecord
    let subscriptionID = "EmployeeSubID"
    var cloudKitObserver:NSObjectProtocol?

    func save(_ object: [String : AnyObject?], completion: @escaping ((CKRecord) -> Void)) {
        let f = DateFormatter()
        f.dateStyle = .medium
        
        let database = CKContainer.default().privateCloudDatabase
        if let record = object["record"] as? CKRecord {
            record["name"] = object["name"] as? CKRecordValue
            record["email"] = object["email"] as? CKRecordValue
            record["birthday"] = f.date(from: (object["birthday"] as! String))! as CKRecordValue
            record["address"] = object["address"] as? CKRecordValue
            record["company"] = object["company"] as? CKRecordValue
            record["position"] = object["position"] as? CKRecordValue
            record["gender"] = object["gender"] as? CKRecordValue
            database.save(record) { (record, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddEmployee"), object: record)
            }
        } else {
            addNew(object)
        }
    }
    
    func addNew(_ object:[String:AnyObject?]){
        let f = DateFormatter()
        f.dateStyle = .medium
        
        let database = CKContainer.default().privateCloudDatabase
        let record = CKRecord(recordType: "Employee")
        record["name"] = object["name"] as? CKRecordValue
        record["email"] = object["email"] as? CKRecordValue
        record["birthday"] = f.date(from: (object["birthday"] as! String))! as CKRecordValue
        record["address"] = object["address"] as? CKRecordValue
        record["company"] = object["company"] as? CKRecordValue
        record["position"] = object["position"] as? CKRecordValue
        record["gender"] = object["gender"] as? CKRecordValue
        database.save(record) { (record, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddEmployee"), object: record)
        }
    }
    
    func delete(objectId: String, completion: @escaping ((Bool) -> Void)) {
        
    }
    
    func delete(_ object: CKRecord, permanently: Bool, completion: @escaping ((Bool) -> Void)) {
        let database = CKContainer.default().privateCloudDatabase
        database.delete(withRecordID: object.recordID) { (recordID, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func queryUnsynced() -> [CKRecord]? {
       return nil
    }
    
    func queryDeleted(_ completion: @escaping ([CKRecord]) -> Void) {
        
    }
    
    func query(completion: @escaping ([CKRecord], NSError?) -> Void) {
        let database = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Employee", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            completion(records!, nil)
        }
    }
    
    func iCloudSubscribe(){
        let database = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let subscription = CKQuerySubscription(recordType: "Employee", predicate: predicate, subscriptionID: subscriptionID, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        
        let info = CKNotificationInfo()
        info.shouldSendContentAvailable = true
        subscription.notificationInfo = info
        
        database.save(subscription) { (savedSubscription, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func toDic(record:CKRecord) -> [String:AnyObject?]{
        var result = [String:AnyObject?]()
        result["name"] = record["name"] as? NSString
        result["email"] = record["email"] as? NSString
        result["birthday"] = record["birthday"] as? NSDate
        result["address"] = record["address"] as? NSString
        result["company"] = record["company"] as? NSString
        result["position"] = record["position"] as? NSString
        result["gender"] = record["gender"] as? CKReference
        return result
    }
    
}
