//
//  ViewController.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 21/12/2017.
//  Copyright © 2017 Ivica Petrsoric. All rights reserved.
//

import UIKit
import CoreData

class CompaniesController: UITableViewController {
    
    var companies = [Company]()
    
    
//    private func fetchCompanies(){
//        // attempt core date fetch
////        let persistentContainer = NSPersistentContainer(name: "TrainingModel")
////        persistentContainer.loadPersistentStores { (storeDescription, err) in
////            if let err = err{
////                fatalError("Loading of store failed: \(err)")
////            }
////        }
////
////        let context = persistentContainer.viewContext
//        let context = CoreDataManager.shared.persistentContainer.viewContext
//
//        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
//
//        do{
//            let companies = try context.fetch(fetchRequest)
//
//            companies.forEach({ (company) in
//                print(company.name ?? "")
//            })
//
//            self.companies = companies
//            self.tableView.reloadData()
//
//        }catch let fetcErr{
//            print("Failed to fetch companie:",fetcErr)
//        }
//    }
    
    @objc private func doWork() {
        print("Trying to do background work...")
        
        // GCD - Grand Central Dispatch
//        DispatchQueue.global(qos: .background).async {
        
            // ovo je u background thread tako da ne treba GCD background!
            CoreDataManager.shared.persistentContainer.performBackgroundTask({ (backgroundContext) in
                
                (0...5).forEach { (value) in
                    print(value)
                    
                    let company = Company(context: backgroundContext)
                    company.name = String(value)
                }
                
                // ako je velika iteracija save ce crashat, ako koristimo standardni context!
                do{
                    try backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        self.tableView.reloadData()
                    }
                    
                }catch let err{
                    print("Failed to save:",err)
                }
            })
            
            // creating some Company objects on a background thread
            // context assoisiated with main thread, not background!
//            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            // A - create old way
//            NSEntityDescription.insertNewObject(forEntityName: "Company", context: context)
            // B - create new way
//            let company = Company(context: context)

//        }
    }
    
    // tricky update bacground
    @objc private func doUpdates(){
        print("Trying to update comapnieson a background context")
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backgroundContext) in
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            
            do{
                let companies = try backgroundContext.fetch(request)
                
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    company.name = "A: \(company.name ?? "")"
                })
                
                do{
                    try backgroundContext.save()
                    
                    // update UI
                    DispatchQueue.main.async {
                        // reset will forget all of the object you've fetch bewfore, not good for many companys
                        CoreDataManager.shared.persistentContainer.viewContext.reset()
                        
                        // you dojt'w want to refety everyting if you're just simply update one or two companies
                        // new to merge changes on background and main context!
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        self.tableView.reloadData()
                    }
                    
                } catch let err{
                    print("Failed to save on background",err)
                }
                
            }catch let err{
                print("Failed to fetch comapnies on background",err)
            }
        }
    }
    
    // update -> Child context - > main context - > Persistant store (Core data)
    @objc private func doNestedUpdates(){
        print("Performing nested updates")
        
        DispatchQueue.global(qos: .background).async {
            // we'll try to perform our updates
            
            
            // we'll first construct a custom MOC
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            // execute updates on privateContext nopw
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            request.fetchLimit = 1
            
            do {
                let companies = try privateContext.fetch(request)
                
                companies.forEach({ (company) in
                    print(company.name ?? "")
                    company.name = "D: \(company.name ?? "")"
                })
                
                do{
                    try privateContext.save()
                    
                    // after save succeeds
                    DispatchQueue.main.async {
                        do{
                            let context = CoreDataManager.shared.persistentContainer.viewContext
                            
                            // chech if context is changed, then save
                            if context.hasChanges{
                                try context.save()
                            }
                            
                        }catch let finalSaveErr{
                            print("Failed to sve naim context:",finalSaveErr)
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                }catch let saveErr{
                    print("Failed to sa ve on private context:",saveErr)
                }
                
            } catch let fetchErr{
                print("Failed to fetch on private context:",fetchErr)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companies = CoreDataManager.shared.fetchCompanies()
        
//        fetchCompanies()
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset)),
//            UIBarButtonItem(title: "Do work", style: .plain, target: self, action: #selector(doWork)),
//            UIBarButtonItem(title: "Do update", style: .plain, target: self, action: #selector(doUpdates)),
            UIBarButtonItem(title: "Nested update", style: .plain, target: self, action: #selector(doNestedUpdates))
        ]
        
        view.backgroundColor = .white

        navigationItem.title = "Companies"
        
        tableView.backgroundColor = .darkBlue
//        tableView.separatorStyle = .none
        tableView.separatorColor = .white
        tableView.tableFooterView = UIView() // da se ne vide cellovi ispod table view
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "cellId")
        
        setupPlusButtonInNavBar(selector: #selector(handleAddCompany))

//        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleAddCompany))
    }
    
    @objc private func handleReset(){
        print("Attempting to delete all core data objects")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        // A)
//        companies.forEach { (company) in
//            context.delete(company)
//        }
        
        // B) - bolji!
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        
        do{
            try context.execute(batchDeleteRequest)
            
            // upon deletion from core data succeded
            var indexPathsToRemove = [IndexPath]()
            
            for (index, _) in companies.enumerated(){
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            
            companies.removeAll()
            tableView.deleteRows(at: indexPathsToRemove, with: .left)

        }catch let delErr {
            print("failed to delete objects from Core Data:", delErr)
        }
    }
    
    @objc func handleAddCompany(){
        let createCompanyController = CreateCompanyController()
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        
        createCompanyController.delegate = self
        present(navController, animated: true, completion: nil)
    }
    
//    func setupNavigationStyle(){
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barTintColor = .lightRed
//        navigationController?.navigationBar.prefersLargeTitles = true
//
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
//    }
    
}

