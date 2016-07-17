//
//  InterfaceController.swift
//  proyectoFinalWatch Extension
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var mapa: WKInterfaceMap!
    var sesion: WCSession!
    
    var ruta: Ruta!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if(WCSession.isSupported()){
            self.sesion = WCSession.defaultSession()
            self.sesion.delegate = self
            self.sesion.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func hacerZoom(value: Float) {
        let grados: CLLocationDegrees = CLLocationDegrees(value)/10
        
        let ventana = MKCoordinateSpanMake(grados, grados)
        let tec = CLLocationCoordinate2D(latitude: 19.283996, longitude: -99.136006)
        let region = MKCoordinateRegionMake(tec, ventana)
        self.mapa.setRegion(region)

    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        //recieving message from iphone
        self.ruta = message["ruta"]! as? Ruta
        print(message["ruta"])
        
        for indice in 0...ruta.puntos.count-1 {
            if indice < 5 {
                self.mapa.addAnnotation(ruta.puntos[indice].coordenadas, withPinColor: .Red)
            }
        }
        
    }
}
