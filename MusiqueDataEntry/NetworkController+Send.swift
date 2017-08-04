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
        guard let newband = band.band else { return }
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
        if let tf = band.ticketFlyID {
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/info/bandTicketflyID").setValue(tf)
        }
        completion(true)
    }
    
    func updateBandData(band: BandObject, completion: @escaping (Bool) -> Void) {
        sendBandData(band: band, completion: {
            success in
            
            self.getAllBandEvents(band: band, completion: {
                eventIDS in
                
                let cleanband = self.cleanFBString(string: band.band!)
                
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
    
    func sendEventDataWithoutBandVenueInfo(event: EventObject, completion: @escaping (Bool) -> Void) {
        if let band = event.band?.band, let venue = event.venue?.venue {
            var newevent = event
            
            self.getBandForString(band: band, completion: {
                band in
                newevent.band = band
                
                self.getVenueForString(venue: venue, completion: {
                    newvenue in
                    newevent.venue = newvenue
                    self.sendBuiltEvent(event: newevent, createBand: false, completion: {
                        _ in
                        completion(true)
                    })
                })
            })
        } else {
            completion(false)
        }
    }

    func sendBuiltEvent(event: EventObject, createBand: Bool, completion: @escaping ((Bool) -> Void)) {
        let newEventRef = FIRDatabase.database().reference()
            .child("/DC/Events")
            .childByAutoId()
        
        let newEventID = newEventRef.key
        
        guard let bandstring = event.band?.band, let venuestring = event.venue?.venue else {
            completion(false)
            return
        }
        
        let newData = event.createSendDict(newEventID: newEventID)
           
        newEventRef.setValue(newData)
        
        if createBand {
            self.sendBandData(band: event.band!, completion: {
                success in
            })
        }
        
        if let band = event.band?.band {
            var newband = cleanFBString(string: band)
            let bandRef = FIRDatabase.database().reference()
                .child("DC/Bands/\(newband)/Events/\(newEventID)")
            bandRef.setValue(newData)
        }
        
        if let venue = event.venue?.venue {
            var newvenue = cleanFBString(string: venue)
            let venueref = FIRDatabase.database().reference()
                .child("DC/Venues/\(newvenue)/Events/\(newEventID)")
            venueref.setValue(newData)
            FIRDatabase.database().reference().child("DC/Venues/\(newvenue)/info/lastUpdated").setValue(String(NSDate().timeIntervalSince1970))
        }
        
        completion(true)
    }
    
    func getTicketFlyVenues(completion: @escaping(([String: String]) -> Void)) {
        var returnDict = [String: String]()
        let query = FIRDatabase.database().reference().child("DC/Other/TicketflyVenues").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let keys = val.allKeys as! [String]
                for key in keys {
                    returnDict[key] = "\(val.object(forKey: key) as! Int)"
                }
                completion(returnDict)
            } else {
                completion([:])
            }
        }, withCancel: {
            (error) in
            completion([:])
        })
    }
    
    func updateVenueTicketflyID(venue: VenueObject, id: Int) {
        guard let newvenue = venue.venue else { return }
        let venuename = cleanFBString(string: newvenue)
        FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/ticketflyVenueID").setValue(id)
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
