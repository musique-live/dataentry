//
//  SearchResultsCollectionView.swift
//  musique
//
//  Created by Tara Wilson on 2/9/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation
import UserNotifications
import Accelerate

class ResultsVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate {
    
    var locValue = CLLocation(latitude: 39.00690000, longitude: -76.77900000)
    var events = [EventObject]()
    var collectionView: UICollectionView?

    var dateLabel: UILabel?
    var currentTimestamp: NSDate?
    var currentTimestampIndex: Int?


    var label: UILabel?


    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        setUpCollectionView()
        collectionView?.isHidden = true
        label?.isHidden = true
        
        getNewEvents()
        
    }
    
    func getNewEvents() {
        NetworkController().getAllEvents(completion: {
            result in
            self.events = result
            if self.events.count > 0 {
                self.collectionView?.isHidden = false
                self.collectionView?.reloadData()
                self.label?.isHidden = true
            } else {
                self.collectionView?.isHidden = true
                self.label?.isHidden = false
            }
        })
        
    }

    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "myFooterView", for: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    
    func goToTop() {
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    func setUpCollectionView() {
        if collectionView == nil {
            let dateHeader = UIView(frame: CGRect(x: 150, y: 110, width: view.frame.width - 300, height: 40))
            dateHeader.backgroundColor = UIColor.blue
            
            dateLabel = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width, height: 40))
            dateLabel?.textColor = .white
            dateLabel?.textAlignment = .left
            dateHeader.addSubview(dateLabel!)
            
            let topButton = UIButton(frame: CGRect(x: view.frame.width - 400, y: 0, width: 50, height: 40))
            topButton.setTitle("Top", for: .normal)
            topButton.addTarget(self, action: #selector(ResultsVC.goToTop), for: .touchUpInside)
            dateHeader.addSubview(topButton)
            
            let datelabelButton = UIButton(frame: CGRect(x: view.frame.width - 350, y: 0, width: 50, height: 40))
            datelabelButton.setImage(UIImage(named: "download")?.withRenderingMode(.alwaysTemplate), for: .normal)
            datelabelButton.imageView?.tintColor = .white
            datelabelButton.addTarget(self, action: #selector(ResultsVC.scrollToNextDate), for: .touchUpInside)
            dateHeader.addSubview(datelabelButton)
            
            view.addSubview(dateHeader)
            
            let layout = UltravisualLayout()
            collectionView = UICollectionView(frame: CGRect(x: 150, y: 150, width: view.frame.width - 300, height: view.frame.height - 180), collectionViewLayout: layout)
            
            guard let collectionView = collectionView else {
                return
            }
            
            if #available(iOS 10.0, *) {
                collectionView.isPrefetchingEnabled = false
            }
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            collectionView.register(EventCell.self, forCellWithReuseIdentifier: "InspirationCell")
            collectionView.register(UITableViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "myFooterView")
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.clear
            view.addSubview(collectionView)
            
        }
    }
    
}

extension ResultsVC {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func scrollToNextDate() {
        guard let collectionView = collectionView else {
            return
        }
        if let start = currentTimestampIndex {
            for index in start..<events.count {
                if events[index].timestamp?.compare(currentTimestamp! as Date) == .orderedDescending  {
                    
                    let layout = collectionView.collectionViewLayout as! UltravisualLayout
                    let offset = layout.dragOffset * CGFloat(index)
                    if collectionView.contentOffset.y != offset {
                        collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
                    }
                    
                    return
                }
            }
            let layout = collectionView.collectionViewLayout as! UltravisualLayout
            let offset = layout.dragOffset * CGFloat(events.count - 1) + 50
            if collectionView.contentOffset.y != offset {
                collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InspirationCell", for: indexPath as IndexPath) as! EventCell
        
        cell.event = events[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let formatter = DateFormatter()
        formatter.dateFormat = "E MMM dd"
        
        if currentTimestamp == nil {
            if let date = events[0].timestamp {
                currentTimestamp = date
                dateLabel?.text = formatter.string(from: date as Date)
                currentTimestampIndex = 0
            }
        }
        
        var numless = 2
        if UIScreen.main.bounds.width < 321 {
            numless = 0
        }
        let size = UIApplication.shared.preferredContentSizeCategory
        if size == .large || size == .extraLarge || size == .extraExtraLarge || size == .extraExtraExtraLarge {
            numless = 0
        }
        
        if indexPath.item > numless {
            if events[indexPath.item - numless].timestamp != currentTimestamp {
                if let date = events[indexPath.item - numless].timestamp {
                    currentTimestamp = date
                    
                    dateLabel?.text = formatter.string(from: date as Date)
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "DELETE", message: "Are you sure you want to delete this?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {
            handle in
            NetworkController().deleteEvent(event: self.events[indexPath.row])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
            handle in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    

}

/* The heights are declared as constants outside of the class so they can be easily referenced elsewhere */
struct UltravisualLayoutConstants {
    struct Cell {
        /* The height of the non-featured cell */
        static let standardHeight: CGFloat = 150
        /* The height of the first visible cell */
        static let featuredHeight: CGFloat = 380
    }
}

class UltravisualLayout: UICollectionViewLayout {
    
    // MARK: Properties and Variables
    
    /* The amount the user needs to scroll before the featured cell changes */
    let dragOffset: CGFloat = 280.0
    
    var cache = [UICollectionViewLayoutAttributes]()
    
    /* Returns the item index of the currently featured cell */
    var featuredItemIndex: Int {
        get {
            /* Use max to make sure the featureItemIndex is never < 0 */
            return max(0, Int(collectionView!.contentOffset.y / dragOffset))
        }
    }
    
    /* Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell */
    var nextItemPercentageOffset: CGFloat {
        get {
            return (collectionView!.contentOffset.y / dragOffset) - CGFloat(featuredItemIndex)
        }
    }
    
    /* Returns the width of the collection view */
    var width: CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    
    /* Returns the height of the collection view */
    var height: CGFloat {
        get {
            return collectionView!.bounds.height
        }
    }
    
    /* Returns the number of items in the collection view */
    var numberOfItems: Int {
        get {
            return collectionView!.numberOfItems(inSection: 0)
        }
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            let contentHeight = (CGFloat(numberOfItems) * dragOffset) + (height - dragOffset)
            return CGSize(width: width, height: contentHeight)
        }
    }
    
    override func prepare() {
        super.prepare()
        cache.removeAll(keepingCapacity: false)
        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
        
        var frame = CGRect.zero
        var y: CGFloat = 0
        
        
        for item in 0..<numberOfItems {
            // 1
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath as IndexPath)
            // 2
            attributes.zIndex = item
            var height = standardHeight
            
            // 3
            if indexPath.item == featuredItemIndex {
                // 4
                let yOffset = standardHeight * nextItemPercentageOffset
                y = collectionView!.contentOffset.y - yOffset
                height = featuredHeight
            } else if indexPath.item == (featuredItemIndex + 1) && indexPath.item != numberOfItems {
                // 5
                let maxY = y + standardHeight
                height = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
                y = maxY - height
            }
            
            // 6
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            y = frame.maxY
        }
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    /* Return true so that the layout is continuously invalidated as the user scrolls */
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return UICollectionViewLayoutAttributes()
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        let itemIndex = round(proposedContentOffset.y / dragOffset)
        let yOffset = itemIndex * dragOffset
        return CGPoint(x: 0, y: yOffset)
    }
    
}


class EventCell: UICollectionViewCell {
    
    var imageView = UIImageView()
    var imageCoverView = UIView()
    var labelblur = UIImageView()
    var label = UILabel()
    var location = UILabel()
    var distance = UILabel()
    var date = UILabel()
    var genre = UILabel()
    
    var event: EventObject? {
        didSet {
            if let image = event?.band?.image {
                imageView.sd_setImage(with: URL(string: image), completed: {
                    completion in
                })
            }
            if let band = event?.band?.name {
                label.text = band.capitalized
            }
            if let loc = event?.venue?.venue {
                location.text = loc
            }
            if let dist = event?.distance {
                let miles = dist / 1609.344
                distance.text = " \(Int(miles)) miles away "
            }
            if let newdate = event?.timestamp {
                let fm = DateFormatter()
                fm.dateFormat = "MMM dd"
                date.text = fm.string(from: newdate as Date)
                if let time = event?.time, let text = date.text {
                    date.text = text + ", \(time)"
                }
            }
            if let bandgenre = event?.band?.genre {
                genre.text = bandgenre
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        contentView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        imageCoverView.translatesAutoresizingMaskIntoConstraints = false
        imageCoverView.backgroundColor = UIColor.black
        imageView.addSubview(imageCoverView)
        imageView.addConstraints([
            NSLayoutConstraint(item: imageCoverView, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageCoverView, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageCoverView, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageCoverView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        contentView.addSubview(label)
        contentView.addConstraints([
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 80)
            ])
        
        location.translatesAutoresizingMaskIntoConstraints = false
        location.textAlignment = .center
        location.textColor = UIColor.white
        location.adjustsFontSizeToFitWidth = true
        contentView.addSubview(location)
        contentView.addConstraints([
            NSLayoutConstraint(item: location, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: location, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: location, attribute: .top, relatedBy: .equal, toItem: label, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        date.translatesAutoresizingMaskIntoConstraints = false
        date.textAlignment = .center
        date.textColor = UIColor.white
        date.adjustsFontSizeToFitWidth = true
        contentView.addSubview(date)
        contentView.addConstraints([
            NSLayoutConstraint(item: date, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: date, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: date, attribute: .top, relatedBy: .equal, toItem: location, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        distance.translatesAutoresizingMaskIntoConstraints = false
        distance.textAlignment = .center
        distance.textColor = UIColor.white
        distance.adjustsFontSizeToFitWidth = true
        contentView.addSubview(distance)
        contentView.addConstraints([
            NSLayoutConstraint(item: distance, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: distance, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: distance, attribute: .top, relatedBy: .equal, toItem: date, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
        genre.translatesAutoresizingMaskIntoConstraints = false
        genre.textAlignment = .center
        genre.textColor = UIColor.white
        genre.adjustsFontSizeToFitWidth = true
        contentView.addSubview(genre)
        contentView.addConstraints([
            NSLayoutConstraint(item: genre, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: genre, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: genre, attribute: .top, relatedBy: .equal, toItem: distance, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let standardHeight = UltravisualLayoutConstants.Cell.standardHeight
        let featuredHeight = UltravisualLayoutConstants.Cell.featuredHeight
        
        let delta = 1 - ((featuredHeight - frame.height) / (featuredHeight - standardHeight))
        
        let minAlpha: CGFloat = 0.1
        let maxAlpha: CGFloat = 0.65
        imageCoverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        
        let scale = max(delta, 0.5)
        label.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        location.alpha = delta
        distance.alpha = delta
        date.alpha = delta
        genre.alpha = delta
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = ""
        location.text = ""
        distance.text = ""
        date.text = ""
        genre.text = ""
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

