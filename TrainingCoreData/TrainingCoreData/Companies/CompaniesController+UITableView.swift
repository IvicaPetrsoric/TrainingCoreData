//
//  CompaniesController+UITableView.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 27/12/2017.
//  Copyright © 2017 Ivica Petrsoric. All rights reserved.
//

import UIKit

extension CompaniesController{
    
    // click on rows
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let company = self.companies[indexPath.row]
        
        let employeesController = EmployeesController()
        employeesController.company = company
        
        navigationController?.pushViewController(employeesController, animated: true)
    }
    
    // akcije na tableView
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let company = self.companies[indexPath.row]
            print("Attempting to delete company:", company.name ?? "")
            
            // remove the company from out tableView
            self.companies.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // delete the company from CoreData
            let context = CoreDataManager.shared.persistentContainer.viewContext
            
            context.delete(company)
            
            do{
                try context.save()
            }catch let delErr{
                print("Failed to delete company:", delErr)
            }
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: editHandlerFunction)
        
        //        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, indexPath) in
        //            print("Editing company...")
        //        }
        
        deleteAction.backgroundColor = .lightRed
        editAction.backgroundColor = .darkBlue
        
        return [deleteAction, editAction]
    }
    
    private func editHandlerFunction(action: UITableViewRowAction, indexPath: IndexPath){
        print("Editing company in separate function")
        
        let editCompanyController = CreateCompanyController()
        editCompanyController.delegate = self
        editCompanyController.company = companies[indexPath.row]
        let navController = CustomNavigationController(rootViewController: editCompanyController)
        present(navController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightBlue
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! CompanyCell
        
        let company = companies[indexPath.row]
        cell.company = company
        
        //        if let name = company.name, let founded = company.founded{
        //
        //            // MMM dd, yyy
        //            let dateFormater = DateFormatter()
        //            dateFormater.dateFormat = "MMM dd, yyy"
        //
        //            let foundedDateString = dateFormater.string(from: founded)
        //
        ////            let locale = Locale(identifier: "EN")
        ////            let dateString = "\(name) - Founded: \(founded.description(with: locale))"
        //            let dateString = "\(name) - Founded: \(foundedDateString)"
        //
        //            cell.textLabel?.text = dateString
        //
        //        } else {
        //            cell.textLabel?.text = company.name
        //        }
        //
        //        cell.textLabel?.textColor = .white
        //        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        //        if let imageData = company.imageData {
        //            cell.imageView?.image = UIImage(data: imageData)
        //        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: Footer
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No companies availabel..."
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return companies.count == 0 ? 150 : 0
    }
}
