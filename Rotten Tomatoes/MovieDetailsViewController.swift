//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Sahil Arora on 9/13/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var networkBannerView: UIView!
    
    var movieId:NSString? = ""
    var movieId1:NSString? = ""
    var movieDetails: NSDictionary = NSDictionary()
    
    var imageCache = NSMutableDictionary()

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieScoreLabel: UILabel!
    @IBOutlet weak var movieRatingLabel: UILabel!
    @IBOutlet weak var movieDescriptionLabel: UILabel!

    @IBOutlet weak var scrollerView: UIScrollView!
    @IBOutlet weak var overlayView1: UIView!
    
    var isConn: Bool = false {
        willSet(isConn) {
            println("set \(isConn)")
            if isConn {
                getMovieDetails()
            }
        }
        didSet {
            
        }
    }
    
//    override func loadView() {
//        self.view = UIView(frame: CGRectZero)
//        self.view.backgroundColor = UIColor.redColor()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        println(self.movieId?)
        
        //Set background colors to avoid white effect
        self.view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)
        
        self.overlayView1.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.55)

        isConnectedAndGetMovies()
        
        scrollerView.scrollEnabled = true;
        scrollerView.contentSize = CGSizeMake(320, 850);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getMovieDetails()->Void{
        
        //Loading HUD
        var progressHUD = MBProgressHUD(view: self.view)
        self.view.addSubview(progressHUD)
        progressHUD.labelText = "Loading..."
        //progressHUD.delegate = self
        progressHUD.show(true)
        
        //API Call
        var url = "http://api.rottentomatoes.com/api/public/v1.0/movies/" + movieId! + ".json?apikey=gfn4z967ephem7tmjjjpaww3"
        var request = NSURLRequest(URL: NSURL(string: url))
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var object = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
            
            //println("object: \(object)")
            
            self.movieDetails = object
            
            self.navigationItem.title = self.movieDetails["title"] as? String
            
            var posters = self.movieDetails["posters"] as NSDictionary
            var poster = posters["profile"] as String
            
            //println(poster)
            
            // HACK: The server isn't returning the correct picutre urls
            //let fixPoster = poster.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
            
            self.moviePoster?.setImageWithURL(NSURL(string: poster))
            
            var synopsis = self.movieDetails["synopsis"] as String
            self.movieDescriptionLabel?.text = synopsis
            self.movieDescriptionLabel.sizeToFit()
            
            self.overlayView1.sizeToFit()
            
            var movieTitle = self.movieDetails["title"] as? String
            var movieScore = self.movieDetails["ratings"] as NSDictionary
            var movieAudienceScore = movieScore["audience_score"] as Int
            var movieCriticsScore = movieScore["critics_score"] as Int
            var movieMpaaRating = self.movieDetails["mpaa_rating"] as? String
            
            self.movieTitleLabel?.text = movieTitle
            self.movieScoreLabel?.text = "Critics Score: \(movieCriticsScore) Audience Score: \(movieAudienceScore)"
            self.movieRatingLabel?.text = movieMpaaRating
            
            let hdPosterUrl = poster.stringByReplacingOccurrencesOfString("tmb", withString: "ori")
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // Jump in to a background thread to get the image for this item

                
                // Check our image cache for the existing key. This is just a dictionary of UIImages
                var image: UIImage? = self.imageCache.valueForKey(hdPosterUrl) as? UIImage
                
                
                if(( image? ) == nil) {
                    // If the image does not exist, we need to download it
                    var imgURL: NSURL = NSURL(string: hdPosterUrl)
                    
                    // Download an NSData representation of the image at the URL
                    var request: NSURLRequest = NSURLRequest(URL: imgURL)
                    var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if ( (error?) == nil) {
                            //var imgData: NSData = NSData(contentsOfURL: imgURL)
                            image = UIImage(data: data)
                            
                            // Store the image in to our cache
                            self.imageCache.setValue(image, forKey: hdPosterUrl)
                            //cell.image = image
                            self.moviePoster.image = image
                        }
                        else {
                            println("Error: \(error?.localizedDescription)")
                        }
                    })
                    
                }
                else {
                    //cell.image = image
                    self.moviePoster.image = image
                }
                
                
                
                
                })
            
            
            
            
            progressHUD.hide(true)
        }
    }
    
    func isConnectedAndGetMovies()->Void{
        
        //var conn:Bool = false
        
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock{(status) in
            var tt = AFStringFromNetworkReachabilityStatus(status)
            println(tt)
            println(status.toRaw())
            
            
            if (status.toRaw() == 0) {
                self.networkBannerView?.hidden = false
                self.isConn = false
            } else {
                self.networkBannerView?.hidden = true
                self.isConn = true
            }
            
        }
        
        println(isConn)
    }

}
