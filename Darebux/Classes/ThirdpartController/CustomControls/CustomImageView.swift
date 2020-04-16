//
//  CustomImageView.swift
//  TaxiApp
//
//  Created by LogicSpice on 05/09/17.
//  Copyright © 2017 LogicSpice. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     self.changeImageColor()
     }
    */
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.changeImageColor()
    }
    
    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        
        self.changeImageColor()
    }
    
    override convenience init(image: UIImage?) {
        self.init(image: image)
        
        self.changeImageColor()
    }

}
