//
//  ViewController.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 3/2/22.
//

import UIKit
import HealthKit

var person: UserLoc?

let YELLOW = UIColor(red: 1, green: 0.8235, blue: 0.1294, alpha: 1.0)
let BACKGROUND = UIColor(red: 0.4275, green: 0.8706, blue: 0.8784, alpha: 1.0)

class ViewController: UIViewController {
    
    
    
    
    //Instance Variables
    var constant: Double = 0.68
    var bac: Double = 0.0 {
        didSet{
            bacText.text = "Your B.A.C is: \(bac.roundTo(places: 2))"
        }
    }
    var maxBac: Double = 0.0
    var numDrinks: Double = 0.0 {
        didSet{
            numDrinksText.text =  "Number of Drinks: \(numDrinks)"
        }
    }
    var adjustedWeight: Double = 0.0
    var start: Double = 0.0
    var end: Double = 0.0
    var showMessage: Bool = true
    var drinks: [DrinkList] = []
    var delegate: HistoryViewControllerDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Temp vars for saving User info
    var name: String = ""
    var weight: Double = 0.0
    var gender: String = ""
    let healthStore = HKHealthStore()
    let healthTypes = Set([HKQuantityType(.numberOfAlcoholicBeverages)])
    
    
    //Outlets
    
    //buttons
    @IBOutlet weak var resetBtnOutlete: UIButton!
    @IBOutlet weak var addDrinkOutlet: UIButton!
    //segmented control
    @IBOutlet weak var alcLevelOutlet: UISegmentedControl!
    @IBOutlet weak var alcLevel: UISegmentedControl!
    //text
    @IBOutlet weak var alcContentText: UILabel!
    @IBOutlet weak var drinkInfoText: UILabel!
    @IBOutlet weak var numDrinksText: UILabel!
    @IBOutlet weak var bacText: UILabel!
    
    
    
    //Set Up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        checkHealthAvailability()
        loadData()
        print("Loaded")
        refreshBAC()
        setTextColor()
        
        //Starts a timer to update the BAC level every minute
        let _ = Timer.scheduledTimer(timeInterval: 60, target: self,
        selector: #selector(refreshBAC), userInfo: nil, repeats: true)
    }
    
    //App is being closed
    override func viewWillDisappear(_ animated: Bool) {
        saveData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "historySegue"{
            if let dest = segue.destination as? HistoryViewController{
                dest.histDelegate = self
                dest.histDrinks = drinks
            }
        }
    }
    
    func updateArray(data: DrinkList, amt: Double){
        
        //Check if any of them are from the same date and time to the minute
        for entry in drinks{
            //Same time exists
            if entry.date!.timeFormat == data.date!.timeFormat{
                
                //add drink amount to the current entry
                entry.addDrink(amt: amt)
                //delete the new drink object that was created
                //since we are just updating an existing drink
                self.context.delete(data)
                //Save the drink
                saveDrinks()
                return
            }
        }
        //Same date and time does not exist
        //Create a new entry
        drinks.append(data)
        saveDrinks()
        return
    }
    
    //Check if User data exists and if not prompt user
    //To fill out information
    func userExists()->Bool{
        if person?.weight == 0{
            
            // create the alert
            let alert = UIAlertController(title: "Welcome!", message: "You need to enter some information about yourself before we can estimate your B.A.C and track your alcohol intake", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "Take me there!", style: UIAlertAction.Style.default, handler: { action in
                self.tabBarController?.selectedIndex = 1
            }))
            
            // show the alert
            if showMessage{
                self.present(alert, animated: true, completion: nil)
            }
            return  false
        }
        return true
    }
    
    //Set Color of the text
    func setTextColor(){
        bacText.textColor = UIColor.black
        numDrinksText.textColor = UIColor.black
        alcContentText.textColor = UIColor.black
        drinkInfoText.textColor = UIColor.black
        addDrinkOutlet.setTitleColor(UIColor.black, for: .selected)
    }
    
    //Change Background Color based on BAC
    func updateBackgroundColor(){
        if bac.roundTo(places: 2) >= 0.08 {
            UIView.animate(withDuration: 0.5){
                self.view.backgroundColor = UIColor.red
            }
        }
        if (bac.roundTo(places: 2)) >= 0.04 && bac.roundTo(places: 2)<0.08{
            UIView.animate(withDuration: 0.5){
                self.view.backgroundColor = YELLOW
            }
        }
        if (bac.roundTo(places: 2)) < 0.04 && bac.roundTo(places: 2) != 0{
            UIView.animate(withDuration: 0.5){
                self.view.backgroundColor = UIColor.green
            }
        }
        if bac == 0{
            UIView.animate(withDuration: 0.5){
                self.view.backgroundColor = BACKGROUND
            }
        }
    }
    
    //Update the Users BAC Level
    @objc func refreshBAC(){
        end = Double(DispatchTime.now().uptimeNanoseconds)
        let elapsedTime = end - start
        let convertedTime = Double(elapsedTime) / 1000000000
        let hours = convertedTime / 60 / 60
        let bacSubtract = hours * 0.015
        bac = maxBac - (bacSubtract)
        if(bac < 0){
            bac = 0
        }
        updateBackgroundColor()
    }
    
    //Request user health Access
    func checkHealthAvailability(){
        
        if HKHealthStore.isHealthDataAvailable(){
            healthStore.requestAuthorization(toShare: healthTypes, read: healthTypes) { (success, error) in
                if !success {
                    //Error
                }
            }
        }
    }
    
    //Refresh Button Clicked
    @IBAction func refreshButton(_ sender: UIButton) {
        refreshBAC()
        
        if bac.roundTo(places: 2) < 0.08{
            showMessage = true
        }
        
        if bac.roundTo(places: 2) == 0{
            resetDrinks()
        }
        saveData()
    }
    
    //Reset Button Clicked
    @IBAction func resetButton(_ sender: UIButton) {
        resetDrinks()
        saveData()
    }
    
    //Resets the drinks
    func resetDrinks(){
        bac = 0
        numDrinks = 0
        start = 0.0
        end = 0.0
        maxBac = 0.0
        showMessage = true
        updateBackgroundColor()
    }
    
    //Adds a drink to the users count
    @IBAction func addButton(_ sender: UIButton) {
        if userExists(){
            //refresh before calculating for most accurate BAC level
          //  loadData()
            refreshBAC()
            calcBac()
            saveData()
            updateBackgroundColor()
            
            //Legal Driving Limit has been reached
            //Display alert
            if bac.roundTo(places: 2) >= 0.08 {
                // create the alert
                let alert = UIAlertController(title: "Warning!", message: "Your current BAC Level is estimated to be \(bac.roundTo(places: 2)). This is above the legal limit of 0.08. DO NOT DRIVE HOME until the refreshed BAC falls below 0.08.", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Don't Show Again.", style: UIAlertAction.Style.default, handler: { action in
                    self.showMessage = false
                }))
                
                // show the alert
                if showMessage{
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //Adds the drink to the health app
    func addToHealth(shots: Double){
        
        //Make sure the healthData is available
        if HKHealthStore.isHealthDataAvailable(){
            
            //Create a variable that holds the type of data we tracking
            let alcoholConsumptionType = HKQuantityType(.numberOfAlcoholicBeverages)
            
            //The number of drinks that we want to add to the Health App
            let drinkCount = HKQuantity(unit:HKUnit.count(), doubleValue: shots)
            
            //Create Data variable for a timestamp
            let date = Date()
            
            //Create the sample which can be saved to the health app
            let drinkSample = HKQuantitySample(type: alcoholConsumptionType,
                                               quantity: drinkCount,
                                               start: date, end: date)
            
            //Save the sample and check if it fails or not
            healthStore.save(drinkSample) {(success, error) in
                if success {
                    //Do Nothing, It was saved
                } else{
                    if let error = error {
                        print("\(error)")
                    }
                }
            }
        }
    }
    
    //Calculate the Users BAC level
    func calcBac(){
        
        //Create temp variable to identify the number of shots to add
        var numShots = 1.0
        
        //Make sure the User has inputted their information
        if (person != nil && person!.weight != 0.0){
            
            //Get the start time of this drink to account for time in the formula
            start = Double(DispatchTime.now().uptimeNanoseconds)
            
            //Adjust the users weight to grams for the formula
            adjustedWeight = person!.weight * 453.592
            
            //Female gender constant (for the formula)
            if person!.gender == "Female"{
                constant = 0.55
            }
            
            //Half a shot
            if (alcLevel.selectedSegmentIndex == 0){
                numShots = 0.5
                numDrinks += 0.5
            }
            
            //1 Shot
            else if (alcLevel.selectedSegmentIndex == 1){
                numShots = 1
                numDrinks += 1
            }
            
            //2 Shots
            else{
                numShots = 2
                numDrinks += 2
            }
            
            //Calculate the BAC
            bac += (( (numShots*14) / (adjustedWeight)*constant)*100)
            
            //If BAC is highest its been this session increase so updating BAC works correctly
            if (bac > maxBac){
                maxBac = bac
            }
            
            //Add the numShots to health
            addToHealth(shots: numShots)
            
            //Create a new drink to add to the drinks array
            let newDrink = DrinkList(context: self.context)
            newDrink.drinkCount = numShots
            newDrink.date = Date.now
            
            updateArray(data: newDrink, amt: numShots)
        }
        
        //User did not enter information
        else{
            return
        }
    }
    
    func saveDrinks(){
        do{
            try context.save()
        }
        catch{
            //Error Saving
        }
    }
    
    //Save data so it persists after app close
    func saveData(){
        
        let defaults = UserDefaults.standard
        if person != nil{
            name = person!.name
            weight = person!.weight
            gender = person!.gender
            //
            defaults.set(start, forKey: "StartKey")
            defaults.set(bac, forKey: "bacKey")
            defaults.set(maxBac, forKey: "maxBac")
            defaults.set(numDrinks, forKey: "drinksKey")

            defaults.set(name, forKey: "UserName")
            defaults.set(weight, forKey: "UserWeight")
            defaults.set(gender, forKey: "UserGender")
        }
    }
    
    //Load the data back into the app
    func loadData(){
        do{
            try drinks = context.fetch(DrinkList.fetchRequest())
        }
        catch{
            //error loading data or no data exists
            drinks = []
            saveDrinks()
        }
        
        //Load drink information
        let defaults = UserDefaults.standard
        start = defaults.object(forKey: "StartKey") as? Double ?? 0.0
        bac = defaults.object(forKey: "bacKey") as? Double ?? 0
        maxBac = defaults.object(forKey: "maxBac") as? Double ?? 0
        numDrinks = defaults.object(forKey: "drinksKey") as? Double ?? 0

        //Load User data
        name = defaults.object(forKey: "UserName") as? String ?? ""
        weight = defaults.object(forKey: "UserWeight") as? Double ?? 0.0
        gender = defaults.object(forKey: "UserGender") as? String ?? ""
        person = UserLoc(name: name, weight: weight, gender: gender, age: -1)
    }
}

extension Double {
    
    /// Rounds the double to decimal places value
    
    func roundTo(places:Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        
        return (self * divisor).rounded() / divisor
        
    }
    
}

extension ViewController: HistoryViewControllerDelegate{
    
    func sendData(data: [DrinkList]) {
        drinks = data
    }
}
