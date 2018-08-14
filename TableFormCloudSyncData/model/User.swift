//
//  User.swift
//  TableFormCloudSyncData
//
//  Created by Sebastiao Gazolla Costa Junior on 14/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation

struct User {
    var email: String?
    var userId: String?
}

typealias UserCredentials = (email: String, password: String)
