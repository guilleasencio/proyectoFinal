//
//  Rutas.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import WatchConnectivity

class Rutas: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WCSessionDelegate  {

    var sesion: WCSession!
    @IBOutlet weak var mapa: MKMapView!
    
    var manejador: CLLocationManager? = nil
    
    private var puntoInicial : Punto? = nil
    
    @IBOutlet weak var camaraBoton: UIButton!
    
    var ruta: Ruta? = nil
    
    private let miPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapa.delegate = self
        
        manejador!.delegate = self
        
        if manejador!.location?.coordinate != nil {
            mapa.showsUserLocation = true
        }else{
            mapa.showsUserLocation = false
        }
        
        miPicker.delegate = self

        self.mostrarRuta()
        self.centrarMapa()
        
        
        if (WCSession.isSupported()) {
            sesion = WCSession.defaultSession()
            sesion.delegate = self
            sesion.activateSession()
        }
        
        sesion.sendMessage(["ruta": self.ruta!], replyHandler: nil, errorHandler: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        // Modificamos foto de la ruta
        self.ruta!.foto = image
        
        // Crear nuevo punto de interes con la imagen
        
        var nombre: String = "Punto de Interés"
        let alert = UIAlertController(title: "Nuevo punto", message: "Indique un nombre:", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Punto de interés"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            nombre = textField.text!
            if self.manejador!.location?.coordinate != nil {
                var punto = CLLocationCoordinate2D()
                punto.latitude = (self.manejador!.location?.coordinate.latitude)!
                punto.longitude = (self.manejador!.location?.coordinate.longitude)!
                
                let puntoActual = Punto(nombre: nombre, coordenadas: punto, foto: image)
                
                self.ruta!.puntos.append(puntoActual)
                
                var puntoLugar = MKPlacemark(coordinate: punto, addressDictionary: nil)
                let destino = MKMapItem(placemark: puntoLugar)
                destino.name = nombre
                
                self.anotaPunto(destino)
                let indice = (self.ruta?.puntos.count)! - 2
                let puntoCoor = CLLocationCoordinate2D(latitude: self.ruta!.puntos[indice].coordenadas.latitude, longitude: self.ruta!.puntos[indice].coordenadas.longitude)
                puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
                let origen = MKMapItem(placemark: puntoLugar)
                origen.name = self.ruta!.puntos[indice].nombre
                
                self.obtenerRuta(origen, destino: destino)
                
                self.centrarMapa()
                
                self.sesion.sendMessage(["ruta": self.ruta!], replyHandler: nil, errorHandler: nil)
            }
            
            
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) -> Void in
            print("Cancelar")
        }))
        
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if manejador!.location?.coordinate != nil {
            manejador!.startUpdatingLocation()
        }else{
            manejador!.stopUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        manejador!.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador!.startUpdatingLocation()
            manejador!.startUpdatingHeading()
            mapa.showsUserLocation = true
        }else{
            manejador!.stopUpdatingLocation()
            manejador!.stopUpdatingHeading()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("\(error)")
    }
    
    func centrarMapa(){
        if manejador!.location?.coordinate != nil {
            
            let centro = CLLocationCoordinate2D(latitude: (manejador!.location?.coordinate.latitude)!, longitude: (manejador!.location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: centro, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapa.setRegion(region, animated: true)
        }
        
    }
    
    func anotaPunto(punto: MKMapItem){
        let anota = MKPointAnnotation()
        anota.coordinate = punto.placemark.coordinate
        anota.title = punto.name
        mapa.addAnnotation(anota)
        
    }
    
    func mostrarRuta(){
        
        var origen: MKMapItem!
        var destino: MKMapItem!
        var puntoCoor: CLLocationCoordinate2D
        var puntoLugar: MKPlacemark
        
        if (ruta?.puntos.count>1) {
            let limite = ruta!.puntos.count - 1
            for indice in 1...limite {
                if (indice == 1) {
                    puntoCoor = CLLocationCoordinate2D(latitude: ruta!.puntos[indice-1].coordenadas.latitude, longitude: ruta!.puntos[indice-1].coordenadas.longitude)
                    puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
                    origen = MKMapItem(placemark: puntoLugar)
                    origen.name = ruta!.puntos[indice-1].nombre
                    
                    self.anotaPunto(origen!)

                } else {
                    origen = destino
                }
                
                puntoCoor = CLLocationCoordinate2D(latitude: ruta!.puntos[indice].coordenadas.latitude, longitude: ruta!.puntos[indice].coordenadas.longitude)
                puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
                destino = MKMapItem(placemark: puntoLugar)
                destino.name = ruta!.puntos[indice].nombre
                
                self.anotaPunto(destino!)
                
                self.obtenerRuta(origen!, destino: destino!)
               
            }
        
        } else if ruta?.puntos.count == 1{
        
            puntoCoor = CLLocationCoordinate2D(latitude: ruta!.puntos[0].coordenadas.latitude, longitude: ruta!.puntos[0].coordenadas.longitude)
            puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
            origen = MKMapItem(placemark: puntoLugar)
            origen.name = ruta!.puntos[0].nombre
            
            self.anotaPunto(origen!)
        
        }
    }
    
    func obtenerRuta(origen: MKMapItem, destino: MKMapItem){
        let solicitud = MKDirectionsRequest()
        solicitud.source = origen
        solicitud.destination = destino
        solicitud.transportType = .Walking
        let indicaciones = MKDirections(request: solicitud)
        indicaciones.calculateDirectionsWithCompletionHandler({
            (respuesta: MKDirectionsResponse?, error: NSError?) in
            if error != nil{
                print("Error al obtener la ruta")
            }else{
                self.muestraRuta(respuesta!)
            }
        })
    }
    
    func muestraRuta(respuesta: MKDirectionsResponse){
        for ruta in respuesta.routes{
            mapa.addOverlay(ruta.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 3.0
        return renderer
    }
   
    @IBAction func agregarPunto(sender: AnyObject) {
        
        var nombre: String = "Punto de Interés"
        let alert = UIAlertController(title: "Nuevo punto", message: "Indique un nombre:", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Punto de interés"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            nombre = textField.text!
            if self.manejador!.location?.coordinate != nil {
                var punto = CLLocationCoordinate2D()
                punto.latitude = (self.manejador!.location?.coordinate.latitude)!
                punto.longitude = (self.manejador!.location?.coordinate.longitude)!
                
                let puntoActual = Punto(nombre: nombre, coordenadas: punto, foto: UIImage())
                
                self.ruta!.puntos.append(puntoActual)
                
                var puntoLugar = MKPlacemark(coordinate: punto, addressDictionary: nil)
                let destino = MKMapItem(placemark: puntoLugar)
                destino.name = nombre
                
                self.anotaPunto(destino)
                let indice = (self.ruta?.puntos.count)! - 2
                let puntoCoor = CLLocationCoordinate2D(latitude: self.ruta!.puntos[indice].coordenadas.latitude, longitude: self.ruta!.puntos[indice].coordenadas.longitude)
                puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
                let origen = MKMapItem(placemark: puntoLugar)
                origen.name = self.ruta!.puntos[indice].nombre
                
                self.obtenerRuta(origen, destino: destino)
                
                self.centrarMapa()
                
                self.sesion.sendMessage(["ruta": self.ruta!], replyHandler: nil, errorHandler: nil)
            }

            
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: .Cancel, handler: { (action) -> Void in
            print("Cancelar")
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
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

}
