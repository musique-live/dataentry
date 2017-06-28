//
//  NetworkController+Send.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

extension NetworkController {

    func sendBandData(band: BandObject, completion: @escaping (Bool) -> Void) {
        guard let newband = band.name else { return }
        let bandname = cleanFBString(string: newband)
        if let youtube = band.youtube {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/youtube").setValue(youtube)
        }
        if let region = band.region {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/region").setValue(region)
        }
        if let descriptionString = band.bandDescription {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/descriptionString").setValue(descriptionString)
        }
        if let facebook = band.facebook {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/facebook").setValue(facebook)
        }
        if let image = band.image {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/image").setValue(image)
        }
        if let genre = band.genre {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/genre").setValue(genre)
        }
        if let website = band.website {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/website").setValue(website)
        }
        if let email = band.email {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/email").setValue(email)
        }
        completion(true)
    }
    
    func updateBandData(band: BandObject, completion: @escaping (Bool) -> Void) {
        sendBandData(band: band, completion: {
            success in
            
            self.getAllBandEvents(band: band, completion: {
                eventIDS in
                
                let cleanband = self.cleanFBString(string: band.name!)
                
                for event in eventIDS {
                    if let image = band.image {
                        FIRDatabase.database().reference().child("DC/Bands/\(cleanband)/Events/\(event)/bandimage").setValue(image)
                        FIRDatabase.database().reference().child("DC/Events/\(event)/bandimage").setValue(image)
                    }
                    if let genre = band.genre {
                        FIRDatabase.database().reference().child("DC/Bands/\(cleanband)/Events/\(event)/bandgenre").setValue(genre)
                        FIRDatabase.database().reference().child("DC/Events/\(event)/bandgenre").setValue(genre)
                    }
                    if let des = band.bandDescription {
                        FIRDatabase.database().reference().child("DC/Bands/\(cleanband)/Events/\(event)/banddescription").setValue(des)
                        FIRDatabase.database().reference().child("DC/Events/\(event)/banddescription").setValue(des)
                    }
                    if let yt = band.youtube {
                        FIRDatabase.database().reference().child("DC/Bands/\(cleanband)/Events/\(event)/bandyoutube").setValue(yt)
                        FIRDatabase.database().reference().child("DC/Events/\(event)/bandyoutube").setValue(yt)
                    }
                    
                }
                completion(true)
                
            })
            
            
        })
    }

    func getAllBandEvents(band: BandObject, completion: @escaping ([String]) -> Void) {
        let query = FIRDatabase.database().reference().child("DC/Bands/\(cleanFBString(string: band.name!))/Events").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                completion(val.allKeys as! [String])
            } else {
                completion([])
            }
        })
    }
    
    func updateRegion(venue: String, region: String, res: Int) {
        FIRDatabase.database().reference().child("DC/Venues/\(venue)/info/region").setValue(region)
        FIRDatabase.database().reference().child("DC/Venues/\(venue)/info/reservations/available").setValue(res)
        FIRDatabase.database().reference().child("DC/Venues/\(venue)/info/reservations/working").setValue(1)
    }
    
    func sendVenueData(venue: VenueObject, completion: @escaping (Bool) -> Void) {
        guard let newvenue = venue.venue else { return }
        let venuename = cleanFBString(string: newvenue)
        if let address = venue.address {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/address").setValue(address)
        }
        if let fb = venue.facebook {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/facebook").setValue(fb)
        }
        if let web = venue.website {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/website").setValue(web)
        }
        if let yelp = venue.yelp {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/yelp").setValue(yelp)
        }
        if let region = venue.region {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/region").setValue(region)
        }
        if let email = venue.email {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/email").setValue(email)
        }
        if let res = venue.reservationsNum {
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/reservations/available").setValue(res)
            FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/reservations/working").setValue(1)
        }
        if let coordinates = venue.coordinates {
            let ref = FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/")
            
            ref.updateChildValues([
                "coordinates":
                    [coordinates.coordinate.latitude,
                     coordinates.coordinate.longitude]
                ])
        } else { let _ = updateLocation(venue: venue, completion: {
            location in
            guard let location = location else { return }
            let ref = FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/")
            
            ref.updateChildValues([
                "coordinates":
                    [location.coordinate.latitude,
                     location.coordinate.longitude]
                ])
            })
        }
    
        completion(true)
        
    }
    
    func sendEventData(event: EventObject, completion: @escaping (Bool) -> Void) {
        if let band = event.bandString, let venue = event.venueString {
            let newevent = EventObject()
            newevent.venueString = venue
            newevent.bandString = band
            newevent.timeString = event.timeString
            newevent.timestamp = event.timestamp
            newevent.price = event.price
            newevent.ticketURL = event.ticketURL
            newevent.seatGeekID = event.seatGeekID
            let query = FIRDatabase.database().reference().child("DC/Bands/\(band)")
            query.observeSingleEvent(of: .value, with: {
                snapshot in
                if let dict = snapshot.value as? NSDictionary {
                    let band = BandObject(name: band)
                    newevent.band = band
                    if let infodict = dict["info"] as? NSDictionary {
                        newevent.band?.bandDescription = infodict["descriptionString"] as? String
                        newevent.band?.facebook = infodict["facebook"] as? String
                        newevent.band?.image = infodict["image"] as? String
                        let genres = (infodict["genre"] as? String)?.capitalized
                        newevent.band?.genre = (genres ?? "")
                        newevent.band?.website = infodict["website"] as? String
                        newevent.band?.youtube = infodict["youtube"] as? String
                    }
                    
                    
                    let newquery = FIRDatabase.database().reference().child("DC/Venues/\(venue)")
                    newquery.observeSingleEvent(of: .value, with: {
                        snapshot in
                        if let newObject = snapshot.value as? NSDictionary {
                            let venue = VenueObject(name: venue)
                            newevent.venue = venue
                            if let infodict = newObject["info"] as? NSDictionary {
                                newevent.venue?.address = infodict["address"] as? String
                                newevent.venue?.yelp = infodict["yelp"] as? String
                                newevent.venue?.website = infodict["website"] as? String
                                newevent.venue?.region = infodict["region"] as? String
                                if let coord = infodict["coordinates"] as? [Double] {
                                    newevent.venue?.coordinates = CLLocation(latitude: coord[0], longitude: coord[1])
                                }
                                
                                self.sendBuiltEvent(event: newevent, completion: {_ in
                                    completion(true)
                                })
                            }
                            
                        }
                    }, withCancel: {
                        error in
                        completion(false)
                    })
                    
                }
            }, withCancel: {
                error in
                completion(false)
            })
        }
        
        
    }

    func sendBuiltEvent(event: EventObject, completion: @escaping ((Bool) -> Void)) {
        let newEventRef = FIRDatabase.database().reference()
            .child("/DC/Events")
            .childByAutoId()
        
        let newEventID = newEventRef.key
        
        guard let bandstring = event.bandString, let venuestring = event.venueString else {
            completion(false)
            return
        }
        
        var newData = [
            "id": newEventID,
            "bandname": bandstring,
            "date": String(event.timestamp!.timeIntervalSince1970),
            "timeString": event.timeString ?? "",
            "updated": "true",
            "venuename": venuestring,
            ]
            as [String : Any]
        if let region = event.venue?.region {
            newData["venueregion"] = region
        }
        if let genre = event.band?.genre {
            newData["bandgenre"] = genre
        }
        if let ticket = event.ticketURL {
            newData["ticketURL"] = ticket
        }
        if let sgid = event.seatGeekID {
            newData["seatGeekID"] = sgid
        }
        if let image = event.band?.image {
            newData["bandimage"] = image
        }
        if let address = event.venue?.address {
            newData["venueaddress"] = address
        }
        if let price = event.price {
            newData["eventprice"] = price
        } else {
            newData["eventprice"] = "Unknown"
        }
        if let fb = event.band?.facebook {
            newData["bandfacebook"] = fb
        }
        if let site = event.venue?.website {
            newData["venuewebsite"] = site
        }
        if let yelp = event.venue?.yelp {
            newData["venueyelp"] = yelp
        }
        if let bandsite = event.band?.website {
            newData["bandwebsite"] = bandsite
        }
        if let yt = event.band?.youtube {
            newData["bandyoutube"] = yt
        }
        if let descript = event.band?.bandDescription {
            newData["banddescription"] = descript
        }
        if bandstring == "Save For Later" {
            
        } else {
            if let location = event.venue?.coordinates {
                newData["coordinates"] =
                    [location.coordinate.latitude,
                     location.coordinate.longitude]
            }
        }
        
        if bandstring == "Save For Later" {
            if let venue = event.venueString {
                var newvenue = cleanFBString(string: venue)
                let venueref = FIRDatabase.database().reference()
                    .child("DC/Venues/\(newvenue)/Events/\(newEventID)")
                venueref.setValue(newData)
            }
            
        } else {
            newEventRef.setValue(newData)
            
            if let band = event.bandString {
                var newband = cleanFBString(string: band)
                let bandRef = FIRDatabase.database().reference()
                    .child("DC/Bands/\(newband)/Events/\(newEventID)")
                bandRef.setValue(newData)
            }
            
            if let venue = event.venueString {
                var newvenue = cleanFBString(string: venue)
                let venueref = FIRDatabase.database().reference()
                    .child("DC/Venues/\(newvenue)/Events/\(newEventID)")
                venueref.setValue(newData)
            }
            
            
            
            if let sgid = event.seatGeekID, let venue = event.venueString  {
                let idsref = FIRDatabase.database().reference()
                    .child("DC/SeatGeek/\(sgid)")
                idsref.setValue(cleanFBString(string: venue))
            }
        }
        
        
        
        completion(true)
    }
    
    func denySeatGeek(sgid:Int) {
        let idsref = FIRDatabase.database().reference()
            .child("DC/SeatGeek/\(sgid)")
        idsref.setValue("denied")
    }
    
    
    func updateLocation(venue: VenueObject, completion: @escaping ((CLLocation?) -> Void)) {
        if let address = venue.address {
            if venue.coordinates == nil {
                let geocoder = CLGeocoder()
                myGroup.enter()
                geocoder.geocodeAddressString(address, completionHandler: {
                    placemarks, error in
                    if let error = error {
                        
                    } else {
                        completion(placemarks?.first?.location)
                    }
                })
            } else {
                completion(nil)
            }
            
        }
    }


}
