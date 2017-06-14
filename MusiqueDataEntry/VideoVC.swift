//
//  VideoVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 6/13/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit
import XCDYouTubeKit

class VideoVC: UIViewController {
    
    var youtube: String?
    var player: XCDYouTubeVideoPlayerViewController?
    
    override func viewDidLoad() {
        if let youtube = self.youtube {
            let ytView = UIView(frame: CGRect(x: 100, y: 100, width: view.frame.width - 200, height: view.frame.width - 200))
            view.addSubview(ytView)
            player = XCDYouTubeVideoPlayerViewController(videoIdentifier: youtube)
            guard let player = player else {return}
            player.present(in: ytView)
            player.moviePlayer.shouldAutoplay = false
            player.moviePlayer.isFullscreen = false
            player.moviePlayer.prepareToPlay()
        }
        
    }
    
}
