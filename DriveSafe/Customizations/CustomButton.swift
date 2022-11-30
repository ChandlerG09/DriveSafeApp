//
//  CustomButton.swift
//  DriveSafe
//
//  Created by Chandler Glowicki on 4/11/22.
//

import UIKit
class CustomButton:UIButton{
    var cornerRadius: CGFloat = 2 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
    var borderWidth: CGFloat = 4 {
        didSet{
            self.layer.borderWidth = borderWidth
//            self.layer.borderColor = UIColor.red.cgColor
//            self.layer.backgroundColor = UIColor.orange.cgColor
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup(){
        let image = UIImage(named: "addDrinkBtn.png") as UIImage?
        self.setBackgroundImage(image, for: .normal)
    }
}
