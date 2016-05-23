//
//  ViewController.swift
//  CEP
//
//  Created by Gabriel de Sousa Borges on 5/21/16.
//  Copyright © 2016 Gabriel de Sousa Borges. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var textLogin: UITextField!
    @IBOutlet weak var textPassWord: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func entrar(sender: UIButton) {
        
        if textLogin.text == "" || textPassWord.text == "" {
            let alert = UIAlertController(title: "Atenção", message: "Preencha todos os campos", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            do {
                let post:NSString = "username=\(textLogin.text! as String)&password=\(textPassWord.text! as String)"
                
                NSLog("PostData: %@",post);
                
                let url:NSURL = NSURL(string:"http://localhost:8888/cep/login.php")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                
                let postLength:NSString = String( postData.length )
                
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.HTTPBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: NSURLResponse?
                
                var urlData: NSData?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request, returningResponse:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    
                    NSLog("Response code: %ld", res.statusCode);
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("Login SUCCESS");
                            
                            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            prefs.setObject(textLogin.text, forKey: "USERNAME")
                            prefs.setInteger(1, forKey: "ISLOGGEDIN")
                            prefs.synchronize()
                            
                            //self.dismissViewControllerAnimated(true, completion: nil)
                            
                            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CEPIdentifier") as! CEPController
                            self.presentViewController(vc, animated: true, completion: nil)
                        } else {
                            var error_msg = "Please enter Username and Password"
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! String
                            } else {
                                error_msg = "Unknown Error"
                            }
                            let alert = UIAlertController(title: "Sign In Failed!", message:error_msg, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                            self.presentViewController(alert, animated: true){}
                        }
                        
                    } else {
                        let alert = UIAlertController(title: "Sign In Failed!", message:"Connection Failed!", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                        self.presentViewController(alert, animated: true){}
                    }
                } else {
                    var msg_error = "Connection Failure"
                    if let error = reponseError {
                        msg_error = (error.localizedDescription)
                    }
                    let alert = UIAlertController(title: "Sign in Failed!", message: msg_error, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                }
            } catch {
                let alert = UIAlertController(title: "Sign In Failed!", message:"Server Error!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

