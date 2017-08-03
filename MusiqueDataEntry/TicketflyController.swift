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
    
    func getEventsForID(id: String) {
        let currentsearchURL = getEventsString + id
        Alamofire.request(currentsearchURL).responseJSON { response in
            var newevents = [TicketFlyEvent]()
            if let JSON = response.result.value as? NSDictionary {
                if let events = JSON["events"] as? [NSDictionary] {
                    for event in events {
                        if let mappedEvent = TicketFlyEvent(JSON: event as! [String : Any]) {
                            newevents.append(mappedEvent)
                        }
                    }
                }
            }
        }
    }
    
    
}
