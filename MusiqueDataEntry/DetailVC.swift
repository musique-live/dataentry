//
//  DetailVC.swift
//  musique
//
//  Created by Tara Wilson on 6/23/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit
import Accelerate
import XCDYouTubeKit
import MapKit
import Firebase

class DetailVC: UIViewController {
    
    var event: EventObject?
    var image: UIImage?
    var shareImage: UIImage?
    var player: XCDYouTubeVideoPlayerViewController?
    var scrollView: UIScrollView!
    var links = [String]()
    var reservationNum: Int?
    
    let firstvalues = [280, 320, 345, 370, 395, 440, 435, 455, 455, 780]
    let yvalues = [320, 360, 380, 400, 420, 465, 460, 475, 480, 500, 540]
    
    let actIndView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        guard let event = event else { return }
        guard let venue = event.venue?.venue else { return }
        guard let band = event.band?.band else { return }
        
        FIRAnalytics.logEvent(withName: "viewed_\(cleanFBString(string: band))", parameters: nil)
        FIRAnalytics.logEvent(withName: "viewed_\(cleanFBString(string: venue))", parameters: nil)
        FIRAnalytics.logEvent(withName: "viewed_\(cleanFBString(string: event.id ?? ""))", parameters: nil)
        
        let imageview = UIImageView(frame: view.frame)
        imageview.image = self.image
        imageview.addBlurEffect()
        imageview.alpha = 0
        view.addSubview(imageview)
        
        scrollView = UIScrollView(frame: view.frame)
        view.addSubview(scrollView)
        
        let nameView = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width - 40, height: 50))
        nameView.numberOfLines = 2
        nameView.adjustsFontSizeToFitWidth = true
        nameView.textColor = UIColor.white
        scrollView.addSubview(nameView)
        nameView.alpha = 0.3
        if let band = event.band?.band, let venue = event.venue?.venue {
            nameView.text = ("\(band)" + " at " + "\(venue)").uppercased()
        }
        
        let ytView = UIView(frame: CGRect(x: view.frame.width/2 - 210/2, y: 50, width: 210, height: 210))
        
        if let youtube = event.band?.youtube {
            scrollView.addSubview(ytView)
            player = XCDYouTubeVideoPlayerViewController(videoIdentifier: youtube)
            guard let player = player else {return}
            player.present(in: ytView)
            player.moviePlayer.shouldAutoplay = false
            player.moviePlayer.isFullscreen = false
            player.moviePlayer.prepareToPlay()
        }
        
        let close = UIButton(frame: CGRect(x: view.frame.width - 40, y: 10, width: 30, height: 30))
        close.setImage(UIImage(named: "close-button"), for: .normal)
        close.backgroundColor = .white
        close.addTarget(self, action: #selector(DetailVC.close), for: .touchUpInside)
        scrollView.addSubview(close)
        
        let tickets = UIButton(frame: CGRect(x: 20, y: firstvalues[0], width: Int(view.frame.width - 40), height: 50))
        tickets.backgroundColor = .blue
        tickets.layer.borderWidth = 2
        tickets.layer.borderColor = UIColor.white.cgColor
        tickets.setTitleColor(UIColor.white, for: .normal)
        scrollView.addSubview(tickets)
        if event.ticketURL != nil {
            tickets.setTitle("GET TICKETS", for: .normal)
            tickets.addTarget(self, action: #selector(DetailVC.getTickets), for: .touchUpInside)
        } else {
            tickets.setTitle("RESERVE", for: .normal)
        }
        
        let date = UILabel(frame: CGRect(x: 20, y: firstvalues[1], width: Int(view.frame.width - 40), height: 50))
        date.numberOfLines = 2
        date.adjustsFontSizeToFitWidth = true
        date.textColor = UIColor.white
        scrollView.addSubview(date)
        date.alpha = 0.3
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        if let eventdate = event.timestamp {
            date.text = dateFormatter.string(from: eventdate as Date)
        }
        
        let time = UILabel(frame: CGRect(x: 20, y: firstvalues[2], width: Int(view.frame.width - 40), height: 50))
        time.adjustsFontSizeToFitWidth = true
        time.textColor = UIColor.white
        scrollView.addSubview(time)
        time.alpha = 0.3
        if let eventtime = event.time {
            time.text = eventtime
        }
        
        let genre = UILabel(frame: CGRect(x: 20, y: firstvalues[3], width: Int(view.frame.width - 40), height: 50))
        genre.adjustsFontSizeToFitWidth = true
        genre.textColor = UIColor.white
        scrollView.addSubview(genre)
        genre.alpha = 0.3
        if let eventgenre = event.band?.genre, !eventgenre.isEmpty {
            genre.text = eventgenre
        } else {
            genre.text = "Rock"
        }
        
        let price = UILabel(frame: CGRect(x: 20, y: firstvalues[4], width: Int(view.frame.width - 40), height: 50))
        price.adjustsFontSizeToFitWidth = true
        price.textColor = UIColor.white
        scrollView.addSubview(price)
        price.alpha = 0.3
        if let eventprice = event.price {
            if eventprice == 0 {
                price.text = "Free"
            } else {
                price.text = "$\(eventprice)"
            }
        } else {
            price.text = "Contact venue for price information"
        }
        
        let lineone = UIView(frame: CGRect(x: 20, y: firstvalues[5], width: Int(view.frame.width - 40), height: 2))
        lineone.backgroundColor = UIColor.white
        
        let linetwo = UIView(frame: CGRect(x: 20, y: firstvalues[6], width: Int(view.frame.width - 40), height: 2))
        linetwo.backgroundColor = UIColor.white
        
        
        var extraheight = 500
        let descripLabel = UILabel()
        if let descrip = event.band?.bandDescription, !descrip.isEmpty {
            descripLabel.frame = CGRect(x: 20, y: 380, width: view.frame.width - 40, height: 50)
            descripLabel.numberOfLines = 0
            descripLabel.textColor = UIColor.white
            scrollView.addSubview(descripLabel)
            descripLabel.alpha = 0.3
            descripLabel.text = descrip
            
            scrollView.addSubview(lineone)
            scrollView.addSubview(linetwo)
        }
        
        
        
        let distance = UILabel(frame: CGRect(x: 20, y: firstvalues[7], width: Int(view.frame.width - 40), height: 50))
        distance.adjustsFontSizeToFitWidth = true
        distance.textColor = UIColor.white
        scrollView.addSubview(distance)
        distance.alpha = 0.3
        if let eventdist = event.distance {
            let miles = eventdist / 1609.344
            distance.text = "\(Int(miles))" + " miles away"
        }
        
        let address = UILabel(frame: CGRect(x: 20, y: firstvalues[8], width: Int(view.frame.width - 40), height: 50))
        address.adjustsFontSizeToFitWidth = true
        address.textColor = UIColor.white
        scrollView.addSubview(address)
        address.alpha = 0.3
        if let eventaddress = event.venue?.address {
            address.text = eventaddress
        }
        
        let mapView = MKMapView()
        mapView.mapType = .standard
        
        if let coordinates = event.venue?.coordinates {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinates.coordinate
            annotation.title = event.venue?.venue ?? "Event"
            mapView.addAnnotation(annotation)
            mapView.selectAnnotation(annotation, animated: false)
            
            let span = MKCoordinateSpanMake(0.075, 0.075)
            let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            imageview.alpha = 1
        }, completion: {
            complete in
            UIView.animate(withDuration: 0.2, delay: 0.05, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                nameView.alpha = 1
                nameView.frame = CGRect(x: 20, y: 40, width: self.view.frame.width - 40, height: 50)
                ytView.frame = CGRect(x: self.view.frame.width/2 - 210/2, y: 100, width: 210, height: 210)
                tickets.frame = CGRect(x: 20, y: self.yvalues[0], width: Int(self.view.frame.width - 40), height: 40)
                date.frame = CGRect(x: 20, y: self.yvalues[1], width: Int(self.view.frame.width - 40), height: 40)
                date.alpha = 1
                time.frame = CGRect(x: 20, y: self.yvalues[2], width: Int(self.view.frame.width - 40), height: 40)
                time.alpha = 1
                genre.frame = CGRect(x: 20, y: self.yvalues[3], width: Int(self.view.frame.width - 40), height: 40)
                genre.alpha = 1
                price.frame = CGRect(x: 20, y: self.yvalues[4], width: Int(self.view.frame.width - 40), height: 40)
                price.alpha = 1
                descripLabel.frame = CGRect(x: 20, y: self.yvalues[5], width: Int(self.view.frame.width - 40), height: extraheight + 10)
                descripLabel.alpha = 1
                lineone.frame = CGRect(x: 20, y: self.yvalues[6], width: Int(self.view.frame.width - 40), height: 2)
                linetwo.frame = CGRect(x: 20, y: self.yvalues[7] + extraheight, width: Int(self.view.frame.width - 40), height: 2)
                
                extraheight = extraheight + 20
                distance.frame = CGRect(x: 20, y: self.yvalues[8] + extraheight, width: Int(self.view.frame.width - 40), height: 40)
                distance.alpha = 1
                address.frame = CGRect(x: 20, y: self.yvalues[9] + extraheight, width: Int(self.view.frame.width - 40), height: 40)
                mapView.frame = CGRect(x: 20, y: self.yvalues[10] + extraheight, width: Int(self.view.frame.width - 40), height: 200)
                address.alpha = 1
                close.alpha = 0.7
            }, completion: {
                complete in
                self.scrollView.addSubview(mapView)
            })
        })
        
        var linknames = [String]()
        
        if let venue = event.venue?.venue, let band = event.band?.band {
            if let yelp = event.venue?.yelp, !yelp.isEmpty {
                links.append(yelp)
                linknames.append("\(venue) Yelp")
            }
            if let web = event.venue?.website, !web.isEmpty {
                links.append(web)
                linknames.append("\(venue) Website")
            }
            if let bandweb = event.band?.website, !bandweb.isEmpty {
                links.append(bandweb)
                linknames.append("\(band) Website")
            }
            if let fb = event.band?.facebook, !fb.isEmpty {
                links.append(fb)
                linknames.append("\(band) Facebook")
            }
        }
        
        for (i,_) in links.enumerated() {
            let linkstring = UILabel(frame: CGRect(x: 20, y: firstvalues[9] + extraheight + (i*50), width: Int(view.frame.width - 80), height: 50))
            linkstring.numberOfLines = 0
            linkstring.lineBreakMode = .byWordWrapping
            linkstring.textColor = .blue
            linkstring.text = linknames[i]
            scrollView.addSubview(linkstring)
            
            let linkImage = UIImageView(frame: CGRect(x: Int(view.frame.width - 50), y: firstvalues[9] + 25/2 + extraheight + (i*50), width: 25, height: 25))
            linkImage.image = UIImage(named: "external-link-symbol.png")
            scrollView.addSubview(linkImage)
            
            let button = UIButton(frame: CGRect(x: 0, y: firstvalues[9] + extraheight + (i*50), width: Int(view.frame.width), height: 30))
            button.addTarget(self, action: #selector(openLink), for: .touchUpInside)
            button.tag = i
            scrollView.addSubview(button)
        }
        
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 500 + CGFloat(extraheight) + CGFloat(50 * links.count - 1))
        let buttonsize: Int = Int((view.frame.width - 60)/2.0)
        
        
        actIndView.frame = view.frame
    }
    
    func openLink(button: UIButton) {
        if let url = URL(string: links[button.tag]) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            } else {
                let newurl = "http://www." + links[button.tag]
                UIApplication.shared.openURL(URL(string: newurl)!)
            }
        }
    }
    
    func getTickets() {
        if let url = URL(string: event?.ticketURL ?? "") {
            UIApplication.shared.openURL(url)
        }
    }
    
    func close() {
        player?.moviePlayer.stop()
        self.dismiss(animated: true, completion: nil)
    }
    
    func parseYoutubeString(ytString: String) -> String {
        let newstring = ytString.replacingOccurrences(of: "&list", with: "")
        var vars = newstring.characters.split(separator: "=").map(String.init)
        if vars.count < 2 {
            vars = ytString.characters.split(separator: "/").map(String.init)
            if vars.count > 2 {
                return vars[2]
            }
        } else {
            return vars[1]
        }
        return ""
    }
    
    func cleanFBString(string: String) -> String {
        //special version without space
        var newstring = string.replacingOccurrences(of: ".", with: "")
        newstring = newstring.replacingOccurrences(of: "#", with: "")
        newstring = newstring.replacingOccurrences(of: "$", with: "")
        newstring = newstring.replacingOccurrences(of: "[", with: "")
        newstring = newstring.replacingOccurrences(of: "]", with: "")
        newstring = newstring.replacingOccurrences(of: " ", with: "")
        newstring = newstring.replacingOccurrences(of: "'", with: "")
        newstring = newstring.replacingOccurrences(of: "&", with: "")
        newstring = newstring.replacingOccurrences(of: "-", with: "_")
        //make this 32 chars?
        return newstring
    }
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
        
    }
    
}
