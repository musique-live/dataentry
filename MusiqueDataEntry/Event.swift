//
//  EventObject.swift
//  musique
//
//  Created by Tara Wilson on 7/18/16.
//  Copyright © 2016 twil. All rights reserved.
//

import Foundation
import CoreLocation

class EventObject: NSObject {
    var body: String?
    var eventimage: String?
    var eventlink: String?
    var ticketURL: String?
    var price: Int?
    var timestamp: NSDate?
    var title: String?
    var id: String?
    var band: BandObject?
    var venue: VenueObject?
    var distance: Double?
    var coordinates: CLLocationCoordinate2D?
    var updated: Bool?
    var time: String?
    var seatGeekID: Int?
    
    //for entry
    var timeString: String?
    var venueString: String?
    var bandString: String?
    
    init(body: String?, eventimage: String?, eventlink: String?, price: Int?, time: NSDate?, title: String?, id: String?, bandName: String?, venueName: String?) {
        self.body = body
        self.eventimage = eventimage
        self.eventlink = eventlink
        self.price = price
        self.timestamp = time
        self.title = title
        self.id = id
        self.band = BandObject(band: bandName, descriptionString: nil, facebook: nil, image: nil, genre: nil, website: nil, youtube: nil)
        self.venue = VenueObject(address: nil, facebook: nil, venue: venueName, yelp: nil, website: nil)
    }
    
    override init() {
        super.init()
    }
    
}
