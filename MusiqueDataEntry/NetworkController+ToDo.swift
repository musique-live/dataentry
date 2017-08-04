//
//  NetworkController+ToDO.swift
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
    
    func getLastDate(fullvenue: String, completion: @escaping([EventObject]?) -> Void) {
        let venue = cleanFBString(string: fullvenue)
        let currentdate = String(NSDate().timeIntervalSince1970)
        let newquery = FIRDatabase.database().reference().child("DC/Venues/\(venue)/Events").queryOrdered(byChild: "date").queryStarting(atValue: currentdate)
        newquery.observeSingleEvent(of: .value, with: {
            
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    completion(newevents)
                    
                })
            } else {
                completion(nil)
            }
            
        }, withCancel: {
            error in
            completion(nil)
        })
        
    }
    
    func getFirstDate(fullvenue: String, completion: @escaping(EventObject?) -> Void) {
        let venue = cleanFBString(string: fullvenue)
        let newquery = FIRDatabase.database().reference().child("DC/Venues/\(venue)/Events").queryOrdered(byChild: "date").queryLimited(toFirst: 1)
        newquery.observeSingleEvent(of: .value, with: {
            
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    completion(newevents.last)
                    
                })
            } else {
                completion(nil)
            }
            
        }, withCancel: {
            error in
            completion(nil)
        })
        
    }
    
    func fixCoordinates(venue: String, newCoords: CLLocationCoordinate2D) {
        NetworkController().getIdsListForVenueEvents(venue: venue, completion: {
            ids in
            for id in ids {
                let ref = FIRDatabase.database().reference().child("DC/Venues/\(venue)/Events/\(id)")
                
                ref.updateChildValues([
                    "coordinates":
                        [newCoords.latitude,
                         newCoords.longitude]
                    ])

            }
            for id in ids {
                let ref = FIRDatabase.database().reference().child("DC/Events/\(id)")
                
                ref.updateChildValues([
                    "coordinates":
                        [newCoords.latitude,
                         newCoords.longitude]
                    ])
                
            }
            let ref = FIRDatabase.database().reference().child("DC/Venues/\(venue)/info")
            
            ref.updateChildValues([
                "coordinates":
                    [newCoords.latitude,
                     newCoords.longitude]
                ])
        })
    }
    
    func getInfo(fullvenue: String, completion: @escaping(NSDictionary?) -> Void) {
        let venue = cleanFBString(string: fullvenue)
        let newquery = FIRDatabase.database().reference().child("DC/Venues/\(venue)/info")
        newquery.observeSingleEvent(of: .value, with: {
            
            snapshot in
            if let dict = snapshot.value as? NSDictionary {
                completion(dict)
            } else {
                completion(nil)
            }
            
        }, withCancel: {
            error in
            completion(nil)
        })
        
    }
    
    func setClaimed(venue: String, name: String) {
        let venuename = cleanFBString(string: venue)
        FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/claimed").setValue(name)
    }
    
    func getClaimed(venue: String, completion: @escaping(String?) -> Void) {
        let venuename = cleanFBString(string: venue)
        let query = FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/claimed").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let name = snapshot.value as? String {
                completion(name)
            } else {
                completion(nil)
            }
        }, withCancel: {
            (error) in
            completion(nil)
        })
        
    }
    
}
