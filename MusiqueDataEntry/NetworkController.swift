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
    
    func getAllEvents(completion: @escaping(([EventObject]) -> Void)) {
        let fourweek = String(NSDate().addingTimeInterval(86400*7*4).timeIntervalSince1970)
        let currentdate = String(NSDate().timeIntervalSince1970)
        var querystring = "/DC/Events"
        let ref = FIRDatabase.database().reference()
        

        
        let query = ref.child(querystring).queryOrdered(byChild: "date").queryStarting(atValue: currentdate).queryEnding(atValue: fourweek)
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
    
    
    //for delete
    //        let fourweekago = String(NSDate().addingTimeInterval(-86400*7*4).timeIntervalSince1970)
    //        let query = ref.child(querystring).queryOrdered(byChild: "date").queryEnding(atValue: fourweekago)
    //        query.observeSingleEvent(of: .value, with: {
    //            snapshot in
    //            if snapshot.hasChildren() {
    //                self.processEventSnapshot(snapArray: snapshot, completion: {
    //                    newevents in
    //                    for event in newevents {
    //                        self.deleteEvent(event: event)
    //                    }
    //                    completion(newevents)
    //                })
    //            } else {
    //                completion([EventObject]())
    //            }
    //        }, withCancel: {
    //            (error) in
    //            completion([EventObject]())
    //        })
    
    func deleteEvent(event: EventObject) {
        guard let id = event.id, let band = event.band?.name, let venue = event.venue?.venue else { return }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        print(formatter.string(from: event.timestamp as? Date ?? Date()))
        
        let query = FIRDatabase.database().reference().child("DC/Events/\(id)")
        query.removeValue()
        
        let venuequery = FIRDatabase.database().reference().child("DC/Bands/\(cleanFBString(string: band))/Events/\(id)")
        venuequery.removeValue()
        
        let bandquery = FIRDatabase.database().reference().child("DC/Venues/\(cleanFBString(string: venue))/Events/\(id)")
        bandquery.removeValue()
    }
    
    func getVenuesList(completion: @escaping ((NSDictionary) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Venues").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let keys = val.allKeys as! [String]
                self.getOwner(venues: keys.sorted(), completion: {
                    result in
                    completion(result)
                })
            } else {
                completion([:])
            }
        }, withCancel: {
            (error) in
            completion([:])
        })
    }

    func getOwner(venues: [String], completion: @escaping((NSDictionary) -> Void)) {
        var returndict = NSMutableDictionary()
        
        for venue in venues {
            myGroup.enter()
            getClaimed(venue: venue, completion: {
                name in
                if let name = name {
                    returndict.setObject(name.lowercased(), forKey: venue as NSCopying)
                } else {
                    returndict.setObject("unclaimed", forKey: venue as NSCopying)
                }
                self.myGroup.leave()
            })
        }
        
        myGroup.notify(queue: .main) {
            completion(returndict)
        }
    }
    
    func getIdsList(venue: String, completion: @escaping (([String]) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Venues/\(venue)/Events").queryOrderedByKey()
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
    
    func getSeatGeekList(completion: @escaping (([Int]) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/SeatGeek").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let keys = val.allKeys as! [String]
                var ints = [Int]()
                for key in keys {
                    if let newint = Int(key) {
                        ints.append(newint)
                    }
                }
                completion(ints)
            } else {
                completion([])
            }
        }, withCancel: {
            (error) in
            completion([])
        })
    }
    
    func getBand(band: String, completion: @escaping (BandObject) -> Void) {
        let query = FIRDatabase.database().reference().child("DC/Bands/\(cleanFBString(string: band))/info")
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let band = BandObject(name: band)
                if let fb = val["facebook"] as? String {
                    band.facebook = fb
                }
                if let genre = val["genre"] as? String {
                    band.genre = genre
                }
                if let image = val["image"] as? String {
                    band.image = image
                }
                if let youtube = val["youtube"] as? String {
                    band.youtube = youtube
                }
                if let website = val["website"] as? String {
                    band.website = website
                }
                if let descript = val["descriptionString"] as? String {
                    band.bandDescription = descript
                }
                completion(band)
            }
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
    
    
    func cleanFBString(string: String) -> String {
        var newstring = string.replacingOccurrences(of: ".", with: "")
        newstring = newstring.replacingOccurrences(of: "#", with: "")
        newstring = newstring.replacingOccurrences(of: "$", with: "")
        newstring = newstring.replacingOccurrences(of: "[", with: "")
        newstring = newstring.replacingOccurrences(of: "]", with: "")
        return newstring
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
        if let coord = newObject["coordinates"] as? [Double] {
            event.coordinates = CLLocationCoordinate2D(latitude: coord[0], longitude: coord[1])
        }
        if let image = newObject["bandimage"] as? String {
            event.band?.image = image
        }
        
        return event
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

    
    
  
