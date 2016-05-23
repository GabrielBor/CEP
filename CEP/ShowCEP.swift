//
//  ShowCEP.swift
//  CEP
//
//  Created by Gabriel de Sousa Borges on 5/22/16.
//  Copyright © 2016 Gabriel de Sousa Borges. All rights reserved.
//

import UIKit

class ShowCEP: UIViewController {
    
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var dataHoraLabel: UILabel!
    @IBOutlet weak var cepLabel: UILabel!
    
    var values: NSArray = []
    var usuario: String!

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let prefs: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn: Int = prefs.integerForKey("ISLOGGEDIN") as Int
        usuario = prefs.valueForKey("USERNAME") as? String
        
        get()
        let maindata = values[0]
        nomeLabel.text = maindata["usuario"] as? String
        dataHoraLabel.text = maindata["data_hora"] as? String
        cepLabel.text = maindata["cep"] as? String
        
    }
    
    func get () {
        
        let url = NSURL(string: "http://localhost:8888/cep/getcep.php?username=\(usuario)")
        
        let data = NSData(contentsOfURL: url!)
        
        do{
            values = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
        }catch {
            print("nulo")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
