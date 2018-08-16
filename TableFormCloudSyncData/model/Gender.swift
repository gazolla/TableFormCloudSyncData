//
//  Gender+CoreDataClass.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Gender)
public class Gender: ManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gender> {
        return NSFetchRequest<Gender>(entityName: "Gender")
    }
    
    @NSManaged public var lastModifiedDate: Date?
    @NSManaged public var markedForDeletion: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var employees: NSSet?

    class func findOrCreate(dic:[String:AnyObject], in context:NSManagedObjectContext) throws -> Gender?{
        let request:NSFetchRequest<Gender> = Gender.fetchRequest()
        
        guard let email = dic["name"] as? String  else {
            return nil
        }
        
        request.predicate = NSPredicate(format: "name = %@", email)
        do{
            let matches = try context.fetch(request)
            if matches.count > 0 {
                let gender = matches[0]
                gender.name = dic["name"] as? String
                gender.employees = dic["gender"] as? NSSet
                return gender
            }
        } catch {
            throw error
        }
        
        var gender:Gender = Gender(context: context)
        dicToObj(obj: &gender, dic: dic)
        return gender
        
    }

}

extension Gender {
    public override var description: String {
        return "\(self.name ?? "")"
    }
}

extension Gender {
    public class func getGenders(context: NSManagedObjectContext)->[Gender] {
        var entities = [Gender]()
        let request:NSFetchRequest<Gender> = Gender.fetchRequest()
        do{
            entities = try context.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Gender]
        } catch {
            print(error)
        }
        return entities
    }
}

