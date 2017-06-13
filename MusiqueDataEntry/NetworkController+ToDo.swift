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

extension NetworkController {
    
    func getLastDate(fullvenue: String, completion: @escaping(EventObject?) -> Void) {
        let venue = cleanFBString(string: fullvenue)
        let newquery = FIRDatabase.database().reference().child("DC/Venues/\(venue)/Events").queryOrdered(byChild: "date").queryLimited(toLast: 1)
        print(venue)
        newquery.observeSingleEvent(of: .value, with: {
            
            snapshot in
            print(snapshot)
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
    
    func setClaimed(venue: String, name: String) {
        let venuename = cleanFBString(string: venue)
        FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/claimed").setValue(name)
    }
    
    func getClaimed(venue: String, completion: @escaping(String?) -> Void) {
        let venuename = cleanFBString(string: venue)
        let query = FIRDatabase.database().reference().child("DC/Venues/\(venuename)/info/claimed").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            print(snapshot)
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
