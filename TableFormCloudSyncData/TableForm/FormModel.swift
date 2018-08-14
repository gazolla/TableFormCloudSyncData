//
//  FomrModel.swift
//  TableFormCoreData
//
//  Created by Gazolla on 23/06/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation
import CoreData

protocol FormModel {
    
    static var dateFmtr:DateFormatter { get }
    static var NumFmtr:NumberFormatter { get }
    func emptyDic()->[String:AnyObject?]
    func objToDic()->[String:AnyObject?]
    static func dicToObj<T:NSManagedObject>( obj:inout T, dic:[String:AnyObject?])
    
}

public class ManagedObject: NSManagedObject, FormModel {
   
    static var dateFmtr:DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }
    
    static var NumFmtr:NumberFormatter {
        let f = NumberFormatter()
        f.generatesDecimalNumbers = true
        return f
    }
    
    func emptyDic()->[String:AnyObject?]{
        var dict = [String:AnyObject?]()
        for (name, attr) in  self.entity.attributesByName {
            let attrClass = attr.attributeValueClassName
            if attrClass == "NSDate" {
                dict[name] = Date() as AnyObject
            } else if attrClass == "NSDecimalNumber" {
                dict[name] = 0.0 as AnyObject
            } else {
                dict[name] = "" as AnyObject
            }
        }
        for (name, _) in  self.entity.relationshipsByName {
            dict[name] = nil
        }
        return dict
    }
    
    func objToDic()->[String:AnyObject?]{
        
        var dict = [String:AnyObject?]()
        for (name, _) in  self.entity.attributesByName {
            dict[name] = self.value(forKey: name) as AnyObject
        }
        for (name, _) in  self.entity.relationshipsByName {
            dict[name] = self.value(forKey: name) as AnyObject
        }
        return dict
    }
    
    static func dicToObj<T:NSManagedObject>(obj: inout T, dic: [String : AnyObject?]) {
        
        for (name, attr) in  obj.entity.attributesByName {
            let attrClass = attr.attributeValueClassName
            print(attrClass!)
            if attrClass == "NSDate" {
                let dt = dateFmtr.date(from: (dic[name] as? String)!)! as NSDate
                obj.setValue(dt, forKey: name)
            } else if attrClass == "NSDecimalNumber" {
                let numberString = dic[name] as! String
                let decimalSeparator = Locale.current.decimalSeparator ?? "."
                let characters = "-0123456789" + decimalSeparator
                let decimalFilter  = CharacterSet(charactersIn:characters)
                let cleanNumberStr = numberString.components(separatedBy:decimalFilter.inverted).joined(separator:"")
                let number = NSDecimalNumber(string: cleanNumberStr, locale:Locale.current)
                obj.setValue(number, forKey: name)
            } else {
                obj.setValue(dic[name] as Any, forKey: name)
            }
        }
        for (name, _) in  obj.entity.relationshipsByName {
            obj.setValue(dic[name] as Any, forKey: name)
        }
    }
}
