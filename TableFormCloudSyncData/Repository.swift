//
//  Repository.swift
//  TableFormCloudSyncData
//
//  Created by Sebastiao Gazolla Costa Junior on 14/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation
import CloudKit

protocol RepositoryUser {
    
    func getUser (_ completion: @escaping ((_ user: User?) -> Void))
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func logout()
    
}

protocol RepositoryEmployees {
    
    func queryEmployees (startDate: Date, endDate: Date, completion: @escaping ([Employee], NSError?) -> Void)
    func queryEmployeesInDay (_ day: Date) -> [Employee]
    func queryEmployeesInDay (_ day: Date, completion: @escaping ([Employee], NSError?) -> Void)
    func queryUnsyncedEmployees() -> [Employee]
    func queryDeletedEmployees (_ completion: @escaping ([Employee]) -> Void)
    func queryUpdates (_ completion: @escaping ([Employee], [String], NSError?) -> Void)
    // Marks the Employee as deleted. If permanently is true it will be removed from db
    func deleteEmployee (_ employee: Employee, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void))
    func deleteEmployee (objectId: String, completion: @escaping ((_ success: Bool) -> Void))
    // Save a employee and returns the same employee with a employeeId generated if it didn't had
    func saveEmployee (_ employee: Employee, completion: @escaping ((_ employee: Employee) -> Void))
    
}

protocol RepositorySettings {
    
    func settings() -> Settings
    func saveSettings (_ settings: Settings)
    
}

typealias Repository = RepositoryUser & RepositoryEmployees & RepositorySettings



protocol Repo {
    associatedtype T
    func save (_ object:[String:AnyObject?], completion: @escaping ((_ object: T) -> Void))
    func save (_ object:CKRecord, completion: @escaping ((_ object: CKRecord) -> Void))
    func delete (objectId: String, completion: @escaping ((_ success: Bool) -> Void))
    func delete (_ object: T, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void))
    func queryUnsynced() -> [T]?
    func queryDeleted (_ completion: @escaping ([T]) -> Void)
    func query (completion: @escaping ([T], NSError?) -> Void)


}
