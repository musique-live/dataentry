//
//  BandObject.swift
//  
//
//  Created by Tara Wilson on 4/20/17.
//
//

import Foundation

class BandObject: NSObject {
    var name: String?
    var email: String?
    var facebook: String?
    var image: String?
    var genre: String?
    var website: String?
    var youtube: String?
    var region: String?
    var bandDescription: String?
    
    init(name: String) {
        self.name = name
    }
    
    init(band: String?, descriptionString: String?, facebook: String?, image: String?, genre: String?, website: String?, youtube: String?) {
        self.name = band
        self.bandDescription = descriptionString
        self.facebook = facebook
        self.image = image
        self.genre = genre
        self.website = website
        self.youtube = youtube
    }
}
