
//
//  VenueObject.swift
//  musique
//
//  Created by Tara Wilson on 7/18/16.
//  Copyright © 2016 twil. All rights reserved.
//

import Foundation
import CoreLocation

class VenueObject: NSObject {
    var address: String?
    var facebook: String?
    var venue: String?
    var website: String?
    var yelp: String?
    var coordinates: CLLocation?
    var email: String?
    var region: String?
    var reservationsNum: Int?
    
    init(address: String?, facebook: String?, venue: String?, yelp: String?, website: String?) {
        self.address = address
        self.facebook = facebook
        self.venue = venue
        self.yelp = yelp
        self.website = website
    }
    
    init(name: String) {
        self.venue = name
    }
    
}

