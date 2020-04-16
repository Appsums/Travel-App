//
//  NSDictionary+NullReplacement.swift
//  BeeLand Artisan
//
//  Created by LS on 04/02/17.
//  Copyright © 2017 logicspice. All rights reserved.
//

import Foundation

extension NSDictionary{
    
    func dictionaryByReplacingNullsWithBlanks()->NSDictionary {
        let replaced:NSMutableDictionary = self.mutableCopy() as! NSMutableDictionary
    
    let blank = ""
        
        for strKey in self.keyEnumerator() {
            let object:AnyObject = self.object(forKey: strKey) as AnyObject
            
            if object is NSNull
            {
                replaced.setObject(blank, forKey: strKey as! NSCopying)
            }
            else if object is NSDictionary
            {
                replaced.setObject((object as! NSDictionary).dictionaryByReplacingNullsWithBlanks(), forKey: strKey as! NSCopying)
            }
            else if object is NSArray
            {
                replaced.setObject((object as! NSArray).arrayByReplacingNullsWithBlanks(), forKey: strKey as! NSCopying)
            }
        }
        return replaced.copy() as! NSDictionary
    }
    
}
