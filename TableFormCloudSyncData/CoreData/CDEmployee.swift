//
//  CDEmployee.swift
//  TableFormCloudSyncData
//
//  Created by Gazolla on 17/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation
import CoreData

class CDEmployee: Repo {
    var context:NSManagedObjectContext?
    typealias T = Employee
    
    init(context:NSManagedObjectContext){
        self.context = context
    }
    
    func save(_ object: [String : AnyObject?], completion: @escaping ((Employee) -> Void)) {
        guard let context = context else { return }
        do{
            let emp = try Employee.findOrCreate(dic:object, in: context)
            try context.save()
            completion(emp!)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func delete(objectId: String, completion: @escaping ((Bool) -> Void)) {
        
    }
    
    func delete(_ object: Employee, permanently: Bool, completion: @escaping ((Bool) -> Void)) {
        guard let context = context else { return }
        context.delete(object)
        do{
            try context.save()
            completion(true)
        } catch {
            print(error)
        }
    }
    
    func queryUnsynced() -> [Employee]? {
        guard let context = context else { return nil }
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        var subpredicates = [
            NSPredicate(format: "markedForDeletion == NO || markedForDeletion == nil")
        ]
        if let sinceDate = UserDefaults.standard.localChangeDate {
            subpredicates.append(NSPredicate(format: "lastModifiedDate == nil || lastModifiedDate > %@", sinceDate as CVarArg))
        } else {
            subpredicates.append(NSPredicate(format: "lastModifiedDate == nil"))
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        fetchRequest.predicate = compoundPredicate
        var result:[Employee]? = nil
        do {
            result = try context.fetch(fetchRequest)
        } catch {
            print("Failed")
        }
        return result
    }
    
    func queryDeleted(_ completion: @escaping ([Employee]) -> Void) {
        guard let context = context else { return }
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        let predicate = NSPredicate(format: "markedForDeletion == YES")
        fetchRequest.predicate = predicate
        do {
            let result = try context.fetch(fetchRequest)
            completion(result)
        } catch {
            print("Failed")
        }
    }
    
    func query(completion: @escaping ([Employee], NSError?) -> Void) {
        guard let context = context else { return }
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Employee.name), ascending: false)]
        do {
            let result = try context.fetch(fetchRequest)
             completion(result, nil)
        } catch {
            print("Failed")
        }
    }
}
