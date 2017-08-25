//
//  TicketflyController.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/3/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import Alamofire

let getEventsString = "http://www.ticketfly.com/api/events/upcoming.json?orgId="

class TicketFlyController: NSObject {
    
    var myGroup = DispatchGroup()
    var myGroup2 = DispatchGroup()
    
    func getEventsForID(id: String, venue: String, completion: @escaping([EventObject]) -> Void) {
        let currentsearchURL = getEventsString + id
        Alamofire.request(currentsearchURL).responseJSON { response in
            var newevents = [TicketFlyEvent]()
            if let JSON = response.result.value as? NSDictionary {
                if let events = JSON["events"] as? [NSDictionary] {
                    for event in events {
                        if let mappedEvent = TicketFlyEvent(JSON: event as! [String : Any]) {
                            mappedEvent.venue = venue
                            newevents.append(mappedEvent)
                        }
                    }
                }
            }
            self.postProcessTicketflyEvents(events: newevents, completion: {
                processedEvents in
                completion(processedEvents)
            })
        }
    }
    
    func postProcessTicketflyEvents(events: [TicketFlyEvent], completion: @escaping([EventObject]) -> Void) {
        let twoWeeksFromNow = Date().addingTimeInterval(60*60*24*30)
        let twoWeekEvents = events.filter({ $0.eventDate?.compare(twoWeeksFromNow) == ComparisonResult.orderedAscending})
        var allEvents = [EventObject]()
        for event in twoWeekEvents {
            myGroup.enter()
            EventObject().createWithTicketFly(ticketfly: event, completion: {
                eventobj in
                allEvents.append(eventobj)
                self.myGroup.leave()
            })
        }
        myGroup.notify(queue: DispatchQueue.main, execute: {
            completion(allEvents)
        })
        
    }
    
    func checkVenueForID() {
        
    }
    
    func sendEvents(bands: [String], id: Int, events: [EventObject], completion: @escaping((Bool) -> Void)) {
        var newbands = bands
        for event in events {
            myGroup2.enter()
            let createBand = !newbands.contains((event.band?.band)!)
            if createBand {
                newbands.append((event.band?.band)!)
            }
            NetworkController().sendBuiltEvent(event: event, createBand: createBand, completion: {
                success in
                self.myGroup2.leave()
            })
        }
        myGroup2.notify(queue: DispatchQueue.main, execute: {
            completion(true)
        })
        
    }
    
    /*
    func checkEventsForVenue(venue: String) -> Bool {
        if let venues = venues {
            if venues.contains(cleanFBString(string: venue)) {
                return true
            }
            return false
        }
        return false
    }
 
 
    */
    
}
