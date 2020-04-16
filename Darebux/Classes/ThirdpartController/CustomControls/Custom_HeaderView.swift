//
//  Custom_HeaderView.swift
//  FoodOrderApp
//
//  Created by LogicSpice on 25/12/17.
//  Copyright © 2017 logicspice. All rights reserved.
//

import UIKit

class Custom_HeaderView: UIView {

    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       self.backgroundColor = UIColor.init(red: 235/255.0, green: 69/255.0, blue: 32/255.0, alpha: 1)
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 235/255.0, green: 69/255.0, blue: 32/255.0, alpha: 1)
    }
}
