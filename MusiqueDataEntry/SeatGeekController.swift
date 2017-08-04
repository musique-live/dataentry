import Foundation
import UIKit
import XCDYouTubeKit
import ObjectMapper
import Alamofire

let seatgeeksecret = "5fc8456ed09d9f40c32adbff67b1fd5a9e44671338cb65a7ea4a20bae9ba24bc"
let seatgeekclient = "Nzc4NjQxMnwxNDk2OTc2NTE3LjEz"

class SeatGeekController: NSObject {
    
    var myGroup = DispatchGroup()
    var page: Int?
    let searchURL = "https://api.seatgeek.com/2/events?client_id=Nzc4NjQxMnwxNDk2OTc2NTE3LjEz&geoip=20769&type=concert&per_page=50&aid=12689"
    var youtubeURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&key=AIzaSyDDqTGpVR7jxeozoOEjH6SLaRdw0YY-HPQ"
    var googleImagesURL = "https://www.googleapis.com/customsearch/v3/search?searchType=image&key=AIzaSyDDqTGpVR7jxeozoOEjH6SLaRdw0YY-HPQ"
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
                dictvenues in
                
                let newvenues = dictvenues.allKeys as! [String]
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
                    
                    
                    if updatedevents.count > 0 {
                        self.getAllYoutube(events: updatedevents, completion: {
                            finalevents in

                            let venues = [
                                "Jammin Java",
                                "Gypsy Sally's",
                                "9:30 Club",
                                "Baltimore Soundstage",
                                "Black Cat",
                                "Bottle and Cork",
                                "DC9 Nightclub",
                                "Flash",
                                "Fish Head Cantina",
                                "Hill Country DC",
                                "Horseshoe Casino",
                                "Live! Center Stage",
                                "Metro Gallery",
                                "Ottobar",
                                "Rams Head Dockside",
                                "Rams Head Live",
                                "Rams Head On Stage",
                                "Rams Head Tavern",
                                "Rock and Roll Hotel",
                                "Sixth & I Synagogue",
                                "Songbyrd Music House",
                                "Smokehouse Live",
                                "Soundcheck",
                                "The Hamilton",
                                "U Street Music Hall",
                                "Vinyl Lounge at Gypsy Sallys"
                            ]
                            let newfinalevents = finalevents.filter({ !venues.contains( $0.venuename!)})
                            completion(newfinalevents)
                            
                        })
                    } else {
                        completion([SeatGeekObject]())
                    }
                    
                    
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
    
    func getImagesForBand(band: String, completion: @escaping(String) -> Void) {
        let searchband = band.replacingOccurrences(of: " ", with: "+")
        let url = googleImagesURL + "&q=music"
        Alamofire.request(url).responseString(completionHandler: {
            response in
            print(response)
            print(response.result.value)
        })
    }
    
    func getYoutubeForBand(band: String, completion: @escaping(String) -> Void) {
        let searchband = band.replacingOccurrences(of: " ", with: "+")
        let url = youtubeURL + "&q=\(searchband)+music+band"
        Alamofire.request(url).responseJSON { response in
            if let result = response.result.value as? NSDictionary {
                if let answers = result["items"] as? [NSDictionary] {
                    if let itemsid = answers.first?["id"] as? NSDictionary {
                        if let youtubeid = itemsid["videoId"] as? String {
                            completion("https://www.youtube.com/watch?v=" + youtubeid)
                        }
                    }
                }
            }
        }
    }
    
    
}


class SeatGeekObject: Mappable {
    
    var stringDate: String?
    var URL: String?
    var name: String?
    var venuename: String?
    var imageURL: String?
    var genres = [String]()
    var address: String?
    var latitude: Float?
    var longitude: Float?
    var id: Int?
    var youtube: String?
    var venueExists: Bool?
    var date: Date?
    
    var bandname: String?
    var bandname2: String?
    var image1: String?
    var image2: String?
    var band1genre1: String?
    var band1genre2: String?
    var band1genre3: String?
    var band2genre1: String?
    var band2genre2: String?
    var band2genre3: String?
    var address1: String?
    var address2: String?
    var lowestprice: Float?
    
    func split() -> SeatGeekObject? {
        self.name = bandname
        self.imageURL = image1
        if let genre1 = band1genre1 {
            self.genres.append(genre1)
        }
        if let genre2 = band1genre2 {
            self.genres.append(genre2)
        }
        if let genre3 = band1genre3 {
            self.genres.append(genre3)
        }
        if let add1 = address1, let add2 = address2 {
            self.address = add1 + ", " + add2
        }
        if let stringDate = stringDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dateObj = dateFormatter.date(from: stringDate)
            self.date = dateObj
        }
        if let secondname = bandname2 {
            let newevent = SeatGeekObject(name: secondname)
            newevent.date = self.date
            newevent.id = id
            newevent.lowestprice = self.lowestprice
            newevent.URL = self.URL
            newevent.venuename = self.venuename
            newevent.imageURL = image2
            newevent.date = self.date
            if let genre1 = band2genre1 {
                newevent.genres.append(genre1)
            }
            if let genre2 = band2genre2 {
                newevent.genres.append(genre2)
            }
            if let genre3 = band2genre3 {
                newevent.genres.append(genre3)
            }
            newevent.address = self.address
            newevent.latitude = self.latitude
            newevent.longitude = self.longitude
            return newevent
        } else {
            return nil
        }
    }
    
    init(name: String) {
        self.name = name
    }
    
    required init?(map: Map) {
        
    }
    
    // Mappable
    func mapping(map: Map) {
        stringDate <- map["datetime_local"]
        URL <- map["performers.0.url"]
        id <- map["id"]
        image1 <- map["performers.0.image"]
        image2 <- map["performers.1.image"]
        bandname <- map["performers.0.short_name"]
        bandname2 <- map["performers.1.short_name"]
        band1genre1 <- map["performers.0.genres.0.name"]
        band1genre2 <- map["performers.0.genres.1.name"]
        band1genre3 <- map["performers.0.genres.2.name"]
        band2genre1 <- map["performers.1.genres.0.name"]
        band2genre2 <- map["performers.1.genres.1.name"]
        band2genre3 <- map["performers.1.genres.2.name"]
        lowestprice <- map["stats.lowest_price"]
        venuename <- map["venue.name_v2"]
        latitude <- map["venue.location.lat"]
        longitude <- map["venue.location.lon"]
        address1 <- map["venue.address"]
        address2 <- map["venue.extended_address"]
    }
    
}


protocol SeatGeekObjectDecisionProtocol {
    func didDeny(event: SeatGeekObject, index: Int)
    func didProceed(event: SeatGeekObject, index: Int)
    func didEdit(event: SeatGeekObject, index: Int)
}
