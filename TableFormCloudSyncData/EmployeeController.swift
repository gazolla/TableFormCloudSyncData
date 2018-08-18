//
//  MyFormView.swift
//  TableForm
//
//  Created by Gazolla on 05/10/17.
//  Copyright © 2017 Gazolla. All rights reserved.
//

import UIKit
import CoreData

class EmployeeController: FormViewController {
    var context:NSManagedObjectContext?
    
    func createFieldsAndSections()->[[Field]]{
        let name = Field(name:"name", title:"Name:", cellType: NameCell.self)
        let birth = Field(name:"birthday", title:"Birthday:", cellType: DateCell.self)
        let address = Field(name:"address", title:"Address:", cellType: TextCell.self)
        let sectionPersonal = [name, address, birth]
        let company = Field(name:"company", title:"Company:", cellType: TextCell.self)
        let position = Field(name:"position", title:"Position:", cellType: TextCell.self)
        let email = Field(name:"email", title:"Email:", cellType: TextCell.self)
        let salary = Field(name:"salary", title:"Salary:", cellType: NumberCell.self)
        let sectionProfessional = [company, position, email, salary]
        let gender = Field(name: "gender", title:"Gender:", cellType: LinkCell.self)
        let sectionGender = [gender]
        return [sectionPersonal, sectionProfessional, sectionGender]
    }
    
    lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped))
    }()
    
    lazy var backButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "\u{25C0}Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backTapped))
    }()
    
    lazy override var selectedRow:((_ form:FormViewController, _ indexPath:IndexPath)->())? = { [weak self] (form,indexPath) in
        let cell = form.tableView.cellForRow(at: indexPath)
        cell?.isSelected = false
        if cell is LinkCell {
            if (cell as! FormCell).name == "gender" {
                self?.navigationController?.pushViewController(self!.genderList, animated: true)
            }
        }
    }
    
    lazy var genderList = { ()-> TableViewController<Gender> in
        let genders:[Gender] = {
            guard let context = context else { return [Gender]()}
            return Gender.getGenders(context:context)
        }()
        
        let genderList = TableViewController(items:genders, cellType: UITableViewCell.self)
        
        genderList.configureCell = { (cell, item, indexPath) in
            let item:Gender = item as Gender
            cell.textLabel?.text = "\(item)"
            if  let gndr = self.data?["gender"] as? Gender {
                if gndr == item {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        }
        
        genderList.viewWillAppear = { (controller) in
            controller.tableView.reloadData()
        }
        
        genderList.selectedRow = { (controller, indexPath) in
            if let cell  = controller.tableView.cellForRow(at: indexPath as IndexPath){
                cell.accessoryType = .checkmark
                controller.selected = indexPath
            }
            let item:Gender = controller.items[indexPath.item]
            self.data!["gender"] = item
            self.setFormData()
            controller.navigationController?.popViewController(animated: true)
        }
        
        genderList.deselectedRow = { (controller, indexPath) in
            if controller.selected != nil {
                if let cell  = controller.tableView.cellForRow(at: controller.selected!){
                    cell.accessoryType = .none
                }
            }
        }
        genderList.title = "Gender"
        return genderList
    }()
    
    override init(){
        super.init()
        let its = createFieldsAndSections()
        self.fields = its
        self.sections = buildCells(items: its)
    }
    
    override init(config:ConfigureForm){
        super.init(config:config)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Employee"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self as UIGestureRecognizerDelegate
    }

    @objc func saveTapped(){
        guard let context = context else { return }
        let dic = self.getFormData()
        let employee = CDEmployee(context:context)
        employee.save(dic) { (employee) in
            // Sync with Cloudkit here...
        }
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @objc func backTapped(){
        self.view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
}

extension EmployeeController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        self.view.endEditing(true)
        return (otherGestureRecognizer is UIScreenEdgePanGestureRecognizer)
    }

}
