//
//  CompanyCell.swift
//  TrainingCoreData
//
//  Created by Ivica Petrsoric on 27/12/2017.
//  Copyright © 2017 Ivica Petrsoric. All rights reserved.
//

import UIKit

class CompanyCell: UITableViewCell{
    
    var company: Company?{
        didSet{
            if let name = company?.name, let founded = company?.founded{
                // MMM dd, yyy
                let dateFormater = DateFormatter()
                dateFormater.dateFormat = "MMM dd, yyy"
    
                let foundedDateString = dateFormater.string(from: founded)
    
    //            let locale = Locale(identifier: "EN")
    //            let dateString = "\(name) - Founded: \(founded.description(with: locale))"
                let dateString = "\(name) - Founded: \(foundedDateString)"
    
                nameFoundedDataLabel.text = dateString
    
            } else {
                nameFoundedDataLabel.text = company?.name
                
                nameFoundedDataLabel.text = "\(company?.name ?? "") \(company?.numEmployee ?? 10))"
                
            }
            
            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
            } else{
                companyImageView.image = #imageLiteral(resourceName: "select_photo_empty")
            }
        }
    }
    
    // you cannot declare another image view using "imageView", it is in tableView
    let companyImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.darkBlue.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let nameFoundedDataLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Name"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .tealColor
        
        addSubview(companyImageView)
        companyImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        companyImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        companyImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        companyImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(nameFoundedDataLabel)
        nameFoundedDataLabel.leftAnchor.constraint(equalTo: companyImageView.rightAnchor, constant: 8).isActive = true
        nameFoundedDataLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        nameFoundedDataLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        nameFoundedDataLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
