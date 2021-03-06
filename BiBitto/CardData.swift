//
//  CardData.swift
//  BiBitto
//
//  Created by admin on 2017/10/24.
//  Copyright © 2017年 aoi.sueki. All rights reserved.
//

import Firebase
import FirebaseDatabase

class CardData: NSObject {
    
    var no: Int
    var text: String
    var author: String?
    var category: String
    var createAt: NSDate
    var updateAt: NSDate
    
    init(valueDictionary: [String: AnyObject]) {
        
        self.no = valueDictionary["no"] as! Int
        self.text = valueDictionary["text"] as! String
        self.author = valueDictionary["author"] as? String
        self.category = valueDictionary["category"] as! String
        // システム項目
        let createAt = valueDictionary["createAt"]!
        if createAt is String , (createAt as! String).count == 25 {
            self.createAt = DateUtils.dateFromString(string:createAt as! String, format: "yyyy-MM-dd HH:mm:ss Z")
        }else{
            self.createAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(createAt as! String)!)
        }
        let updateAt = valueDictionary["updateAt"] as? String
        if updateAt?.count == 25 {
            self.updateAt = DateUtils.dateFromString(string:updateAt!, format: "yyyy-MM-dd HH:mm:ss Z")
        }else{
            self.updateAt = NSDate(timeIntervalSinceReferenceDate: TimeInterval(updateAt!)!)
        }
    }
}

class DateUtils {
    class func dateFromString(string: String, format: String) -> NSDate {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)! as NSDate
    }
    
    class func stringFromDate(date: NSDate, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date as Date)
    }
}

class CardUtils {
    class func cardToDictionary(cardDataArray: Array<CardData>) -> Array<[String:Any]>{
        print("DEBUG_PRINT: CardUtils.cardToDictionary: start")
        
        var outputDataArray = Array<[String:Any]>()
        
        cardDataArray.forEach {
            var outputData = [String : Any]()
            outputData["no"] = $0.no
            outputData["text"] = $0.text
            outputData["createAt"] = DateUtils.stringFromDate(date: $0.createAt, format: "yyyy-MM-dd HH:mm:ss Z")
            outputData["author"] = $0.author ?? ""
            outputData["category"] = $0.category
            outputData["updateAt"] = DateUtils.stringFromDate(date: $0.updateAt, format: "yyyy-MM-dd HH:mm:ss Z")
            outputDataArray.append(outputData)
        }
        print("DEBUG_PRINT: CardUtils.cardToDictionary: end")
        return outputDataArray
    }
}

