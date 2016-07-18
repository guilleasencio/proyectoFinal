//
//  Ruta.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import Foundation
import UIKit

class Ruta {
    
    var nombre: String
    var foto: UIImage?
    var descripcion: String
    var puntos:Array<Punto>
    
    init (nombre: String, descripcion: String, foto: UIImage?, puntos: Array<Punto>) {
        
        self.nombre = nombre
        self.descripcion = descripcion
        self.foto = foto
        self.puntos = puntos
        
    }
    
}