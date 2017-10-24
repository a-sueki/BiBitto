//
//  UserData.swift
//  BiBitto
//
//  Created by admin on 2017/10/24.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class UserData: NSObject {
    
    var id: String
    var mail: String
    var cardIds = [String]()
    
    init(snapshot: DataSnapshot, id: String) {
        
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        mail = valueDictionary["mail"] as! String
        cardIds = valueDictionary["cardIds"] as! [String]

    }
}

