  //
//  VenueObject.swift
//  musique
//
//  Created by Tara Wilson on 7/18/16.
//  Copyright © 2016 twil. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper


class VenueObject: NSObject, Mappable {
    var address: String?
    var venue: String?
    var website: String?
    var yelp: String?
    var coordinates: CLLocation?
    var region: String?
    var facebook: String?
    var email: String?
    var reservationsNum: Int?
    
    var tempCoordinates1: Double?
    var tempCoordinates2: Double?
    
    func updateTypes() {
        if let c1 = tempCoordinates1, let c2 = tempCoordinates2 {
            coordinates = CLLocation(latitude: c1, longitude: c2)
        }
        
    }
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        address <- map["venueaddress"]
        website <- map["venuewebsite"]
        yelp <- map["venueyelp"]
        region <- map["venueregion"]
        address <- map["address"]
        website <- map["website"]
        facebook <- map["facebook"]
        facebook <- map["venuefacebook"]
        yelp <- map["yelp"]
        region <- map["region"]
        tempCoordinates1 <- map["coordinates.0"]
        tempCoordinates2 <- map["coordinates.1"]
        
        updateTypes()
    }
    
    
}


