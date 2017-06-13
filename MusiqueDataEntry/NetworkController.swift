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

    
    
  
