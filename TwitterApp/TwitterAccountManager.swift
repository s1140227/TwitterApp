//
//  TwitterAccountManager.swift
//  TwitterApp
//
//  Created by 横山卓也 on 2015/09/22.
//  Copyright © 2015年 yokoyama. All rights reserved.
//

import UIKit
import Social
import Accounts
import Alamofire

class TwitterAccountManager{
    
    private static let instance = TwitterAccountManager()
    private static let BaseURL = "https://api.twitter.com/1.1/"
    
    private var account:ACAccount?
    
    //Tweet画面表示
    static func showTweetDialog(){
        
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            
            //CancelもしくはPostを押した際に呼ばれ、投稿画面を閉じる処理を行っています。
            vc.completionHandler = {(result:SLComposeViewControllerResult) -> () in
                vc.dismissViewControllerAnimated(true, completion:nil)
            }
            
            ExUtil.getVC().presentViewController(vc, animated: true, completion: nil)
            
        }else{
            ExUtil.showAlert(msg: "Twitterアカウントが登録されていません。")
        }
    }
    
    //ログイン処理を自動で行う汎用API通信メソッド
    static func requestTwitterAPI(endPoint:String, method:SLRequestMethod = .GET,
        parameters:[String:AnyObject] = [:], callback:(Result<AnyObject>)->Void){
            
            //未ログインの場合は先にログイン処理を行う
            if instance.account == nil{
                
                loginTwitter({ () -> () in
                    if instance.account != nil{
                        requestTwitterAPI(endPoint, method: method, parameters: parameters, callback: callback)
                    }
                })
                return
            }
            
            //ログイン済みの場合はAPIへリクエストを行う
            //print("URL >> \(BaseURL)\(endPoint)")
            //print("Param >> \(parameters)")
            let url = NSURL(string: "\(BaseURL)\(endPoint)")
            let preRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: method, URL: url, parameters:parameters)
            preRequest.account = instance.account
            
            Alamofire.request(preRequest.preparedURLRequest()).responseJSON { _, response, result in
                
                if let statusCode = response?.statusCode{
                    
                    if statusCode == 429{
                        ExUtil.showAlert(msg: "APIリクエスト上限通信エラーです。しばらくしてから再度お試しください。")
                        callback(Result.Failure(nil, Error.errorWithCode(statusCode, failureReason: "APIリクエスト上限通信エラー")))
                    }
                    else if statusCode != 200{
                        ExUtil.showAlert(msg: "リクエストエラーです。status -> \(statusCode)")
                        callback(Result.Failure(nil, Error.errorWithCode(statusCode, failureReason: "リクエストエラー")))
                        
                    }else{
                        
                        if result.isFailure{
                            ExUtil.showAlert(msg: "通信エラーです。電波の良いところで再度お試しください。")
                        }
                        
                        callback(result)
                    }
                }
            }
            
    }

    
    
    //ログイン処理
    private static func loginTwitter(callback:()->()){
        
        if !SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            ExUtil.showAlert(msg: "Twitterアカウントが登録されていません。")
            return
        }
        
        let store = ACAccountStore();
        let type = store.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        store.requestAccessToAccountsWithType(type, options: nil) { (granted, error) -> Void in
            
            if error != nil || granted == false{
                ExUtil.showAlert(msg: "Twitterアカウントが許可されていません。")
                return;
            }
            
            let accounts = store.accountsWithAccountType(type);
            if accounts.count == 0{
                return;
            }
            
            if let account = accounts[0] as? ACAccount{
                //print("自分のアカウント名：「\(account.username)」\n")
                
                //アカウントをメモリに保持
                instance.account = account
                
                callback()
                
            }
        }
    }
    
}


