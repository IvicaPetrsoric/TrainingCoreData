//
//  Service.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 03/01/2018.
//  Copyright © 2018 Ivica Petrsoric. All rights reserved.
//

import Foundation
import CoreData

struct Service{
    
    static let shared = Service()
    
    let urlString = "https://api.letsbuildthatapp.com/intermediate_training/companies"
    
    func downloadCompaniesFromServer(){
        print("Attempting to download companies")
        
        guard let url = URL(string: urlString) else { return }
        
        // background thread, te zbog toga i core data mroa biti na background
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            
            if let err = err{
                print("Failed to DL:",err)
                return
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do{
                let jsonCompanies = try jsonDecoder.decode([JSONCompany].self, from: data)
                
                
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                
                // companies
                jsonCompanies.forEach({ (jsonCompany) in
                    print(jsonCompany.name)
                    
                    let company = Company(context: privateContext)
                    company.name = jsonCompany.name
                    
                    let dateFormater = DateFormatter()
                    dateFormater.dateFormat = "MM/dd/yyyy"
                    let foundedDate = dateFormater.date(from: jsonCompany.founded)
                    
                    company.founded = foundedDate
                    
                    // employees
                    jsonCompany.employees?.forEach({ (jsonEmployee) in
                        print("  \(jsonEmployee.name)")
                        
                        let employee = Employee(context: privateContext)
                        employee.fullName = jsonEmployee.name
                        employee.type = jsonEmployee.type
                        
                        let employeeInformation = EmployeeInformation(context: privateContext)
                        
                        let birthdayDate = dateFormater.date(from: jsonEmployee.birthday)
                        
                        employeeInformation.birthday = birthdayDate
                        
                        employee.employeeInformation = employeeInformation
                        
                        employee.company = company
                    })
                    
                    do{
                        try privateContext.save()
                        try privateContext.parent?.save()
                        
                        
                    }catch let saveErr{
                        print("Failed to save comapnies,",saveErr)
                    }
                })
                
            } catch let err{
                print("Failed to decode:",err)
            }
            
            //            let string = String(data: data, encoding: .utf8)
            
            //            print(string)
            
            }.resume()
    }
}

struct JSONCompany: Decodable{
    
    let name: String
    let founded: String
    var employees: [JSOnEmployee]?
    
}

struct JSOnEmployee: Decodable{
    
    let name: String
    let type: String
    let birthday: String
    
}


