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

class NuevaRuta: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: NuevaRutaDelegate?
    
    var manejador: CLLocationManager?

    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var descripcion: UITextView!
    var foto: UIImage = UIImage()
    
    
    @IBOutlet weak var imagen: UIImageView!
    
    var rutas: Array<Ruta> = Array<Ruta>()
    
    private let miPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        manejador!.delegate = self
        
        miPicker.delegate = self
        
    }

    @IBAction func guardarRuta(sender: AnyObject) {
        
        let nuevoNombre = nombre.text
        let nuevaDescripcion = descripcion.text
        
        let nuevaRuta = Ruta(nombre: nuevoNombre!, descripcion: nuevaDescripcion, foto: self.foto, puntos: Array<Punto>())
        
        if manejador!.location?.coordinate != nil {
            var punto = CLLocationCoordinate2D()
            punto.latitude = (manejador!.location?.coordinate.latitude)!
            punto.longitude = (manejador!.location?.coordinate.longitude)!
            
            let puntoInicial = Punto(nombre: "Inicio", coordenadas: punto, foto: self.foto)
            
            nuevaRuta.puntos.append(puntoInicial)
        }
        
        rutas.append(nuevaRuta)
        
        self.delegate?.actualizarRutas(self.rutas)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelar(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tomarFoto(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Nueva foto", message: "Indique la fuente de la foto:", preferredStyle: .Alert)
        
        // Create the actions.
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            let accionCamara = UIAlertAction(title: "Cámara", style: .Default) { _ in
                self.miPicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.miPicker, animated: true, completion: nil)
            }
            alertController.addAction(accionCamara)
        }
        
        
        let accionAlbum = UIAlertAction(title: "Álbum", style: .Default) { _ in
            self.miPicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.miPicker, animated: true, completion: nil)
        }
        
        let cancelarAlbum = UIAlertAction(title: "Cancelar", style: .Default) { _ in
            print("Cancelar")
        }
        
        // Add the actions.
        
        alertController.addAction(accionAlbum)
        alertController.addAction(cancelarAlbum)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // Modificamos foto de la ruta
        self.foto = image
        
        self.imagen.image = image
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
    }



}
