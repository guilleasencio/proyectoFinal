//
//  ViewController.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TablaRutaDelegate {

    var rutas: Array<Ruta> = Array<Ruta>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "rutas"{
            
            let sigVista = segue.destinationViewController as! TablaRutas
    
            sigVista.rutas = self.rutas
            sigVista.delegate = self
            
        }
    }
    
    func mantenerRutas(datos: Array<Ruta>){
        self.rutas = datos
    }


}

