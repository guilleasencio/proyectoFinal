//
//  QR.swift
//  proyectoFinal
//
//  Created by Guillermo Asencio Sanchez on 17/7/16.
//  Copyright © 2016 Guillermo Asencio Sanchez. All rights reserved.
//

import UIKit
import AVFoundation

class QR: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    var sesion: AVCaptureSession?
    var capa: AVCaptureVideoPreviewLayer?
    var marcoQR: UIView?
    var urls: String?
    
    override func viewWillAppear(animated: Bool) {
        marcoQR?.frame = CGRectZero
        sesion?.startRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dispositivo = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let entrada = try AVCaptureDeviceInput(device: dispositivo)
            sesion = AVCaptureSession()
            sesion?.addInput(entrada)
            let metaDatos = AVCaptureMetadataOutput()
            sesion?.addOutput(metaDatos)
            metaDatos.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            metaDatos.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            capa = AVCaptureVideoPreviewLayer(session: sesion!)
            capa?.videoGravity = AVLayerVideoGravityResizeAspectFill
            capa?.frame = view.layer.bounds
            view.layer.addSublayer(capa!)
            marcoQR = UIView()
            marcoQR?.layer.borderWidth = 3
            marcoQR?.layer.borderColor = UIColor.redColor().CGColor
            view.addSubview(marcoQR!)
            sesion?.startRunning()
        }
        catch{
            
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        marcoQR?.frame = CGRectZero
        if (metadataObjects == nil || metadataObjects.count == 0) {
            return
        }
        let objMetadato = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if (objMetadato.type == AVMetadataObjectTypeQRCode) {
            let objBordes = capa?.transformedMetadataObjectForMetadataObject(objMetadato as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            marcoQR?.frame = objBordes.bounds
            if ( objMetadato.stringValue != nil) {
                self.urls = objMetadato.stringValue
                let navc = self.navigationController
                navc?.performSegueWithIdentifier("detalleQR", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func volver(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
