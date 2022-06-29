//
//  UsersViewController.swift
//  Shwing
//
//  Created by shy attoun on 20/09/2019.
//  Copyright © 2019 shy attoun. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseCore
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FBSDKShareKit
import FBSDKCoreKit
import MessageUI
import Lottie

class UsersViewController: UITableViewController,UISearchResultsUpdating {

    let userDefault = UserDefaults.standard
    var users = [User] ()
    var searchController: UISearchController = UISearchController (searchResultsController: nil)
    var searchResults : [User] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
        setupSearchBarController ()
        setupNavigationBar()
        fetchUsers ()
        setupTableView ()
    }

    
    func setupTableView () {
        tableView.tableFooterView = UIView ()
    }
    
    
    
    func setupSearchBarController () {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
     searchController.searchBar.placeholder = "Search users..."
        searchController.searchBar.barTintColor = UIColor.white
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
    func  setupNavigationBar() {
        navigationItem.title = "People"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        let iconView = UIImageView(image: UIImage(named: "icon_top"))
        iconView.contentMode = .scaleAspectFit
        navigationItem.titleView = iconView
        
        let location = UIBarButtonItem(image: UIImage(named: "icon-location"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(locationDidTapped))
        navigationItem.leftBarButtonItem = location
        
        let buisness = UIBarButtonItem(image: UIImage(named: "buisness"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(buisnessDidTapped))
        navigationItem.rightBarButtonItem = buisness
    }
    @objc func buisnessDidTapped() {
        // switch to UsersAroundVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let buisnessVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_BUISNESS_AROUND) as! BuisnessLocationViewController
        
        self.navigationController?.pushViewController(buisnessVC, animated: true)
        
    }
    @objc func locationDidTapped() {
        // switch to UsersAroundVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let usersAroundVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_USER_AROUND) as! UsersAroundViewController
        
        self.navigationController?.pushViewController(usersAroundVC, animated: true)
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == nil || searchController.searchBar.text!.isEmpty {
            view.endEditing(true)
        } else {
            let textLowercased = searchController.searchBar.text!.lowercased()
            filterContent(for: textLowercased)
        }
        tableView.reloadData()
    }
    
    func filterContent (for searchText: String){
        searchResults = self.users.filter{
            return $0.fullname.lowercased().range(of: searchText) != nil
        }
    }
    
    func fetchUsers () {
        let rootRef = Database.database().reference()
        let query = rootRef.child(REF_USER)
        
        query.observe(.childAdded){(snapshot) in
            
            //            print(snapshot.value!)
            if let dict = snapshot.value as? Dictionary <String , Any> {
                print(dict)
                
                if let user = User.transformUser(dict: dict){
                    
                    self.users.append(user)
                    
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            return searchResults.count
        } else {
            return self.users.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: IDENTIFIER_CELL_USERS,for: indexPath) as! UserTableViewCell
        
        let user = searchController.isActive ? searchResults[indexPath.row] : users[indexPath.row]
        cell.delegate = self
        cell.loadData(user)
     
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? UserTableViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatVC = storyboard.instantiateViewController(withIdentifier: IDENTIFIER_CHAT) as! ChatViewController
            chatVC.imagePartner = cell.avatar.image
            chatVC.partnerUserName = cell.fullnameLbl.text
            chatVC.partnerId = cell.user.uid
            chatVC.partnerUser = cell.user
            self.navigationController?.pushViewController(chatVC,animated: true)
        }
    }
}
extension UsersViewController: UpdateTableProtocol {
    func reloadData() {
        self.tableView.reloadData()
    }
}
