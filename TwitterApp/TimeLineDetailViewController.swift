//
//  TimeLineDetailViewController.swift
//  TwitterApp
//
//  Created by 横山卓也 on 2015/09/22.
//  Copyright © 2015年 yokoyama. All rights reserved.
//

import UIKit

class TimeLineDetailViewController: UIViewController {

    var tweet:TwitterTimeLine?
    
    @IBOutlet weak var favButton: UIButton!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var detailImageView: UIImageView!
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tweet = tweet{
            iconImageView.sd_setImageWithURL(NSURL(string: tweet.userIcon))
            detailImageView.sd_setImageWithURL(NSURL(string: tweet.imageURL))
            
            userLabel.text = tweet.userName
            tweetCountLabel.text = "リツイート : \(tweet.retweetCount)\nファボ : \(tweet.favoriteCount)"
            tweetLabel.text = tweet.text
            
            if tweet.favorited{
                favButton.setTitleColor(UIColor.yellowColor(), forState: .Normal)
            }else{
                favButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            }
            
        }
        
    }


}