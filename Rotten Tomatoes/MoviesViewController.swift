//
//  ViewController.swift
//  Rotten Tomatoes
//
//  Created by Sahil Arora on 9/11/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
                            
    @IBOutlet weak var movieSearchBar: UISearchBar!
    @IBOutlet weak var networkBannerView: UIView!
    @IBOutlet weak var moviesTableView: UITableView!
    var movies: [NSDictionary] = []
        
    var refreshControl:UIRefreshControl!  // An optional variable
    
    var imageCache = NSMutableDictionary()
    
    var isConn: Bool = false {
        willSet(isConn) {
            println("set \(isConn)")
            if isConn {
                getMovieList(false)
            }
        }
        didSet {

        }
    }
    
    var isConnSearch: Bool = false {
        willSet(isConnSearch) {
            println("set \(isConn)")
            if isConnSearch {
                getMovieList(true)
            }
        }
        didSet {
            
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        println("tab: \(self.tabBarController.selectedIndex)")

        if self.tabBarController.selectedIndex == 0 {
            //self.navigationController.title = "Movies"
        } else {
            //self.navigationController.title = "DVDs1"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Search bar controls
        movieSearchBar.showsScopeBar = true
        movieSearchBar.delegate = self
        
        //Set search bar colors
        //self.movieSearchBar.barTintColor = UIColor.blackColor()
        //self.movieSearchBar.alpha = 0.55
        //self.movieSearchBar.tintColor = UIColor.blackColor()
        //self.movieSearchBar.inputView.tintColor = UIColor.blackColor()
        
        //Set tab bar colors
        self.tabBarController.tabBar.barTintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        //Set tab bar images
        self.tabBarController.tabBar.selectedImageTintColor = UIColor.orangeColor()
            
        //Set the correct color for Navigation bar
        self.navigationController.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        self.navigationController.navigationBar.tintColor = UIColor.orangeColor()
        self.navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orangeColor()]
        
        
        //Set background colors to avoid white effect
        self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        self.moviesTableView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        //self.refreshControl.
        
        //Check??
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: false)
        
        self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        
        isConnectedAndGetMovies(false)
        
        //Logic to implement pull to refresh on table view
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.moviesTableView.addSubview(refreshControl)

    }
    
    func refresh(sender:AnyObject)
    {
        // Code to refresh table view

        isConnectedAndGetMovies(false)
        
        self.refreshControl.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        view.endEditing(true)
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        
        var movie = movies[indexPath.row]
        
        //var cell = UITableViewCell()
        //let cell = UITableViewCell(style: .Default, reuseIdentifier: "")
        
        var cell = tableView.dequeueReusableCellWithIdentifier("com.codepath.rottentomatoes.moviecell") as MovieTableViewCell
        
        var rating = movie["mpaa_rating"] as? String
        var synopsis = movie["synopsis"] as? String
        var description = rating! + " " + synopsis!
        
        cell.titleLabel!.text = movie["title"] as? String
        cell.synopsisLabel!.text = description
        
        var posters = movie["posters"] as NSDictionary
        var poster = posters["thumbnail"] as String
        
        // HACK: The server isn't returning the correct picutre urls
        //let fixPoster = poster.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
        

        //cell.posterView.setImageWithURL(NSURL(string: poster))

        
        // Check our image cache for the existing key. This is just a dictionary of UIImages
        var image: UIImage? = self.imageCache.valueForKey(poster) as? UIImage
        
        
        if(( image? ) == nil) {
            
            let image_url = NSURL(string: poster)
            let url_request = NSURLRequest(URL: image_url)
            let placeholder = UIImage(named: "no_photo")
            cell.imageView.setImageWithURLRequest(url_request, placeholderImage: placeholder, success: { [weak cell] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                    // cache image
                    // Store the image in to our cache
                    self.imageCache.setValue(image, forKey: poster)
                    if let cell_for_image = cell {
                            cell_for_image.posterView.image = image
                            cell_for_image.setNeedsLayout()
                    }
                }, failure: { [weak cell]
                    (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    // handle fail
                    if let cell_for_image = cell {
                        cell_for_image.posterView.image = nil
                        cell_for_image.setNeedsLayout()
                    }
                    println("fail")
            })
        }
        else {
            cell.posterView.image = image
        }
        
        
        //Animate image fade in
        cell.posterView.alpha = 0
        UIView.animateWithDuration(0.8, animations: {
            // This causes first view to fade in and second view to fade out
            cell.posterView.alpha = 1
        })
        

        cell.backgroundColor = UIColor(red: 41/256, green: 41/256, blue: 41/256, alpha: 1.0)
        
        var bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        cell.selectedBackgroundView = bgColorView
        
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        var movie = movies[self.moviesTableView.indexPathForSelectedRow().row] as NSDictionary
        
        let vc = segue.destinationViewController as MovieDetailsViewController
        vc.movieId = movie["id"] as? String
        vc.imageCache = self.imageCache as NSMutableDictionary
    }
    
    //API calls
    func getMovieList(isSearch: Bool) {

        
        //Loading HUD
        var progressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHUD)
        progressHUD.labelText = "Loading..."
        //progressHUD.delegate = self
        progressHUD.show(true)
        
        
        // API call
        var searchParam = ""
        var movieListParam = "lists/movies/box_office"
        if isSearch && self.movieSearchBar.text != "" {
            movieListParam = "movies"
            searchParam = "&q=\(self.movieSearchBar.text)"
        } else if (self.tabBarController.selectedIndex == 0) {
            movieListParam = "lists/movies/box_office"
        } else { //if (self.tabBarController.selectedIndex == 1){
            movieListParam = "lists/dvds/new_releases"
        }
        
        println(movieListParam)
        println(self.tabBarController.selectedIndex)

        var url = "http://api.rottentomatoes.com/api/public/v1.0/\(movieListParam).json?apikey=gfn4z967ephem7tmjjjpaww3&limit=20\(searchParam)"
        var request = NSURLRequest(URL: NSURL(string: url))
        
        println(url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var object = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
            
            //println("object: \(object)")
            
            self.movies = object["movies"] as [NSDictionary]
            
            self.moviesTableView.reloadData()
            
            progressHUD.hide(true)
        }
    }
    
    func isConnectedAndGetMovies(isSearch: Bool)->Void{
        
        //var conn:Bool = false
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock{(status) in
            var tt = AFStringFromNetworkReachabilityStatus(status)
            println(tt)
            println(status.toRaw())
            
            if (status.toRaw() == 0) {
                self.networkBannerView.hidden = false
                    //self.isConnSearch = false
                    //self.isConn = false
                
            } else {
                self.networkBannerView.hidden = true
                if (isSearch) {
                    self.isConnSearch = true
                } else {
                    self.isConn = true
                }
            }
            
        }
        
        println(isConn)
    }
    
    func searchBar(searchBar: UISearchBar!, textDidChange searchText: String!) {
        println("search on the fly")
        isConnectedAndGetMovies(true)
    }
    
    

    
}

//Figure out how to use it later
//        var m13ProgView = M13ProgressView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
//
//        m13ProgView.performAction(M13ProgressViewActionSuccess, animated: true)
//
//        m13ProgView.indeterminate = true

//        m13ProgView.primaryColor = UIColor.redColor()
//        m13ProgView.secondaryColor = UIColor.purpleColor()
//        m13ProgView.animationDuration = 10000
//
//        m13ProgView.performAction(M13ProgressViewActionNone, animated: true)
//        m13ProgView.performAction(M13ProgressViewActionSuccess, animated: true)

