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
    
    var myGroup = DispatchGroup()
    var page: Int?
    let searchURL = "https://api.seatgeek.com/2/events?client_id=Nzc4NjQxMnwxNDk2OTc2NTE3LjEz&geoip=20769&type=concert&per_page=50"
    var youtubeURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&key=AIzaSyDDqTGpVR7jxeozoOEjH6SLaRdw0YY-HPQ"
    var venues: [String]?
    var usedIDs: [Int]?
    
    func cleanFBString(string: String) -> String {
        var newstring = string.replacingOccurrences(of: ".", with: "")
        newstring = newstring.replacingOccurrences(of: "#", with: "")
        newstring = newstring.replacingOccurrences(of: "$", with: "")
        newstring = newstring.replacingOccurrences(of: "[", with: "")
        newstring = newstring.replacingOccurrences(of: "]", with: "")
        return newstring
    }
    
    func loadNextEvents(completion: @escaping([SeatGeekObject]) -> Void) {
        var currentsearchURL = searchURL
        if let page = page {
            currentsearchURL = searchURL + "&page=\(page)"
            self.page = page + 1
        } else {
            page = 2
        }
        Alamofire.request(currentsearchURL).responseJSON { response in
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
            var updatedevents = self.updateEvents(events: newevents)
            
            NetworkController().getVenuesList(completion: {
                newvenues in
                
                
                //just setting venues
                var checkvenues = [String]()
                for item in newvenues {
                    checkvenues.append(self.cleanFBString(string: item))
                }
                self.venues = checkvenues
                /////
                
                NetworkController().getSeatGeekList(completion:  {
                    newids in
                    self.usedIDs = newids
                    
                    var deleteids = [Int]()
                    for (index, event) in updatedevents.enumerated() {
                        if let venue = event.venuename {
                            event.venueExists = self.checkEventsForVenue(venue: venue)
                        }
                        if let id = event.id {
                            if self.usedIDs?.contains(id) == true {
                                deleteids.append(index)
                            }
                        }
                    }
                    
                    for item in deleteids.reversed() {
                        updatedevents.remove(at: item)
                    }
                    
                    self.getAllYoutube(events: updatedevents, completion: {
                        finalevents in
                        completion(finalevents)
                    })
                    
                })
                
                
                
            })
            
        }
    }
    
    func checkEventsForVenue(venue: String) -> Bool {
        if let venues = venues {
            if venues.contains(cleanFBString(string: venue)) {
                return true
            }
            return false
        }
        return false
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
    
    func getAllYoutube(events: [SeatGeekObject], completion: @escaping([SeatGeekObject]) -> Void) {
        let returnEvents = events
        for event in returnEvents {
            if let band = event.name {
                let searchband = band.replacingOccurrences(of: " ", with: "+")
                let url = youtubeURL + "&q=\(searchband)+music+band"
                myGroup.enter()
                Alamofire.request(url).responseJSON { response in
                    if let result = response.result.value as? NSDictionary {
                        if let answers = result["items"] as? [NSDictionary] {
                            if let itemsid = answers.first?["id"] as? NSDictionary {
                                if let youtubeid = itemsid["videoId"] as? String {
                                    event.youtube = youtubeid
                                    self.myGroup.leave()
                                } else {
                                   self.myGroup.leave()
                                }
                            } else {
                                self.myGroup.leave()
                            }
                        } else {
                            self.myGroup.leave()
                        }
                    } else {
                        self.myGroup.leave()
                    }
                    
                }
                myGroup.notify(queue: DispatchQueue.main, execute: {
                    completion(returnEvents)
                })
            }
        }
    }
    
}
