//
//  CustomTableViewCell.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/20/22.
//

import Foundation
import UIKit

class CustomTableViewCell: UITableViewCell{
  
    @IBOutlet weak var CellLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func setHistory(data: DrinkList){
        CellLabel.text = "\(data.drinkCount) Drinks"
        timeLabel.text = "\(data.date!.timeOnly)"
    }
    
}
