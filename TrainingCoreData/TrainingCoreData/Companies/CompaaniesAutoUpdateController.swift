//
//  CompaaniesAutoUpdateController.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 03/01/2018.
//  Copyright © 2018 Ivica Petrsoric. All rights reserved.
//

import UIKit
import CoreData

class CompaniesAutoUpdateController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    // manipulacija objekata, poredavanje coreData objekata po ključu
    lazy var fetchResultsController: NSFetchedResultsController<Company> = {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        frc.delegate = self
        
        do{
            try frc.performFetch()
        } catch let err{
            print(err)
        }
        
        return frc
    }()
    
////    // save in coreData
////    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////
////    }
////
////    // before save in CoreData
////    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////
////    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        // indexPtu = update, newIndexPath = insert
//
//        if type == .insert{
//            tableView.insertRows(at: [newIndexPath!], with: .middle)
//        } else if type == .delete{
////            tableView.deleteRows(at: [in], with: <#T##UITableViewRowAnimation#>)
//        }
//    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    let cellId = "cellId"
    
    @objc private func handleAdd(){
        print("Let's add a company called Bmw")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let company = Company(context: context)
        company.name = "2"
        
        do{
            try context.save()
        }catch let err{
            print(err)
        }
    }
    
    @objc private func handleDelete(){
        
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        // predicate dopušta brisanje po odrededenom izboru
//        request.predicate = NSPredicate(format: "name CONTAINS %@", "2")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let companieswithB = try? context.fetch(request)
        
        companieswithB?.forEach({ (company) in
            context.delete(company)
        })
        
        try? context.save()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Company Auto Updates"
        
        tableView.backgroundColor = .darkBlue
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(CompanyCell.self, forCellReuseIdentifier: cellId)

//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd)),
            UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))
        ]
        
        fetchResultsController.fetchedObjects?.forEach({ (company) in
            print(company.name ?? "")
        })
        
//        let service = Service()
//        Service.shared.downloadCompaniesFromServer()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = .white
        
        self.refreshControl = refreshControl
    }
    
    @objc func handleRefresh(){
        Service.shared.downloadCompaniesFromServer()
        refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultsController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.text = fetchResultsController.sectionIndexTitles[section]
        label.backgroundColor = .lightBlue
        return label
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyCell
        
        let company = fetchResultsController.object(at: indexPath)
        
        cell.company = company
        
//        cell.textLabel?.text = company.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employeeListController = EmployeesController()
        employeeListController.company = fetchResultsController.object(at: indexPath)
        
        navigationController?.pushViewController(employeeListController, animated: true)
    }
       
}
