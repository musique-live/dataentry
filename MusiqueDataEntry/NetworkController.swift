//
//  NetworkController.swift
//  musique
//
//  Created by Tara Wilson on 9/19/16.
//  Copyright © 2016 twil. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

let database = "https://musiquelive-2167e.firebaseio.com/"

class NetworkController: NSObject {
    
    var ref: FIRDatabaseReference!
    let geocoder = CLGeocoder()
    var filter: FilterObject?
    var myGroup = DispatchGroup()
    let numberOfItemsPerPage = 100
    let numberOfItemsPerDate = 100
    var startkey: Int?
    var onedelete = false
    
    func getAllEventsWithFilter(filter: FilterObject, _ completion: @escaping (([EventObject], Int?) -> Void)) {
        self.filter = filter
        ref = FIRDatabase.database().reference()
        
        if let _ = filter.venue {
            venueSearch({
                events in
                completion(events, self.startkey)
            })
        } else if let _ = filter.band {
            bandSearch({
                events in
                completion(events, self.startkey)
            })
        } else if let _ = filter.date {
            dateSearch({
                events in
                completion(events, self.startkey)
            })
        } else {
            regularSearch({
                events in
                completion(events, self.startkey)
            })
        }
        
    }
    
    func venueSearch(_ completion: @escaping (([EventObject]) -> Void)) {
        guard let venueSearch = filter?.venue else {
            return
        }
        let query = ref.child("Venues/\(venueSearch)/Events").queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    completion(newevents)
                })
            } else {
                completion([EventObject]())
            }
        }, withCancel: {
            (error) in
            completion([EventObject]())
        })
        
    }
    
    func bandSearch(_ completion: @escaping (([EventObject]) -> Void)) {
        guard let bandSearch = filter?.band else {
            return
        }
        let query = ref.child("Bands/\(bandSearch)/Events").queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    completion(newevents)
                })
            } else {
                completion([EventObject]())
            }
        }, withCancel: {
            (error) in
            completion([EventObject]())
        })
        
    }
    
    func dateSearch(_ completion: @escaping (([EventObject]) -> Void)) {
        guard let dateSearch = filter?.date else {
            return
        }
        let calendar = NSCalendar.current
        let year =  calendar.component(.year, from: dateSearch as Date)
        let month = calendar.component(.month, from: dateSearch as Date)
        let day = calendar.component(.day, from: dateSearch as Date)
        
        var stringMonth = "\(month)"
        var stringDay = "\(day)"
        if stringMonth.characters.count == 1 {
            stringMonth = "0" + stringMonth
        }
        if stringDay.characters.count == 1 {
            stringDay = "0" + stringDay
        }
        
        let query = ref.child("Events").queryOrdered(byChild: "date").queryEqual(toValue: "\(year)-\(stringMonth)-\(stringDay)T04:00:00.000Z")
        
        let limit = filter?.date == nil ? numberOfItemsPerPage : numberOfItemsPerDate
        query.queryLimited(toFirst: UInt(limit)).observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    completion(newevents)
                })
            } else {
                completion([EventObject]())
            }
        }, withCancel: {
            (error) in
            completion([EventObject]())
        })
    }
    
    func regularSearch(_ completion: @escaping (([EventObject]) -> Void)) {
        var query = ref.child("Events").queryOrderedByKey()
        
        getStartKey(completion: {
            key in
            
            if self.startkey == nil {
                self.startkey = key
            }
            
            if let k = self.startkey {
                query = query.queryStarting(atValue: "\(k)")
            } else {
                self.startkey = 0
                query = query.queryStarting(atValue: "0")
            }
            
            let limit = self.filter?.date == nil ? self.numberOfItemsPerPage : self.numberOfItemsPerDate
            query.queryLimited(toFirst: UInt(limit)).observeSingleEvent(of: .value, with: {
                snapshot in
                if snapshot.hasChildren() {
                    self.processEventSnapshot(snapArray: snapshot, completion: {
                        newevents in
                        completion(newevents)
                    })
                } else {
                    completion([EventObject]())
                }
            }, withCancel: {
                (error) in
                completion([EventObject]())
            })
        })
        
        
    }
    
    /////// first
    
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
    
    //////// second
    
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
    
    
    /////////third
    
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
    
    //////////// fourth
    
    func doFilter(events: [EventObject]) -> [EventObject] {
        let newevents = events.sorted(by: { $0.distance ?? Double(mindist) < $1.distance ?? Double(mindist) })
        let genreevents = filterByGenre(events: newevents)
        let priceevents = filterByPrice(events: genreevents)
        let dateevents = filterByDate(events: priceevents)
        let distanceeventes = filterByDistance(events: dateevents)
        return distanceeventes
    }
    
    /////////////// other
    
    
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
    
    func filterByGenre(events: [EventObject]) -> [EventObject] {
        var newEvents = events
        if let filter = filter, filter.genre.count > 0 {
            for (i,event) in newEvents.enumerated().reversed() {
                var contains = false
                for genre in (filter.genre) {
                    if event.band?.genre?.contains(genre) == true {
                        contains = true
                    }
                }
                if contains == false {
                    newEvents.remove(at: i)
                }
            }
        }
        return newEvents
    }
    
    func filterByPrice(events: [EventObject]) -> [EventObject] {
        if let price = filter?.price {
            let newEvents = events.filter() {($0.price ?? 0) < price + 1}
            return newEvents
        }
        return events
    }
    
    func filterByOutdoors(events: [EventObject]) -> [EventObject] {
        return events
    }
    
    func filterByDate(events: [EventObject]) -> [EventObject] {
        var newEvents = events
        var currentDate = NSDate()
        currentDate = currentDate.addingTimeInterval(-100000)
        
        for (i,event) in newEvents.enumerated().reversed() {
            if event.timestamp?.compare(currentDate as Date) == .orderedAscending {
                newEvents.remove(at: i)
            }
        }
        
        return newEvents.sorted(by: { $0.timestamp?.compare(($1.timestamp as? Date) ?? Date()) == ComparisonResult.orderedAscending })
        
        
    }
    
    func filterByDistance(events: [EventObject]) -> [EventObject] {
        let amount = Double(filter?.distance ?? mindist)
        let newEvents = events.filter() {$0.distance ?? 0 < amount}
        return newEvents
    }
    
    
    func deleteEvent(event: EventObject) {
        if let id = event.id {
            FIRDatabase.database().reference().child("Events/\(id)").removeValue(completionBlock: {
                completion in
                
            })
        }
        
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




