//
//  UserDefaults.swift
//  TableFormCloudSyncData
//
//  Created by Sebastiao Gazolla Costa Junior on 16/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    var localChangeDate: Date? {
        get {
            return self.object(forKey: "localChangeDate") as? Date
        }
        set {
            self.set(newValue, forKey: "localChangeDate")
        }
    }
}
