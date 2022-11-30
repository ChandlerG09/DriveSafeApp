//
//  HistoryViewController.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/20/22.
//

import UIKit

protocol HistoryViewControllerDelegate{
    func sendData(data: [DrinkList])
}

class HistoryViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var histDrinks: [DrinkList] = []
    var sections: [Section] =  []
    var histDelegate: HistoryViewControllerDelegate!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        tableView.delegate = self
        tableView.dataSource = self
        createSections()
    }
    
    func loadData(){
        
        do{
            try histDrinks = context.fetch(DrinkList.fetchRequest())
        }
        catch{
            //Error Loading Data
        }
    }
    
    func sortSections(){
        //Sort by Date of the drink
        sections = sections.sorted(by: ({$0.date >= $1.date }) )
        //Sort by time of the drink
        for section in sections{
            section.drinks = section.drinks.sorted(by: ({$0.date! >= $1.date!}))
        }
    }
    func createSections(){
        
        //Reset sections to recreate with updated data
        sections = []
        
        for  drink in histDrinks{
            var added = false
            for section in sections{
                if drink.getDate().short == section.date{
                    section.drinks.append(drink)
                    added = true
                    break
                }
            }
            if !added{
                sections.append(Section(date: drink.date!.short, drinks: [drink]) )
            }
        }
        sortSections()
    }
}

//MARK: EXTENSIONS
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let drink = sections[indexPath.section].drinks[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell")  as! CustomTableViewCell
        
        cell.setHistory(data: drink)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].drinks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].date
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in

            //What Drink to remove
            let drinkToRemove = self.sections[indexPath.section].drinks[indexPath.row]

            //Remove the drink
            self.context.delete(drinkToRemove)

            //save the Drink
            do{
                try self.context.save()
            }
            catch{
                //Error Saving
            }

            //Re-get the drinks
            self.loadData()
                //Update the Table
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            //Put the loaded data into sections
            self.createSections()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //get the drink of the selected row
        let drink = self.sections[indexPath.section].drinks[indexPath.row]
        
        //Create the edit swipe action
        let action = UIContextualAction(style: .normal, title: "Edit") { (action, view, completionHandler) in
            
            //Create the alert to display when the edit action is selected
            let alert = UIAlertController(title: "Edit", message: "Edit number of drinks:", preferredStyle: .alert)
            
            //Add a textfield to the action
            alert.addTextField()
            
            //Get a reference to the textfield
            let textfield = alert.textFields![0]
            
            textfield.keyboardType = .decimalPad
            
            //Set the text of the textfield to the current drink number of the row
            textfield.text = "\(drink.drinkCount)"
            
            //create a save button for the alert
            let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
                
                //Update the drink Count based on user input
                drink.drinkCount = Double(textfield.text!)!
                
                //Save the new drink count value to memory
                do{
                    try self.context.save()
                }
                catch{
                    //error saving
                }
                
                //Refresh the data
                    self.loadData()
                    //Reload the table with the loaded data
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                
                self.createSections()
            }
            
            //Cancel Button for alert
            let cancelButton = UIAlertAction(title: "Cancel", style: .default) { (action) in
                //Do Nothing, User pressed Cancel
                
                //refresh so the edit swipe goes away
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            //Add the actions to the alert
            alert.addAction(cancelButton)
            alert.addAction(saveButton)
            //Show the alert
            self.present(alert, animated: true, completion: nil)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //TODO: ADD WAY TO VIEW SPECIFIC TIMES A DRINK WAS TAKEN
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //User selects a row
    }
}

extension Date {
    struct Formatter {
        static let iso8601: DateFormatter = {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxx"
            return formatter
        }()
        
        static let short: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM-dd-YYYY"
            return formatter
        }()
        
        static let section: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM-dd-yyyy"
            return formatter
        }()
        
        static let timeFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM-dd-yyyy'T'HH:mm"
            return formatter
        }()
        
        static let timeOnly: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            return formatter
        }()
    }
    
    var short: String {
        return Formatter.short.string(from: self)
    }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
    
    var section: String {
        return Formatter.section.string(from: self)
    }
    
    var timeFormat: String{
        return Formatter.timeFormat.string(from: self)
    }
    
    var timeOnly: String{
        return Formatter.timeOnly.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Date.Formatter.iso8601.date(from: self)
    }
}
