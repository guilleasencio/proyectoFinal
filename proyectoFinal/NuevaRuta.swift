//
//  NuevaRuta.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol NuevaRutaDelegate: class {
    func actualizarRutas(datos: Array<Ruta>)
}

class NuevaRuta: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    weak var delegate: NuevaRutaDelegate?
    
    var manejador: CLLocationManager?

    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var descripcion: UITextView!
    
    var rutas: Array<Ruta> = Array<Ruta>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manejador!.delegate = self
        
    }

    @IBAction func guardarRuta(sender: AnyObject) {
        
        let nuevoNombre = nombre.text
        let nuevaDescripcion = descripcion.text
        
        let nuevaRuta = Ruta(nombre: nuevoNombre!, descripcion: nuevaDescripcion, foto: UIImage(), puntos: Array<Punto>())
        
        if manejador!.location?.coordinate != nil {
            var punto = CLLocationCoordinate2D()
            punto.latitude = (manejador!.location?.coordinate.latitude)!
            punto.longitude = (manejador!.location?.coordinate.longitude)!
            
            let puntoInicial = Punto(nombre: "Inicio", coordenadas: punto, foto: UIImage())
            
            nuevaRuta.puntos.append(puntoInicial)
        }
        
        rutas.append(nuevaRuta)
        
        self.delegate?.actualizarRutas(self.rutas)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelar(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
