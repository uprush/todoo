//
//  ToDoItem.swift
//  ToDoo
//
//  Created by Jiang, Yifeng on 8/13/14.
//  Copyright (c) 2014 Uprush. All rights reserved.
//

import UIKit

class ToDoItem : NSObject {
    var itemName: String = ""
    var completed: Bool = false
    var creationDate: NSDate = NSDate()
    var id: CFStringRef
    
    init(itemName: String) {
        self.itemName = itemName
        var uuid: CFUUIDRef = CFUUIDCreate(nil)
        id = CFUUIDCreateString(nil, uuid)
    }
}
