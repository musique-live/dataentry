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
        
        if let key = startkey {
            if events.count == numberOfItemsPerPage {
                startkey = events.count + key
            } else {
                startkey = nil
            }
        }
        
        self.updateEvents(events: events, completion: {
            doneevents in
            completion(self.doFilter(events: doneevents))
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
            bandName: newObject["bandname"] as? String,
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
        
        event.band?.dancing = newObject["banddancing"] as? String
        event.band?.descriptionString = newObject["banddescription"] as? String
        event.band?.facebook = newObject["bandfacebook"] as? String
        event.band?.image = newObject["bandimage"] as? String
        let tags = (newObject["bandtags"] as? String)?.capitalized
        let genres = (newObject["bandgenre"] as? String)?.capitalized
        if genres == nil {
            event.band?.genre = (tags ?? "")
        } else if tags == nil {
            event.band?.genre = (genres ?? "")
        } else {
            event.band?.genre = (genres ?? "") + ", " + (tags ?? "")
        }
        event.band?.website = newObject["bandwebsite"] as? String
        event.band?.youtube = newObject["bandyoutube"] as? String
        
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
            updateEventForBandsAndVenues(event: event, newObject: newObject)
        }
        
        return event
    }

    
    func updateEvents(events: [EventObject], completion: @escaping (([EventObject]) -> Void)) {
        let loc = self.filter?.currentLocation ?? CLLocation(latitude: 38.9780, longitude: -76.8087)
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
    
    func getBandsList(completion: @escaping (([String]) -> Void)) {
        let query = FIRDatabase.database().reference().child("Bands").queryOrderedByKey()
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

    func updateEventForBandsAndVenues(event: EventObject, newObject: NSDictionary) {
        if let id = event.id, let bandname = event.band?.band, bandname != "", !bandname.contains("."), !bandname.contains("$"), !bandname.contains("#") {
            FIRDatabase.database().reference().child("Bands/\(bandname)/Events/\(id)").setValue(newObject)
            if let youtube = event.band?.youtube {
                FIRDatabase.database().reference().child("Bands/\(bandname)/youtube").setValue(youtube)
            }
            if let youtube = event.band?.youtube {
                FIRDatabase.database().reference().child("Bands/\(bandname)/youtube").setValue(youtube)
            }
            if let descriptionString = event.band?.descriptionString {
                FIRDatabase.database().reference().child("Bands/\(bandname)/descriptionString").setValue(descriptionString)
            }
            if let facebook = event.band?.facebook {
                FIRDatabase.database().reference().child("Bands/\(bandname)/facebook").setValue(facebook)
            }
            if let image = event.band?.image {
                FIRDatabase.database().reference().child("Bands/\(bandname)/image").setValue(image)
            }
            if let genre = event.band?.genre {
                FIRDatabase.database().reference().child("Bands/\(bandname)/genre").setValue(genre)
            }
            if let website = event.band?.website {
                FIRDatabase.database().reference().child("Bands/\(bandname)/website").setValue(website)
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




