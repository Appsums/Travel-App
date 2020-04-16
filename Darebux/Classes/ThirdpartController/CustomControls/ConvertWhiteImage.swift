//
//  ConvertWhiteImage.swift
//  FoodOrderApp
//
//  Created by LogicSpice on 25/10/17.
//  Copyright © 2017 logicspice. All rights reserved.
//

import UIKit

class ConvertWhiteImage: UIImageView {
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.changeWhiteImageColor()
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        
        self.changeWhiteImageColor()
    }
    
    override convenience init(image: UIImage?) {
        self.init(image: image)
        
        self.changeWhiteImageColor()
    }
    
}
