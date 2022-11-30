//
//  CustomTabController.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/15/22.
//

import UIKit

let TABCOLOR = UIColor(red: 0.6039, green: 0.8745, blue: 0.8784, alpha: 1.0)

class CustomTabController: UITabBarController{
    
    override func viewDidLoad() {
        
        overrideUserInterfaceStyle = .light
        
        self.tabBar.backgroundColor = TABCOLOR
        self.tabBar.tintColor = UIColor.black
        
        if let items = self.tabBar.items{
            for item in items{
                item.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
                item.setTitleTextAttributes([.foregroundColor: UIColor.orange], for: .normal)
            }
        }
            
        
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
    }
    
}
