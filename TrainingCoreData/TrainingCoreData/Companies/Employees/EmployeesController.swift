//
//  EmployeesController.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 27/12/2017.
//  Copyright © 2017 Ivica Petrsoric. All rights reserved.
//

import UIKit
import CoreData

// lets create a UILabel subclass for custom text drawing
class IndentedLabel: UILabel{
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = UIEdgeInsetsInsetRect(rect, insets)
        super.drawText(in: customRect)
    }
}

class EmployeesController: UITableViewController, CreateEmployeeConbtrollerDelegate{
    
    // this is called when dissmisec createEmployee
    func didAddEmployee(employee: Employee) {
//        employees.append(employee)
//        fetchEmployee()
//        tableView.reloadData()
        
        // what is the insertion index path
        guard let section = employeeTypes.index(of: employee.type!) else { return }
        
        // what is my row
        let row = allEmployees[section].count
        let insertionIndexPath = IndexPath(row: row, section: section)
        
        allEmployees[section].append(employee)
        
        tableView.insertRows(at: [insertionIndexPath], with: .middle)
    }
    
    var company: Company?
    
    var employees = [Employee]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = company?.name
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        
//        if section == 0{
//            label.text = EmployeeType.Executive.rawValue
//        } else if section == 1{
//            label.text = EmployeeType.SeniorManagment.rawValue
//        } else if section == 2{
//            label.text = EmployeeType.Staff.rawValue
//        }else{
//            label.text = EmployeeType.Intern.rawValue
//        }
        
        label.text = employeeTypes[section]
        
        label.backgroundColor = UIColor.lightBlue
        label.textColor = UIColor.darkBlue
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    

    var allEmployees = [[Employee]]()
    
    var employeeTypes = [
        EmployeeType.Executive.rawValue,
        EmployeeType.SeniorManagment.rawValue,
        EmployeeType.Staff.rawValue,
        EmployeeType.Intern.rawValue
    ]
    
    private func fetchEmployee(){
        print("Trying to fetch employees.")
        // fetching particulay employees for company
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else { return }
        
        allEmployees = []
        
        // array loop instead of filter
        employeeTypes.forEach { (employeeTypee) in
            
            // somehow construct my allEmployees array
            allEmployees.append(
                companyEmployees.filter {$0.type == employeeTypee}
            )
        }
        
        // let's filter employees for "Executives"
//        let executives = companyEmployees.filter { (employee) -> Bool in
//            return employee.type == EmployeeType.Executive.rawValue
//        }
//
//        let seniorManagment = companyEmployees.filter { $0.type == EmployeeType.SeniorManagment.rawValue }
//
//        allEmployees = [
//            executives,
//            seniorManagment,
//            companyEmployees.filter{ $0.type == EmployeeType.Staff.rawValue }
//        ]
        
        
        // fetching all employees of all companies
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//
//        let request = NSFetchRequest<Employee>(entityName: "Employee")
//
//        do{
//            let employees = try context.fetch(request)
//            self.employees = employees
//
////            employees.forEach{print("Employee name:", $0.name ?? "")}
//
//        } catch let err{
//            print("Failed to fetch employee:",err)
//        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allEmployees.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmployees[section].count
//        if section == 0{
//            return shortNameEmployees.count
//        }else{
//            return longNameEmployees.count
//        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
//        let employee = employees[indexPath.row]
//        let employee = indexPath.section == 0 ? shortNameEmployees[indexPath.row] : longNameEmployees[indexPath.row]
        
        let employee = allEmployees[indexPath.section][indexPath.row]
        cell.textLabel?.text = employee.fullName
        
        if let birthday = employee.employeeInformation?.birthday{
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "MMM dd, yyy"            
            cell.textLabel?.text = "\(employee.fullName ?? "") \(dateFormater.string(from: birthday))"
        }
        
//        if let taxId = employee.employeeInformation?.taxId{
//            cell.textLabel?.text = "\(employee.name ?? "") \(taxId)"
//        }
        
        cell.backgroundColor = UIColor.tealColor
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        return cell
    }
    
    let cellID = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEmployee()
        
        tableView.backgroundColor = UIColor.darkBlue
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        // extension
        setupPlusButtonInNavBar(selector: #selector(handleAdd))
    }
    
    @objc private func handleAdd(){
        print("Add employee")
        
        let createEmployeeController = CreateEmployeeController()
        createEmployeeController.delegate = self
        createEmployeeController.company = company
        
        let navController = UINavigationController(rootViewController: createEmployeeController)
        
        present(navController, animated: true, completion: nil)
    }
    
    
}
