//
//  AllBandsVenuesVC.swift
//  MusiqueDataEntry
//
//  Created by Tara Wilson on 8/23/17.
//  Copyright © 2017 twil. All rights reserved.
//

import Foundation
import UIKit

class AllBandsVenuesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var venues: [String]?
    var bands: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        
        let actind = UIActivityIndicatorView(frame: view.frame)
        actind.backgroundColor = UIColor.darkGray
        
        navigationController?.navigationBar.isHidden = true
        
        NetworkController().getVenuesList(completion:  {
            venues in
            let newvenues = venues.allKeys as! [String]
            self.venues = newvenues.sorted()
            
            NetworkController().getBandObjectsList(completion: {
                bands in
                self.bands = bands.sorted()
                actind.stopAnimating()
                self.tableView.reloadData()
            })
            
        })
        
        let menuButton = UIButton(frame: CGRect(x: 30, y: 20, width: 100, height: 50))
        menuButton.setTitle("MENU", for: .normal)
        menuButton.setTitleColor(.white, for: .normal)
        menuButton.addTarget(self, action: "openMenu", for: .touchUpInside)
        view.addSubview(menuButton)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 90, width: view.frame.width, height: view.frame.height - 90))
        tableView.delegate = self
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(ToDoList.refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresh
        }
        tableView.dataSource = self
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(actind)
        actind.startAnimating()
    }
    
    
    func refresh() {
        
        NetworkController().getVenuesList(completion:  {
            venues in
            self.venues = venues.allKeys as! [String]
            
            NetworkController().getBandObjectsList(completion: {
                bands in
                self.bands = bands
                
                if #available(iOS 10.0, *) {
                    self.tableView.refreshControl?.endRefreshing()
                }
                self.tableView.reloadData()
            })
            
        })

    }
    
    
    
    func openMenu() {
        self.slideMenuController()?.openLeft()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return venues?.count ?? 0
        }
        if section == 1 {
            return bands?.count ?? 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = venues![indexPath.row]
        }
        if indexPath.section == 1 {
            cell.textLabel?.text = bands![indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Venues"
        }
        if section == 1 {
            return "Bands"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}
