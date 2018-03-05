//
//  CoreDataManager.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 22/12/2017.
//  Copyright © 2017 Ivica Petrsoric. All rights reserved.
//

import CoreData

struct CoreDataManager{
    
    // SINGLETON
    // will live forever as long as your application is still alive, it's properties will too
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrainingModel")
        container.loadPersistentStores { (storeDescription, err) in
            if let err = err{
                fatalError("Loading of store failed: \(err)")
            }
        }
        return container
    }()
    
    func fetchCompanies() -> [Company]{
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do{
            let companies = try context.fetch(fetchRequest)
            return companies
        }catch let fetcErr{
            print("Failed to fetch companie:",fetcErr)
            return []
        }
    }
    
    func createEmployee(employeeName: String, employeeType: String, birthday: Date, company: Company) -> (Employee?, Error?){
        let context = persistentContainer.viewContext
        
        // create employee
        let employee = NSEntityDescription.insertNewObject(forEntityName: "Employee", into: context) as! Employee
        employee.setValue(employeeName, forKey: "name")
        
        employee.company = company
        employee.type = employeeType
        
        // lets check company is setup correctly
//        let company = Company(context: context)
//        company.employees // type: NSSet, many employees!!
//        employee.company // type: Company, ONE!!!
        
        // relationships inserts data
        let employeeInformation = NSEntityDescription.insertNewObject(forEntityName: "EmployeeInformation", into: context) as! EmployeeInformation
        
        // safer
        employeeInformation.taxId = "456"
        employeeInformation.birthday = birthday
        // with key
//        employeeInformation.setValue("456", forKey: "taxId")
        
        employee.employeeInformation = employeeInformation
        
        do{
            try context.save()
            return (employee, nil)
        } catch let err{
            print("Failed to create employee",err)
            return (nil, err)
        }
    }
    
}
