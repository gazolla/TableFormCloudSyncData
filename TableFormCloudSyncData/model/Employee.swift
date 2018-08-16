//
//  Employee+CoreDataClass.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Employee)
public class Employee: ManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }
    
    @NSManaged var lastModifiedDate: Date?
    @NSManaged var markedForDeletion: NSNumber?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var birthday: NSDate?
    @NSManaged public var address: String?
    @NSManaged public var company: String?
    @NSManaged public var position: String?
    @NSManaged public var salary: NSDecimalNumber?
    @NSManaged public var gender: Gender?

    class func findOrCreate(dic:[String:AnyObject?], in context:NSManagedObjectContext) throws -> Employee?{
        
        let request:NSFetchRequest<Employee> = Employee.fetchRequest()
        
        guard let email = dic["email"] as? String  else {
            return nil
        }
        
        request.predicate = NSPredicate(format: "email = %@", email)
        do{
            let matches = try context.fetch(request)
            if matches.count > 0 {
                var employee = matches[0]
                dicToObj(obj: &employee, dic: dic)
                return employee
            }
        } catch {
            throw error
        }
       
        var employee:Employee = Employee(context:context)
        dicToObj(obj: &employee, dic: dic)
        return employee
        
    }

}

