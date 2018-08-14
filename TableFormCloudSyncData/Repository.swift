//
//  Repository.swift
//  TableFormCloudSyncData
//
//  Created by Sebastiao Gazolla Costa Junior on 14/08/2018.
//  Copyright © 2018 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import Foundation

protocol RepositoryUser {
    
    func getUser (_ completion: @escaping ((_ user: User?) -> Void))
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func logout()
    
}

protocol RepositoryTasks {
    
    func queryTasks (startDate: Date, endDate: Date, completion: @escaping ([Task], NSError?) -> Void)
    func queryTasksInDay (_ day: Date) -> [Task]
    func queryTasksInDay (_ day: Date, completion: @escaping ([Task], NSError?) -> Void)
    func queryUnsyncedTasks() -> [Task]
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void)
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void)
    // Marks the Task as deleted. If permanently is true it will be removed from db
    func deleteTask (_ task: Task, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void))
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void))
    // Save a task and returns the same task with a taskId generated if it didn't had
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void))
    
}

protocol RepositorySettings {
    
    func settings() -> Settings
    func saveSettings (_ settings: Settings)
    
}

typealias Repository = RepositoryUser & RepositoryTasks & RepositorySettings
