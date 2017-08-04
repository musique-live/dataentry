//
//  BandObject.swift
//  musique
//
//  Created by Tara Wilson on 1/10/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import ObjectMapper

class BandObject: NSObject, Mappable {
    var band: String?
    var descriptionString: String?
    var facebook: String?
    var image: String?
    var genre: String?
    var website: String?
    var youtube: String?
    var email: String?
    var region: String?
    var bandDescription: String?
    var ticketFlyID: Int?
    var instagram: String?
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func updateItems() {
        self.genre = genre?.capitalized
    }
    
    func mapping(map: Map) {
        band <- map["bandname"]
        descriptionString <- map["banddescription"]
        facebook <- map["bandfacebook"]
        image <- map["bandimage"]
        genre <- map["bandgenre"]
        website <- map["bandwebsite"]
        youtube <- map["bandyoutube"]
        descriptionString <- map["descriptionString"]
        facebook <- map["facebook"]
        image <- map["image"]
        genre <- map["genre"]
        website <- map["website"]
        youtube <- map["youtube"]
        region <- map["region"]
        
        updateItems()
    }
    
}
