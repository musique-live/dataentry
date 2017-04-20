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
    var startkey: Int?
    
    func getEventWithID(id: String, _ completion: @escaping (([EventObject]) -> Void)) {
        ref = FIRDatabase.database().reference()
        let string = "Events/\(id)"
        let query = ref.child(string)
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let dict = snapshot.value as? NSDictionary {
                let event = self.processEvent(newObject: dict, key: id)
                self.updateEvents(events: [event], completion: {
                    events in
                    completion(events)
                })
            }
            else {
                completion([EventObject]())
            }
        }, withCancel: {
            (error) in
            completion([EventObject]())
        })
        
    }

    
    func processEventSnapshot(snapArray: FIRDataSnapshot, completion: @escaping (([EventObject]) -> Void)) {
        var events = [EventObject]()
        for child in snapArray.children {
            if let child = child as? FIRDataSnapshot {
                if let value = child.value as? NSDictionary {
                    let newEv = processEvent(newObject: value, key: child.key)
                    events.append(newEv)
                }
            }
        }
        
        
        self.updateEvents(events: events, completion: {
            doneevents in
            completion(doneevents)
        })
        
    }

    
    func processEvent(newObject: NSDictionary, key: String) -> EventObject {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS'Z'"
        let event = EventObject(
            body: newObject["eventdescription"] as? String,
            eventimage: newObject["eventpicture"] as? String,
            eventlink: newObject["eventlink"] as? String,
            price: newObject["eventprice"] as? Int,
            time: dateFormatter.date(from: newObject["date"] as? String ?? "") as NSDate?,
            title: newObject["eventname"] as? String,
            id: key,
            bandName: newObject["BandObjectname"] as? String,
            venueName: newObject["venuename"] as? String)
        
        if let time = newObject["eventTime"] as? String, time.startIndex != time.endIndex, time.characters.count > 10 {
            let start = time.index((time.startIndex), offsetBy: 11)
            let end = time.index((time.startIndex), offsetBy: 13)
            let range = start..<end
            let hour = "\(Int(time.substring(with: range))! - 5)"
            
            let minstart = time.index((time.startIndex), offsetBy: 14)
            let minend = time.index((time.startIndex), offsetBy: 16)
            let minrange = minstart..<minend
            let minute = time.substring(with: minrange)
            
            event.time = "\(hour):\(minute)"
        }
        
        if let time = newObject["eventadditionaltime"] as? String, time.startIndex != time.endIndex, time.characters.count > 10 {
            let start = time.index((time.startIndex), offsetBy: 11)
            let end = time.index((time.startIndex), offsetBy: 13)
            let range = start..<end
            let hour = "\(Int(time.substring(with: range))! - 5)"
            
            let minstart = time.index((time.startIndex), offsetBy: 14)
            let minend = time.index((time.startIndex), offsetBy: 16)
            let minrange = minstart..<minend
            let minute = time.substring(with: minrange)
            
            event.time = (event.time ?? "") + " and \(hour):\(minute)"
        }
        
        event.band?.bandDescription = newObject["BandObjectdescription"] as? String
        event.band?.facebook = newObject["BandObjectfacebook"] as? String
        event.band?.image = newObject["BandObjectimage"] as? String
        let tags = (newObject["BandObjecttags"] as? String)?.capitalized
        let genres = (newObject["BandObjectgenre"] as? String)?.capitalized
        event.band?.genre = (genres ?? "")
        event.band?.website = newObject["BandObjectwebsite"] as? String
        event.band?.youtube = newObject["BandObjectyoutube"] as? String
        
        event.venue?.address = newObject["venueaddress"] as? String
        event.venue?.dancing = newObject["venuedescription"] as? String
        event.venue?.facebook = newObject["venuewebsite"] as? String
        event.venue?.image = newObject["venueimage"] as? String
        event.venue?.yelp = newObject["venueyelp"] as? String
        event.venue?.website = newObject["venuewebsite"] as? String
        
        if let coord = newObject["coordinates"] as? [Double] {
            event.venue?.coordinates = CLLocation(latitude: coord[0], longitude: coord[1])
        }
        
        if let _ = newObject["updated"] as? String {
            event.updated = true
        } else {
            event.updated = false
            updateEventForBandObjectsAndVenues(event: event, newObject: newObject)
        }
        
        return event
    }

    
    func updateEvents(events: [EventObject], completion: @escaping (([EventObject]) -> Void)) {
        let loc = CLLocation(latitude: 38.9780, longitude: -76.8087)
        for event in events {
            if let venue = event.venue, let address = venue.address {
                if venue.coordinates == nil {
                    let geocoder = CLGeocoder()
                    myGroup.enter()
                    geocoder.geocodeAddressString(address, completionHandler: {
                        placemarks, error in
                        if let error = error {
                            print(error)
                            event.distance = 10000
                            self.myGroup.leave()
                        } else {
                            venue.coordinates = placemarks?.first?.location
                            if let coord = venue.coordinates {
                                event.distance = loc.distance(from: coord)
                                event.coordinates = coord.coordinate
                                self.updateGeoCode(event: event, coord: coord.coordinate)
                            }
                            self.myGroup.leave()
                        }
                    })
                } else {
                    if let coord = venue.coordinates {
                        event.distance = loc.distance(from: coord)
                        event.coordinates = coord.coordinate
                    }
                }
                
            }
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            completion(events)
        })
        
    }
    
    
    func sendFeedback(feedback: NSDictionary, completion: @escaping ((Bool) -> Void)) {
        ref = FIRDatabase.database().reference()
        
        let newRef = ref
            .child("Feedback")
            .childByAutoId()
        
        
        
        newRef.setValue(feedback, withCompletionBlock: {
            complete in
            
            completion(true)
            
        })
        
    }
    
    
    func getVenuesList(completion: @escaping (([String]) -> Void)) {
        let query = FIRDatabase.database().reference().child("Venues").queryOrderedByKey()
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
    
    func getBandObjectsList(completion: @escaping (([String]) -> Void)) {
        let query = FIRDatabase.database().reference().child("BandObjects").queryOrderedByKey()
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
    
    func getStartKey(completion: @escaping ((Int) -> Void)) {
        let query = FIRDatabase.database().reference().child("Startkey")
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? Int {
                completion(val)
            } else {
                completion(0)
            }
        }, withCancel: {
            error in
            completion(0)
        })
    }

    func updateEventForBandObjectsAndVenues(event: EventObject, newObject: NSDictionary) {
        if let id = event.id, let BandObjectname = event.band?.name, BandObjectname != "", !BandObjectname.contains("."), !BandObjectname.contains("$"), !BandObjectname.contains("#") {
            FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/Events/\(id)").setValue(newObject)
            if let youtube = event.band?.youtube {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/youtube").setValue(youtube)
            }
            if let youtube = event.band?.youtube {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/youtube").setValue(youtube)
            }
            if let descriptionString = event.band?.bandDescription {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/descriptionString").setValue(descriptionString)
            }
            if let facebook = event.band?.facebook {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/facebook").setValue(facebook)
            }
            if let image = event.band?.image {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/image").setValue(image)
            }
            if let genre = event.band?.genre {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/genre").setValue(genre)
            }
            if let website = event.band?.website {
                FIRDatabase.database().reference().child("BandObjects/\(BandObjectname)/website").setValue(website)
            }
        }
        if let id = event.id, let venuename = event.venue?.venue, venuename != "", !venuename.contains("."), !venuename.contains("$"), !venuename.contains("#") {
            FIRDatabase.database().reference().child("Venues/\(venuename)/Events/\(id)").setValue(newObject)
        }
        
        if let id = event.id {
            let ref = FIRDatabase.database().reference().child("Events/\(id)")
            
            ref.updateChildValues([
                "updated": "true"
                ])
            
        }
    }
    
    
    
    func updateGeoCode(event: EventObject, coord: CLLocationCoordinate2D) {
        if let id = event.id {
            let ref = FIRDatabase.database().reference().child("Events/\(id)")
            
            ref.updateChildValues([
                "coordinates": [
                    coord.latitude,
                    coord.longitude
                ]
                ])
            
        }
    }

    
}




