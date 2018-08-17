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
    typealias T = [String:AnyObject?]
    
    func save(_ object: [String:AnyObject?], completion: @escaping (([String:AnyObject?]) -> Void)) {
        guard let context = context else { return }
        do{
            _ = try Employee.findOrCreate(dic:object, in: context)
            try context.save()
            completion(object)
        } catch {
            print(error)
        }
    }
    
    
    
}
