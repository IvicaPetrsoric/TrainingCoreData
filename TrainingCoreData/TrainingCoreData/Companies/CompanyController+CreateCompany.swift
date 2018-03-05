//
//  CompanyController+CreateCompany.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 27/12/2017.
//  Copyright © 2017 Ivica Petrsoric. All rights reserved.
//

import UIKit

extension CompaniesController: CreateComnpanyControllerDelegate{
    
    // specify your extension methos here
    func didEditCompany(company: Company){
        // update my tableView somehow
        let row = companies.index(of: company)
        
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
    }
    
    func didAddCompanty(company: Company) {
        companies.append(company)
        
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
}
