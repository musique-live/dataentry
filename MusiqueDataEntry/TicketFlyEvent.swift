//
//  TicketFlyEvent.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/3/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class TicketFlyEvent: Mappable {

    var ticketFlyEventID: Int?
    var name: String?
    var headlinersName: String?
    var supportsName: String?
    var image: String? //image.large.path
    var doorsDate: String?
    var ticketPurchaseUrl: String?
    var ticketPrice: String?
    var urlEventDetailsUrl: String?
    var headliners: [TicketFlyBand]?
    var supports: [TicketFlyBand]?
    var eventDate: Date?
    var timeString: String?
    var venue: String?
    var startDate: String?
    
    required init?(map: Map) {
        
    }
    
    func postProcess() {
        if let doorsDate = doorsDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateObj = dateFormatter.date(from: doorsDate)
            self.eventDate = dateObj
            
            if let startingDate = self.eventDate {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: startingDate as Date) + 4
                let minutes = calendar.component(.minute, from: startingDate as Date)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm"
                self.timeString = timeFormatter.string(from: startingDate)
                
                let secondspast = 0 - ((60*60*hour) + (60*minutes))
                let newdate = (startingDate).addingTimeInterval(TimeInterval(secondspast))
                self.eventDate = newdate
            }
        } else if let doorsDate = startDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateObj = dateFormatter.date(from: doorsDate)
            self.eventDate = dateObj
            
            if let startingDate = self.eventDate {
                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: startingDate as Date) + 4
                let minutes = calendar.component(.minute, from: startingDate as Date)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm"
                self.timeString = timeFormatter.string(from: startingDate)
                
                let secondspast = 0 - ((60*60*hour) + (60*minutes))
                let newdate = (startingDate).addingTimeInterval(TimeInterval(secondspast))
                self.eventDate = newdate
            }
        }
    }
    
    func mapping(map: Map) {
        ticketFlyEventID <- map["id"]
        name <- map["name"]
        headlinersName <- map["headlinersName"]
        supportsName <- map["supportsName"]
        image <- map["image.large.path"]
        doorsDate <- map["doorsDate"]
        startDate <- map["startDate"]
        ticketPurchaseUrl <- map["ticketPurchaseUrl"]
        ticketPrice <- map["ticketPrice"]
        urlEventDetailsUrl <- map["urlEventDetailsUrl"]
        headliners <- map["headliners"]
        supports <- map["supports"]
        postProcess()
    }
    
}

class TicketFlyBand: Mappable {
    
    var ticketFlyBandID: Int?
    var eventDescription: String?
    var urlOfficialWebsite: String?
    var urlFacebook: String?
    var urlInstagram: String?
    var image: String?
    var youtube: String?
    var name: String?
    
    func postProcess() {
        if let description = self.eventDescription {
            if String(description.characters.prefix(7)) == "<iframe" {
                if String(description[50..<57]) == "youtube" {
                    let descriptionSplit = description.components(separatedBy: "https://www.youtube.com/embed/")
                    let youtubeSplit = descriptionSplit[1][0..<11]
                    self.youtube = youtubeSplit
                }
            }
            let descriptWithoutEmbed = description.components(separatedBy: "iframe>")
            if descriptWithoutEmbed.count > 1 {
                self.eventDescription = descriptWithoutEmbed[1]
            }
        }
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        ticketFlyBandID <- map["id"]
        eventDescription <- map["eventDescription"]
        urlOfficialWebsite <- map["urlOfficialWebsite"]
        urlFacebook <- map["urlFacebook"]
        name <- map["name"]
        urlInstagram <- map["urlInstagram"]
        image <- map["image.large.path"]
        postProcess()
    }
}

extension String {
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[Range(start ..< end)]
    }
}
