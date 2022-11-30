//
//  AboutViewController.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 3/2/22.
//

import UIKit
import CoreData
class AboutViewController: UIViewController{
    
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var dateChoice: UIDatePicker!
    @IBOutlet weak var genderChoice: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        self.view.backgroundColor = BACKGROUND
        
        let detectTouch = UITapGestureRecognizer(target: self, action:
                                                    #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
        
        if person!.weight != 0{
            nameTextField.text = person!.name
            weightTextField.text = "\(person!.weight)"
            nameTextField.isEnabled = false
            weightTextField.isEnabled = false
            genderChoice.isEnabled = false
            dateChoice.isEnabled = false
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        nameTextField.isEnabled = true
        weightTextField.isEnabled = true
        genderChoice.isEnabled = true
        dateChoice.isEnabled = true
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        dismissKeyboard()
        var gender: String
        
        var age: Int
        age = 21
        
        if weightTextField.text != "" && nameTextField.text != "" {
            
            
            if genderChoice.selectedSegmentIndex == 0{
                gender = "Male"
            } else {
                gender = "Female"
            }
    
            person = UserLoc(name: nameTextField.text!, weight: Double("\(weightTextField.text!)")!, gender: gender, age: age)
            
            nameTextField.isEnabled = false
            weightTextField.isEnabled = false
            genderChoice.isEnabled = false
            dateChoice.isEnabled = false
        }
    }

    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}
