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
    
    required init?(map: Map) {
        
    }
    
    func postProcess() {
        //doors date to real date
    }
    
    func mapping(map: Map) {
        ticketFlyEventID <- map["id"]
        name <- map["name"]
        headlinersName <- map["headlinersName"]
        supportsName <- map["supportsName"]
        image <- map["image.large.path"]
        doorsDate <- map["doorsDate"]
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
    
    func postProcess() {
        if let description = self.eventDescription {
            if String(description.characters.prefix(7)) == "<iframe" {
                if String(description[50..<57]) == "youtube" {
                    let descriptionSplit = description.components(separatedBy: "https://www.youtube.com/embed/")
                    let youtubeSplit = descriptionSplit[1][0..<10]
                    self.youtube = youtubeSplit
                    print(self.youtube)
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
