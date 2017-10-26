//
//  FacebookEvent.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 10/25/17.
//  Copyright © 2017 twil. All rights reserved.
//


import Foundation
import ObjectMapper
import CoreLocation

class FacebookEvent: Mappable {
    
    var id: String?
    var end_time: Int?
    var date: Date?
    var name: String?
    var place: String? //place.name
    var start_time: String?
    var description: String?
    var ticket_uri: String?

    required init?(map: Map) {
        
    }
    
    func postProcess() {
        if let date = start_time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
            let dateObj = dateFormatter.date(from: date)
            self.date = dateObj
            print(dateObj)
        }
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        end_time <- map["end_time"]
        place <- map["place.name"]
        start_time <- map["start_time"]
        description <- map["description"]
        ticket_uri <- map["ticket_uri"]
        postProcess()
    }
    
}


