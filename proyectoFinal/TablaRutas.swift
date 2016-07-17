//
//  TablaRutas.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol TablaRutaDelegate: class {
    func mantenerRutas(datos: Array<Ruta>)
}


class TablaRutas: UITableViewController, NuevaRutaDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    weak var delegate: TablaRutaDelegate?
    
    var rutas: Array<Ruta> = Array<Ruta>()
    
    var manejador = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rutas.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tableView.reloadData()
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        self.delegate?.mantenerRutas(self.rutas)
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = self.rutas[indexPath.row].nombre
        
        return cell
    }
    
    func actualizarRutas(datos: Array<Ruta>){
        self.rutas = datos
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "nuevaRuta"{

            let navController = segue.destinationViewController as! UINavigationController
            let sigVista = navController.viewControllers.first as! NuevaRuta
            sigVista.manejador = self.manejador
            sigVista.rutas = self.rutas
            sigVista.delegate = self
        }else if segue.identifier == "verRuta" {
            let sigVista = segue.destinationViewController as! Rutas
            sigVista.manejador = self.manejador
            sigVista.ruta = self.rutas[(self.tableView.indexPathForSelectedRow?.row)!]
        }
    }


}
