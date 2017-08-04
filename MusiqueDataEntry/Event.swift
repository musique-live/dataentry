//
//  EventObject.swift
//  musique
//
//  Created by Tara Wilson on 7/18/16.
//  Copyright © 2016 twil. All rights reserved.
//

import Foundation
import CoreLocation
import ObjectMapper

let youtubeopenstring = "https://www.youtube.com/watch?v="

class EventObject: NSObject, Mappable {
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    var price: Int?
    var timestamp: NSDate?
    var id: String?
    var band: BandObject?
    var venue: VenueObject?
    var distance: Double?
    var coordinates: CLLocationCoordinate2D?
    var time: String?
    var ticketURL: String?
    var ticketflyID: Int?
    var currentReserved: Int?
    var reserved: String?
    var eventLink: String?
    var seatGeekID: Int?
    
    var tempdateString: String?
    var tempCoordinates1: Double?
    var tempCoordinates2: Double?

    
    func updateTypes() {
        if let date = tempdateString {
            self.timestamp = NSDate(jsonDate: date)
        }
        if let c1 = tempCoordinates1, let c2 = tempCoordinates2 {
            coordinates = CLLocationCoordinate2D(latitude: c1, longitude: c2)
        }
        if let url = ticketURL {
            if !(url.contains("aid")) {
                ticketURL = url + "?aid=12689"
            }
        }
        
    }
    
    func mapping(map: Map) {
        time <- map["timeString"]
        price <- map["eventprice"]
        tempdateString <- map["date"]
        id <- map["id"]
        currentReserved <- map["currentReserved"]
        ticketURL <- map["ticketURL"]
        ticketflyID <- map["ticketflyID"]
        reserved <- map["reserved"]
        tempCoordinates1 <- map["coordinates.0"]
        tempCoordinates2 <- map["coordinates.1"]
        
        updateTypes()
    }
    
    func createWithTicketFly(ticketfly: TicketFlyEvent, completion: @escaping((EventObject) -> Void)) {
        
        if let date = ticketfly.eventDate {
            let newEvent = EventObject()
            newEvent.timestamp = date as NSDate
            
            if let link = ticketfly.urlEventDetailsUrl {
                newEvent.eventLink = link
            }
            if let ticket = ticketfly.ticketPurchaseUrl {
                newEvent.ticketURL = ticket
            }
            if let pr = ticketfly.ticketPrice {
                let betterString = pr.replacingOccurrences(of: "$", with: "")
                newEvent.price = Int(betterString)
            }
            if let tm = ticketfly.timeString {
                newEvent.time = tm
                newEvent.time = tm
            }
            if let band = ticketfly.headliners?.first {
                if let bandname = band.name {
                    let newBand = BandObject()
                    newBand.band = bandname
                    if let tfid = band.ticketFlyBandID {
                        newBand.ticketFlyID = tfid
                    }
                    if let descrip = band.eventDescription {
                        newBand.bandDescription = descrip
                    }
                    if let web = band.urlOfficialWebsite {
                        newBand.website = web
                    }
                    if let fb = band.urlFacebook {
                        newBand.facebook = fb
                    }
                    if let ig = band.urlInstagram {
                        newBand.instagram = ig
                    }
                    if let imag = band.image {
                        newBand.image = imag
                    }
                    if let yt = band.youtube {
                        newBand.youtube = yt
                    }
                    newEvent.band = newBand
                }
            }
            if let image = ticketfly.image {
                if newEvent.band?.image == nil {
                    newEvent.band?.image = image
                }
            }
            if let venue = ticketfly.venue {
                NetworkController().getVenueForString(venue: venue, completion: {
                    venueobj in
                    newEvent.venue = venueobj
                    completion(newEvent)
                })
            }
        }
    }
    



    
    func createSendDict(newEventID: String) -> [String: Any] {
        var newData = [
            "id": newEventID,
            "bandname": self.band?.band,
            "date": String(self.timestamp!.timeIntervalSince1970),
            "timeString": self.time ?? "",
            "updated": "true",
            "venuename": self.venue?.venue,
            ]
            as [String : Any]
        if let ticket = self.ticketURL {
            newData["ticketURL"] = ticket
        }
        if let tfid = self.ticketflyID {
            newData["eventticketflyID"] = tfid
        }
        if let price = self.price {
            newData["eventprice"] = price
        } else {
            newData["eventprice"] = "Unknown"
        }
        if let el = self.eventLink {
            newData["eventlink"] = el
        }
        
        
        
        if let region = self.venue?.region {
            newData["venueregion"] = region
        }
        if let address = self.venue?.address {
            newData["venueaddress"] = address
        }
        if let site = self.venue?.website {
            newData["venuewebsite"] = site
        }
        if let yelp = self.venue?.yelp {
            newData["venueyelp"] = yelp
        }
        if let location = self.venue?.coordinates {
            newData["coordinates"] =
                [location.coordinate.latitude,
                 location.coordinate.longitude]
        }
        
        
        
        if let genre = self.band?.genre {
            newData["bandgenre"] = genre
        }
        if let image = self.band?.image {
            newData["bandimage"] = image
        }
        if let fb = self.band?.facebook {
            newData["bandfacebook"] = fb
        }
        if let bandsite = self.band?.website {
            newData["bandwebsite"] = bandsite
        }
        if let yt = self.band?.youtube {
            if yt.characters.count < 15 {
                newData["bandyoutube"] = youtubeopenstring + yt
            } else {
                newData["bandyoutube"] = yt
            }
        }
        if let descript = self.band?.bandDescription {
            newData["banddescription"] = descript
        }

        
        return newData
    }
    
}

