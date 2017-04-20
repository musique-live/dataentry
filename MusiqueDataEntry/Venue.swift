
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
    var dancing: String?
    var facebook: String?
    var image: String?
    var venue: String?
    var website: String?
    var yelp: String?
    var coordinates: CLLocation?
    
    init(address: String?, dancing: String?, facebook: String?, image: String?, venue: String?, yelp: String?, website: String?) {
        self.address = address
        self.dancing = dancing
        self.facebook = facebook
        self.image = image
        self.venue = venue
        self.yelp = yelp
        self.website = website
    }
    
}

