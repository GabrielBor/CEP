//
//  CEPController.swift
//  CEP
//
//  Created by Gabriel de Sousa Borges on 5/21/16.
//  Copyright © 2016 Gabriel de Sousa Borges. All rights reserved.
//

import UIKit

class CEPController: UIViewController {
    
    @IBOutlet weak var textCep: UITextField!
    var usuario: String!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn: Int = prefs.integerForKey("ISLOGGEDIN") as Int
        usuario = prefs.valueForKey("USERNAME") as? String
        
        
    }
    
    @IBAction func enviar() {
        
        if textCep == "" {
            let alert = UIAlertController(title: "Atenção", message: "Preencha todos os campos", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            do {
                // Passa os parametros pelo método POST
                let post: NSString = "username=\(usuario)&cep=\(textCep.text! as String)"
                
                NSLog("PostData: %@",post)
                
                // link do script php pra dar um request pesadao
                let url:NSURL = NSURL(string: "http://localhost:8888/cep/inserecep.php")!
                
                let postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
                
                let postLength:NSString = String(postData.length)
                
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
                    let res = response as! NSHTTPURLResponse!
                    
                    NSLog("Response code: %ld", res.statusCode)
                    
                    if (res.statusCode >= 200 && res.statusCode < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                        
                        NSLog("Response ==> %@", responseData)
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue]
                        
                        NSLog("Success: %ld", success)
                        
                        // Se cadastrou sem nenhum erro manda aparece AlertView e da um pop na navigation (volta pro login)
                        if(success == 1)
                        {
                            NSLog("Sign Up SUCCESS")
                            //self.dismissViewControllerAnimated(true, completion: nil)
                            
                            let alert = UIAlertController(title: "CEP", message: "Inserido com sucesso!", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction!) in self.navigationController?.popViewControllerAnimated(true)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "Erro desconhecido!"
                            }
                            let alert = UIAlertController(title: "Falha ao cadastrar!", message:error_msg as String, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                            self.presentViewController(alert, animated: true){}
                        }
                        
                    } else {
                        let alert = UIAlertController(title: "Falha ao cadastrar!", message:"Falha ao conectar.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                        self.presentViewController(alert, animated: true){}
                    }
                }  else {
                    var error_msg = "Falha na conexão."
                    if let error = reponseError {
                        error_msg = (error.localizedDescription)
                    }
                    let alert = UIAlertController(title: "Falha ao cadastrar!", message:error_msg, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                    self.presentViewController(alert, animated: true){}
                }
            } catch {
                let alert = UIAlertController(title: "Falha ao cadastrar!", message:"Erro no servidor!", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default) { _ in })
                self.presentViewController(alert, animated: true){}
            }

        }
        
    }
    
    @IBAction func sair() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
