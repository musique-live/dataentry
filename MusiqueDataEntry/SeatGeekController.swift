//
//  SeatGeekController.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import Alamofire

let seatgeeksecret = "5fc8456ed09d9f40c32adbff67b1fd5a9e44671338cb65a7ea4a20bae9ba24bc"
let seatgeekclient = "Nzc4NjQxMnwxNDk2OTc2NTE3LjEz"


class SeatGeekController: NSObject {
    
    var page: Int?
    var searchURL = "https://api.seatgeek.com/2/events?client_id=Nzc4NjQxMnwxNDk2OTc2NTE3LjEz&geoip=20769&type=concert"
    
    
    func loadNextEvents(completion: @escaping([SeatGeekObject]) -> Void) {
        if let page = page {
            searchURL = searchURL + "&page=\(page)"
            self.page = page + 1
        } else {
            page = 2
        }
        Alamofire.request(searchURL).responseJSON { response in
            var newevents = [SeatGeekObject]()
            if let JSON = response.result.value as? NSDictionary {
                if let events = JSON["events"] as? [NSDictionary] {
                    for event in events {
                        if let mappedEvent = SeatGeekObject(JSON: event as! [String : Any]) {
                            newevents.append(mappedEvent)
                        }
                    }
                }
            }
            completion(self.updateEvents(events: newevents))
        }
    }
    
    func updateEvents(events: [SeatGeekObject]) -> [SeatGeekObject] {
        var newevents = events
        for event in events {
            if let splitEvent = event.split() {
                newevents.append(splitEvent)
            }
        }
        return newevents
    }
    
    
    
}
