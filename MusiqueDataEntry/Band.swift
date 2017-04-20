//
//  Band.swift
//  
//
//  Created by Tara Wilson on 4/20/17.
//
//

import Foundation

class Band: NSObject {
    var name: String?
    var email: String?
    var facebook: String?
    var image: String?
    var genre: String?
    var website: String?
    var youtube: String?
    var region: String?
    var bandDescription: String?
    
    init(name: String) {
        self.name = name
    }
}
