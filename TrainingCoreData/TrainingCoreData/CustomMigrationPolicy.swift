//
//  CustomMigrationPolicy.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 03/01/2018.
//  Copyright © 2018 Ivica Petrsoric. All rights reserved.
//

import CoreData

class CustomMigrationPolicy: NSEntityMigrationPolicy{
    
    //1st time it needs to convert int to String this will be called, after that no CoreData is on new V
    @objc func transformNumEmployees(forNum: NSNumber) -> String{
        if forNum.intValue < 150{
            return "small"
        } else {
            return "very large"
        }
    }
    
}
