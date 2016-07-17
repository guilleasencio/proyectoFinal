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

class Rutas: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapa: MKMapView!
    
    var manejador: CLLocationManager? = nil
    
    private var puntoInicial : Punto? = nil
    
    var ruta: Ruta? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapa.delegate = self
        
        manejador!.delegate = self
        
        if manejador!.location?.coordinate != nil {
            mapa.showsUserLocation = true
        }else{
            mapa.showsUserLocation = false
        }

        self.mostrarRuta()
        self.centrarMapa()
        
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
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        if manejador!.location?.coordinate != nil {
            var punto = CLLocationCoordinate2D()
            punto.latitude = (manejador!.location?.coordinate.latitude)!
            punto.longitude = (manejador!.location?.coordinate.longitude)!
            
            let puntoActual = Punto(nombre: nombre, coordenadas: punto, foto: UIImage())
            
            ruta!.puntos.append(puntoActual)
            
            var puntoLugar = MKPlacemark(coordinate: punto, addressDictionary: nil)
            let destino = MKMapItem(placemark: puntoLugar)
            destino.name = nombre
            
            self.anotaPunto(destino)
            let indice = (ruta?.puntos.count)! - 2
            let puntoCoor = CLLocationCoordinate2D(latitude: ruta!.puntos[indice].coordenadas.latitude, longitude: ruta!.puntos[indice].coordenadas.longitude)
            puntoLugar = MKPlacemark(coordinate: puntoCoor, addressDictionary: nil)
            let origen = MKMapItem(placemark: puntoLugar)
            origen.name = ruta!.puntos[indice].nombre
            
            self.obtenerRuta(origen, destino: destino)
        }

    }

    @IBAction func tomarFoto(sender: AnyObject) {
    }

}
