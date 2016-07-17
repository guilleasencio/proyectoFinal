//
//  Punto.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Punto: MKPointAnnotation {
    
    var nombre: String
    var coordenadas: CLLocationCoordinate2D
    var foto: UIImage?
    
    init (nombre: String, coordenadas: CLLocationCoordinate2D, foto: UIImage?) {
        
        self.nombre = nombre
        self.coordenadas = coordenadas
        self.foto = foto

    }
    
}
