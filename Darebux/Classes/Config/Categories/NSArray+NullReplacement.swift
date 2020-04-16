//
//  NSArray+NullReplacement.swift
//  BeeLand Artisan
//
//  Created by LS on 04/02/17.
//  Copyright © 2017 logicspice. All rights reserved.
//

import Foundation

extension NSArray{
    
    func arrayByReplacingNullsWithBlanks()->NSArray {
        
        let replaced:NSMutableArray = self.mutableCopy() as! NSMutableArray
        let blank = ""
        
        for idx in 0..<replaced.count {
            let object = replaced.object(at: idx)
            if object is NSNull {
                replaced.replaceObject(at: idx, with: blank)
            }
            else if object is NSDictionary{
                replaced.replaceObject(at: idx, with: (object as! NSDictionary).dictionaryByReplacingNullsWithBlanks())
            }
            else if object is NSArray{
                replaced.replaceObject(at: idx, with: (object as! NSArray).arrayByReplacingNullsWithBlanks())
            }
        }
        
        return replaced.copy() as! NSArray
    }

}
