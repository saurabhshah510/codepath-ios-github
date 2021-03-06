//
//  ViewController.swift
//  GithubDemo
//
//  Created by Nhan Nguyen on 5/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var searchBar: UISearchBar!
    var searchSettings = GithubRepoSearchSettings()
    var fetchedRepos:[GithubRepo] = []

    @IBOutlet weak var reposTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // add search bar to navigation bar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        doSearch()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return fetchedRepos.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoCell", forIndexPath: indexPath) as! RepoTableViewCell
        if fetchedRepos.count > 0{
            cell.descriptionLabel.text = self.fetchedRepos[indexPath.row].description!
            cell.ownerLabel.text = self.fetchedRepos[indexPath.row].ownerHandle!
            cell.starsLabel.text = "\(self.fetchedRepos[indexPath.row].stars!)"
            cell.forkLabel.text = "\(self.fetchedRepos[indexPath.row].forks!)"
            cell.repoNameLabel.text = self.fetchedRepos[indexPath.row].name!
            let url = NSURL(string: self.fetchedRepos[indexPath.row].ownerAvatarURL!)!
            let request = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                    if error == nil {
                        let image = UIImage (data: data!)
                        cell.avatarImageView.image = image
                    }
                }
            }
        return cell
    }
    
    
    private func doSearch() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        GithubRepo.fetchRepos(searchSettings, successCallback: { (repos) -> Void in
            self.fetchedRepos = repos

//            for repo in repos {
//                print("[Name: \(repo.name!)]" +
//                    "\n\t[Stars: \(repo.stars!)]" +
//                    "\n\t[Forks: \(repo.forks!)]" +
//                    "\n\t[Owner: \(repo.ownerHandle!)]" +
//                    "\n\t[Avatar: \(repo.ownerAvatarURL!)] \n\t[Description: \(repo.description!)]")
//                fetchedRepos.append(repo)
//            }
            self.reposTableView.reloadData()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }, error: { (error) -> Void in
            print(error)
        })
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchSettings.searchString = searchBar.text
        searchBar.resignFirstResponder()
        doSearch()
    }
}