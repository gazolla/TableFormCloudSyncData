//
//  EmployeesController.swift
//  TableFormCoreData
//
//  Created by Sebastiao Gazolla Costa Junior on 11/10/17.
//  Copyright © 2017 Sebastiao Gazolla Costa Junior. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class EmployeesController: UITableViewController {
    
    var context:NSManagedObjectContext?
    
    lazy var employeeCtrl:EmployeeController = {
        let ec = EmployeeController()
        ec.context = self.context
        return ec
    }()

    lazy var fetchedResultsController: NSFetchedResultsController<Employee>? = {
        guard let context = context else { return nil }
        let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Employee.name), ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    
    fileprivate func loadData() {
        guard let fetchedRstCtrl = self.fetchedResultsController else { return }
        do {
            try fetchedRstCtrl.performFetch()
        } catch {
            print("Unable to Perform Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EmployeeCell.self, forCellReuseIdentifier:"cellid")
        
        title = "Employees"
        navigationController?.navigationBar.prefersLargeTitles = true
        let btn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEmployeeTapped))
        self.navigationItem.rightBarButtonItem = btn
        
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addItem), name: NSNotification.Name(rawValue: "AddEmployee"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteItem), name: NSNotification.Name(rawValue: "DeleteEmployee"), object: nil)
    }
    
    @objc func addItem(notification:Notification){
        guard let context = context else { return }
        if let record = notification.object as? CKRecord{
            // ================================
            // ToDo: Identify if the notification was fired by this User !!!
            //==================================
           let coreData = CDEmployee(context: context)
            coreData.save(record) { (record) in
              // something to do after save.....
            }
        } else {
            print("record not received")
        }
    }
    
    @objc func deleteItem(notification:Notification){
        guard let context = context else { return }
        if let recordId = notification.object as? CKRecordID{
          let coreData = CDEmployee(context: context)
            coreData.delete(objectId: recordId.recordName) { (success) in
                // something to do after delete....
            }
        } else {
            print("record not received")
        }
    }

    @objc func addEmployeeTapped(){
        var data = Employee().emptyDic()
        data.removeValue(forKey: "lastModifiedDate")
        data.removeValue(forKey: "markedForDeletion")
        data.removeValue(forKey: "objectId")
        employeeCtrl.data = data
        
        let nullDate:NSDate? = nil
        let hiddenData:[String:AnyObject?] = ["lastModifiedDate":nullDate, "markedForDeletion":0.0 as NSNumber?, "objectId":nil]
        employeeCtrl.hiddenData = hiddenData
        
        self.navigationController?.pushViewController(employeeCtrl, animated: true)
    }
    
}

extension EmployeesController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let fetchedRstCtrl = self.fetchedResultsController, let sections = fetchedRstCtrl.sections else { return 0 }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let fetchedRstCtrl = self.fetchedResultsController, let section = fetchedRstCtrl.sections?[section] else { return 0 }
        return section.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! EmployeeCell
        guard let fetchedRstCtrl = self.fetchedResultsController else { return cell }
        let employee = fetchedRstCtrl.object(at: indexPath)
        cell.employee = employee
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let fetchedRstCtrl = self.fetchedResultsController, let context = context else { return }
        let obj = fetchedRstCtrl.object(at: indexPath)
        let employee = CDEmployee(context:context)
        employee.delete(obj, permanently: true) { (ok) in
            // delete on cloudkit
        }
    }
    
}

extension EmployeesController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fetchedRstCtrl = self.fetchedResultsController else { return }
        let employee = fetchedRstCtrl.object(at: indexPath)
        employeeCtrl.title = "Edit Employee"
        employeeCtrl.data = employee.objToDic()
        self.navigationController?.pushViewController(employeeCtrl, animated: true)
    }
}

extension EmployeesController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? EmployeeCell {
                guard let fetchedRstCtrl = self.fetchedResultsController else { return }
                cell.employee = fetchedRstCtrl.object(at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
}

class EmployeeCell: UITableViewCell {
    
    var employee:Employee?{
        didSet{
            guard let p = employee else { return }
            self.textLabel?.text = "\(p.name!)"
            self.detailTextLabel?.text = p.email!
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required  public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override  open func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

