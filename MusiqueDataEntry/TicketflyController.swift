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
let getEventsVenueString = "http://www.ticketfly.com/api/events/upcoming.json?venueId="

class TicketFlyController: NSObject {
    
    var myGroup = DispatchGroup()
    var myGroup2 = DispatchGroup()
    
    func getEventsForID(id: String, venue: String, completion: @escaping([EventObject]) -> Void) {
        
        var currentsearchURL = getEventsVenueString + id
        let orgs = ["Vinyl Lounge at Gypsy Sallys", "U Street Music Hall", "The Hamilton", "Smokehouse Live", "Sixth & I Synagogue", "Rock and Roll Hotel", "Rams Head Tavern", "Rams Head On Stage", "9:30 Club", "Rams Head Live", "Rams Head Dockside", "Pier Six Concert Pavilion", "Ottobar", "Metro Gallery", "Merriweather Post Pavilion", "Live! Center Stage", "Lincoln Theatre", "Jammin java", "Hill Country DC", "Gypsy Sallys", "Flash", "Fish Head Cantina", "Echostage", "DC9", "Bottle and Cork", "Black Cat", "Bambou" ]
        
        if orgs.contains(venue) {
            var currentsearchURL = getEventsString + id
        }
        
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
                } else {
                    print("no events")
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
