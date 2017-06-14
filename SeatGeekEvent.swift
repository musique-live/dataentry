//
//  SeatGeekEvent.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

class SeatGeekObject: Mappable {
    
    var stringDate: String?
    var URL: String?
    var name: String?
    var venuename: String?
    var imageURL: String?
    var genres = [String]()
    var address: String?
    var latitude: Float?
    var longitude: Float?
    var id: Int?
    var youtube: String?
    var venueExists: Bool?
    var date: Date?
    
    var bandname: String?
    var bandname2: String?
    var image1: String?
    var image2: String?
    var band1genre1: String?
    var band1genre2: String?
    var band1genre3: String?
    var band2genre1: String?
    var band2genre2: String?
    var band2genre3: String?
    var address1: String?
    var address2: String?
    var lowestprice: Float?
    
    func split() -> SeatGeekObject? {
        self.name = bandname
        self.imageURL = image1
        if let genre1 = band1genre1 {
            self.genres.append(genre1)
        }
        if let genre2 = band1genre2 {
            self.genres.append(genre2)
        }
        if let genre3 = band1genre3 {
            self.genres.append(genre3)
        }
        if let add1 = address1, let add2 = address2 {
            self.address = add1 + ", " + add2
        }
        if let stringDate = stringDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dateObj = dateFormatter.date(from: stringDate)
            self.date = dateObj
        }
        if let secondname = bandname2 {
            let newevent = SeatGeekObject(name: secondname)
            newevent.date = self.date
            newevent.id = id
            newevent.lowestprice = self.lowestprice
            newevent.URL = self.URL
            newevent.venuename = self.venuename
            newevent.imageURL = image2
            newevent.date = self.date
            if let genre1 = band2genre1 {
                newevent.genres.append(genre1)
            }
            if let genre2 = band2genre2 {
                newevent.genres.append(genre2)
            }
            if let genre3 = band2genre3 {
                newevent.genres.append(genre3)
            }
            newevent.address = self.address
            newevent.latitude = self.latitude
            newevent.longitude = self.longitude
            return newevent
        } else {
            return nil
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        stringDate <- map["datetime_local"]
        URL <- map["url"]
        id <- map["id"]
        image1 <- map["performers.0.image"]
        image2 <- map["performers.1.image"]
        bandname <- map["performers.0.short_name"]
        bandname2 <- map["performers.1.short_name"]
        band1genre1 <- map["performers.0.genres.0.name"]
        band1genre2 <- map["performers.0.genres.1.name"]
        band1genre3 <- map["performers.0.genres.2.name"]
        band2genre1 <- map["performers.1.genres.0.name"]
        band2genre2 <- map["performers.1.genres.1.name"]
        band2genre3 <- map["performers.1.genres.2.name"]
        lowestprice <- map["stats.lowest_price"]
        venuename <- map["venue.name_v2"]
        latitude <- map["venue.location.lat"]
        longitude <- map["venue.location.lon"]
        address1 <- map["venue.address"]
        address2 <- map["venue.extended_address"]
    }
    
}
