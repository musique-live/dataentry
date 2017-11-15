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
import Alamofire

let database = "https://musiquelive-2167e.firebaseio.com/"
let yelpclientid = "xNWMinRpWtYPu1c1SA28xA"
let yelpsecret = "joxqtrACR9pH9BE3ACp3gEZ1tSNgf41iJlmdfZJnQbsoKigNCWJsdGZSU73L8xFS"
let youtubeURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&key=AIzaSyDDqTGpVR7jxeozoOEjH6SLaRdw0YY-HPQ"

class NetworkController: NSObject {
    
    let geocoder = CLGeocoder()
    var myGroup = DispatchGroup()
    
    func getAllOldEvents() {
        let olddate = String(NSDate().addingTimeInterval(86400 * -7).timeIntervalSince1970)
        let ref = FIRDatabase.database().reference()
        var querystring = "/DC/Events"

        let query = ref.child(querystring).queryOrdered(byChild: "date").queryEnding(atValue: olddate).queryLimited(toFirst: 1000)
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                self.processEventSnapshot(snapArray: snapshot, completion: {
                    newevents in
                    for event in newevents {
                        self.justEventDelete(event: event)
                    }
                })
            }
        }, withCancel: {
            (error) in
        })
    }
    
    func restructure() {
        let query = FIRDatabase.database().reference().child("DC/Bands").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let keys = val.allKeys as! [String]
                self.sendList(venues: keys)
            }
        }, withCancel: {
            (error) in
        })
    }
    
    func sendList(venues: [String]) {
        for place in venues {
            let newEventRef = FIRDatabase.database().reference()
                .child("/DC/AllBands/\(place)")
            
            newEventRef.setValue(true)
        }
    }
    
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

    func getEventsFor(band: String?, venue: String?, completion: @escaping(([EventObject]) -> Void)) {
        let currentdate = String(NSDate().timeIntervalSince1970)
        var querystring = "/DC/Events"
        
        if let band = band {
            querystring = "DC/Bands/\(band)/Events"
        } else if let venue = venue {
            querystring = "DC/Venues/\(venue)/Events"
        }
        
        let ref = FIRDatabase.database().reference()
        
        let query = ref.child(querystring).queryOrdered(byChild: "date").queryStarting(atValue: currentdate)
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
    
    func justEventDelete(event: EventObject) {
        if let id = event.id {
            if let stamp = event.timestamp?.timeIntervalSince1970 {
                if stamp < TimeInterval(1507100000) {
                    print(stamp)
                    print(id)
                    let query = FIRDatabase.database().reference().child("DC/Events/\(id)")
                    query.removeValue()
                }
            }
        }
    }
    
    func deleteEvent(event: EventObject) {
        guard let id = event.id, let band = event.band?.band, let venue = event.venue?.venue else { return }
        
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
                self.getOwnerForVenue(venues: keys.sorted(), completion: {
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

    func getOwnerForVenue(venues: [String], completion: @escaping((NSDictionary) -> Void)) {
        let returndict = NSMutableDictionary()
        
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
    
    func getIdsListForVenueEvents(venue: String, completion: @escaping (([String]) -> Void)) {
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
    
    func getBandInfo(band: String, completion: @escaping (BandObject) -> Void) {
        let query = FIRDatabase.database().reference().child("DC/Bands/\(cleanFBString(string: band))/info")
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                let newband = BandObject(JSON: val as! [String : Any])
                newband?.band = band
                completion(newband!)
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
                }
            }
        }
        completion(events)
        
    }
    
    func processEvent(newObject: NSDictionary, key: String) -> EventObject {
        let event = EventObject(JSON: newObject as! [String : Any])
        event?.band = BandObject(JSON: newObject as! [String : Any])
        if let bandname = newObject["bandname"] as? String {
            event?.band?.band = bandname
        }
        event?.venue = VenueObject(JSON: newObject as! [String : Any])
        if let venuename = newObject["venuename"] as? String {
            event?.venue?.venue = venuename
        }
        return event!
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
                        } else {
                            completion("")
                        }
                    } else {
                        completion("")
                    }
                } else {
                    completion("")
                }
            } else {
                completion("")
            }
        }
    }
    
    func getBandForString(band: String, completion: @escaping ((BandObject?) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Bands/\(cleanFBString(string: band))")
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            print(snapshot.value)
            if let dict = snapshot.value as? NSDictionary {
                if let infodict = dict["info"] as? NSDictionary {
                    let newband = BandObject(JSON: infodict as! [String : Any])
                    newband?.band = band
                    completion(newband)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }, withCancel: {
            error in
            print(error)
            completion(nil)
        })
    }
    
    func getVenueForString(venue: String, completion: @escaping ((VenueObject?) -> Void)) {
        let newquery = FIRDatabase.database().reference().child("DC/Venues/\(cleanFBString(string: venue))")
        newquery.observeSingleEvent(of: .value, with: {
            snapshot in
            if let newObject = snapshot.value as? NSDictionary {
                if let infodict = newObject["info"] as? NSDictionary {
                    let newven = VenueObject(JSON: infodict as! [String : Any])
                    newven?.venue = venue
                    completion(newven)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }, withCancel: {
            error in
            completion(nil)
        })
    }
    
    func getAllBandEvents(band: BandObject, completion: @escaping ([String]) -> Void) {
        let query = FIRDatabase.database().reference().child("DC/Bands/\(cleanFBString(string: band.band!))/Events").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                completion(val.allKeys as! [String])
            } else {
                completion([])
            }
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
    
    func getAllEmails() {
        let query = FIRDatabase.database().reference().child("DC/Bands").queryOrderedByKey()
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            if let val = snapshot.value as? NSDictionary {
                if let keys = val.allKeys as? [String] {
                    for key in keys {
                        if let object = val[key] as? NSDictionary {
                            if let infodict = object["info"] as? NSDictionary {
                                if let email = infodict["email"] as? String, !email.isEmpty {
                                    print(email + " : " + "\(key)")
                                }
                            }
                            if let email = object["email"] as? String, !email.isEmpty {
                                print(email + " : " + "\(key)")
                            }
                        }
                    }
                }
            }
        }, withCancel: {
            (error) in
        })
    }
    
    func getFBFromBand(val: String, completion: @escaping ((String?) -> Void)) {
        let query = FIRDatabase.database().reference().child("DC/Bands/\(val)/info/facebook")
        query.observeSingleEvent(of: .value, with: {
            snapshot in
            print(snapshot.value)
            if let fbstring = snapshot.value as? String {
                let newstring = fbstring.replacingOccurrences(of: "https://www.facebook.com/", with: "")
                completion(newstring.replacingOccurrences(of: "/", with: ""))
            } else {
                completion(nil)
            }
        }, withCancel: {
            success in
            completion(nil)
        })
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

    
    
  
