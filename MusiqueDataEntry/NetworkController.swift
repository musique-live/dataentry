//
//  NetworkController.swift
//  musique
//
//  Created by Tara Wilson on 9/19/16.
//  Copyright © 2016 twil. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

let database = "https://musiquelive-2167e.firebaseio.com/"

class NetworkController: NSObject {
    
    var ref: FIRDatabaseReference!
    let geocoder = CLGeocoder()
    var myGroup = DispatchGroup()
    
    
    func getVenuesList(completion: @escaping (([String]) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Venues").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                completion(val.allKeys as! [String])
            } else {
                completion([])
            }
        }, withCancel: {
            (error) in
            completion([])
        })
    }
    
    func getVenuesListWithDates(completion: @escaping (([EventObject]?) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Venues").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let venues = val.allKeys as! [String]
                var dict = [EventObject]()
                for venue in venues {
                    var newvenue = venue.replacingOccurrences(of: ".", with: "")
                    newvenue = newvenue.replacingOccurrences(of: "#", with: "")
                    newvenue = newvenue.replacingOccurrences(of: "$", with: "")
                    newvenue = newvenue.replacingOccurrences(of: "[", with: "")
                    newvenue = newvenue.replacingOccurrences(of: "]", with: "")
                    newvenue = newvenue.replacingOccurrences(of: " ", with: "")
                    self.myGroup.enter()
                    self.getLastDate(venue: newvenue, completion: {
                        event in
                        if let event = event {
                           dict.append(event)
                        }
                        
                        self.myGroup.leave()
                    })
                }
                self.myGroup.notify(queue: DispatchQueue.main, execute: {
                    completion(dict)
                })
            }
        }, withCancel: {
            (error) in
            completion(nil)
        })
    }
    
    func getBandObjectsList(completion: @escaping (([String]) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Bands").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                completion(val.allKeys as! [String])
            } else {
                completion([])
            }
        }, withCancel: {
            (error) in
            completion([])
        })
    }
    
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
            FIRDatabase.database().reference().child("DC/Bands/\(bandname)/email").setValue(email)
        }
        completion(true)
    }

    func cleanFBString(string: String) -> String {
        var newstring = string.replacingOccurrences(of: ".", with: "")
        newstring = newstring.replacingOccurrences(of: "#", with: "")
        newstring = newstring.replacingOccurrences(of: "$", with: "")
        newstring = newstring.replacingOccurrences(of: "[", with: "")
        newstring = newstring.replacingOccurrences(of: "]", with: "")
        return newstring
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
        

        let _ = updateLocation(venue: venue, completion: {
            location in
            guard let location = location else { return }
            let ref = FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/")
            
            ref.updateChildValues([
                "coordinates":
                    [location.coordinate.latitude,
                     location.coordinate.longitude]
                ])
        })
        
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
            let query = FIRDatabase.database().reference().child("DC/Bands/\(band)")
            query.observeSingleEvent(of: .value, with: {
                snapshot in
                print(snapshot)
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
                        print(snapshot)
                        if let newObject = snapshot.value as? NSDictionary {
                            let venue = VenueObject(name: venue)
                            newevent.venue = venue
                            if let infodict = newObject["info"] as? NSDictionary {
                                newevent.venue?.address = infodict["address"] as? String
                                newevent.venue?.yelp = infodict["yelp"] as? String
                                newevent.venue?.website = infodict["website"] as? String
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
    
    func getLastDate(venue: String, completion: @escaping(EventObject?) -> Void) {
        var newvenue = venue.replacingOccurrences(of: ".", with: "")
        newvenue = newvenue.replacingOccurrences(of: "#", with: "")
        newvenue = newvenue.replacingOccurrences(of: "$", with: "")
        newvenue = newvenue.replacingOccurrences(of: "[", with: "")
        newvenue = newvenue.replacingOccurrences(of: "]", with: "")
        let newquery = FIRDatabase.database().reference().child("DC/Venues/\(newvenue)/Events").queryOrdered(byChild: "date")
        newquery.observeSingleEvent(of: .value, with: {
            
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    completion(newevents.last)
                    
                })
            } else {
                completion(EventObject(body: nil, eventimage: nil, eventlink: nil, price: nil, time: nil, title: nil, id: nil, bandName: nil, venueName: venue))
            }
            
        }, withCancel: {
            error in
            completion(nil)
        })

    }
    
    func processEventSnapshot(snapArray: FIRDataSnapshot, completion: @escaping (([EventObject]) -> Void)) {
        var events = [EventObject]()
        for child in snapArray.children {
            if let child = child as? FIRDataSnapshot {
                if let value = child.value as? NSDictionary {
                    let newEv = processEvent(newObject: value, key: child.key)
                    events.append(newEv)
                    completion(events)
                }
            }
        }
        
    }
    
    func processEvent(newObject: NSDictionary, key: String) -> EventObject {
        let date = (newObject["date"] as? String ?? "")
        let event = EventObject(
            body: "",
            eventimage: "",
            eventlink: "",
            price: 0,
            time: NSDate(jsonDate: date),
            title: "",
            id: newObject["id"] as? String,
            bandName: newObject["bandname"] as? String,
            venueName: newObject["venuename"] as? String)
        
        return event
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
            "venuename": venuestring
        ]
         as [String : Any]
        
        if let genre = event.band?.genre {
            newData["bandgenre"] = genre
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
        if let location = event.venue?.coordinates {
            newData["coordinates"] =
            [location.coordinate.latitude,
            location.coordinate.longitude]
        }
        
        newEventRef.setValue(newData)
        
        
        if let region = event.venue?.region {
            let regionRef = FIRDatabase.database().reference()
                .child("DC/Region/\(region)/Events/\(newEventID)")
            regionRef.setValue(newData)
        }
        
        if let band = event.bandString {
            var newband = band.replacingOccurrences(of: ".", with: "")
            newband = newband.replacingOccurrences(of: "#", with: "")
            newband = newband.replacingOccurrences(of: "$", with: "")
            newband = newband.replacingOccurrences(of: "[", with: "")
            newband = newband.replacingOccurrences(of: "]", with: "")
            let bandRef = FIRDatabase.database().reference()
                .child("DC/Bands/\(newband)/Events/\(newEventID)")
            bandRef.setValue(newData)
        }
        
        if let venue = event.venueString {
            var newvenue = venue.replacingOccurrences(of: ".", with: "")
            newvenue = newvenue.replacingOccurrences(of: "#", with: "")
            newvenue = newvenue.replacingOccurrences(of: "$", with: "")
            newvenue = newvenue.replacingOccurrences(of: "[", with: "")
            newvenue = newvenue.replacingOccurrences(of: "]", with: "")
            let venueref = FIRDatabase.database().reference()
                .child("DC/Venues/\(newvenue)/Events/\(newEventID)")
            venueref.setValue(newData)
        }

        completion(true)
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

    
extension NSDate {
    convenience init?(jsonDate: String) {
        let scanner = Scanner(string: jsonDate)
        
        
        // Read milliseconds part:
        var seconds : Int64 = 0
        guard scanner.scanInt64(&seconds) else { return nil }
        let timeStamp = TimeInterval(seconds)
        
        // Success! Create NSDate and return.
        self.init(timeIntervalSince1970: timeStamp)
    }
}

    
    
  
