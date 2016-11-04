//
//  Capturado.swift
//  BountyHunter
//
//  Created by Infraestructura on 28/10/16.
//  Copyright © 2016 Infraestructura. All rights reserved.
//

import UIKit
import MapKit
import Social
import CoreLocation

class Capturado: UIViewController, CLLocationManagerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var lblNombre: UILabel!
    @IBOutlet weak var lblDelito: UILabel!
    @IBOutlet weak var lblRecompensa: UILabel!
    @IBOutlet weak var imgFugitivo: UIImageView!
    @IBOutlet weak var btnGuardar: UIButton!
    @IBOutlet weak var btnFoto: UIButton!
    var fugitivo:Fugitive?
    var localizador : CLLocationManager?
    
    
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblLon: UILabel!
    
    var count:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.localizador = CLLocationManager()
        self.localizador?.desiredAccuracy = kCLLocationAccuracyBest
        self.localizador?.delegate = self
        // Do any additional setup after loading the view.
        let autorizado  = CLLocationManager.authorizationStatus()
        if autorizado == CLAuthorizationStatus.NotDetermined {
            self.localizador?.requestWhenInUseAuthorization()
        }
        
        self.localizador?.startUpdatingLocation()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        lblNombre.text  = fugitivo?.name
        lblDelito.text = fugitivo?.desc
        let formater = NSNumberFormatter()
        lblRecompensa.text  =  formater.stringFromNumber((fugitivo?.bounty)!)
    }

    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnX(sender: AnyObject) {
   
        let imagenData=NSData(data:UIImageJPEGRepresentation(self.imgFugitivo.image!, 1.0)!)
        self.fugitivo?.image = imagenData
        self.fugitivo?.captdate=NSDate().timeIntervalSinceReferenceDate
        
        self.fugitivo?.captured = true
        print("\(self.fugitivo?.captdate)")
        do {
            try DBManager.instance.managedObjectContext?.save()
            //mapa
            let googleMapURL="https://www.google.com.mx/maps/@"
            //\(self.fugitivo?.capturedLat),\(self.fugitivo?.capturedLon)"
            
            //habiliatr redes sociales u otros
            let laFoto=UIImage(data: self.fugitivo!.image!)
            let texto = "Ya capture a \(self.fugitivo?.name) en la siguiente ubicacion \(googleMapURL)"
            let image = UIImage(named: "fugitivo")
            //compartir para otras cosas x face and twiter
            let hayFeiz = SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
            let hayTuit = SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)
            //di rxisdten las dos app, permite al usuario elegir cual de los 2
            if hayFeiz && hayTuit {
                let ac = UIAlertController(title: "Compartir", message: "Compartir con ...", preferredStyle: .Alert)
                let btnFeiz = UIAlertAction(title: "Facebook .", style: .Default, handler:
                    { (UIAlertAction) in
                        let feizbuc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                        feizbuc.setInitialText(texto)
                        feizbuc.addImage(laFoto!)
                        self.presentViewController(feizbuc, animated: true, completion:
                            {
                            self.navigationController?.popViewControllerAnimated(true)
                            }
                        )
                    })
                let btnTiut = UIAlertAction(title: "Twiter .", style: .Default, handler:
                    { (UIAlertAction) in
                        let tuiter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                        tuiter.setInitialText(texto)
                        tuiter.addImage(laFoto!)
                        self.presentViewController(tuiter, animated: true, completion:
                            {
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        )
                })
                let noquiero = UIAlertAction(title: "No gracias", style: .Destructive, handler: nil)
                ac.addAction(btnFeiz)
                ac.addAction(btnTiut)
                ac.addAction(noquiero)
                self.presentViewController(ac, animated: true, completion: nil)
                
            }
            else{
                //tarea enviar correo con coordenadsa a jan.zelaznog a  gmail.com
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                    let feizbuc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                    feizbuc.setInitialText(texto)
                    feizbuc.addImage(laFoto!)
                    self.presentViewController(feizbuc, animated: true, completion: {
                        self.navigationController?.popViewControllerAnimated(true)})
                    
                }
                else if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                    let tuiter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                    tuiter.setInitialText(texto)
                    tuiter.addImage(laFoto!)
                    self.presentViewController(tuiter, animated: true, completion: {
                        self.navigationController?.popViewControllerAnimated(true)})
                }
                else {
                    let items:Array<AnyObject> = [texto, laFoto!, image!]
                    let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                    // esto solo es necesario para el caso del correo
                    avc.setValue("Fugitivo Capturado!", forKey:"Subject") // jan.zelaznog@gmail.com
                    //cambiar la el nombre de la jecucion para otro tipo de dispositivo de ipas a iphone
                    if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                        self.presentViewController(avc, animated: true, completion:
                            {self.navigationController?.popViewControllerAnimated(true)})
                    }
                    else{
                        let popover = UIPopoverController(contentViewController: avc)
                        popover.presentPopoverFromRect(self.btnGuardar.frame,
                                                       inView: self.view, permittedArrowDirections: .Any, animated: true)
                        self.navigationController?.popViewControllerAnimated(true) // esta linea me regresa
                    }
                }
            }
                                                   
        } catch {
            print("Error al salvar DB")
        }
    }
    
    @IBAction func btnSendF(sender: AnyObject) {
        
        let imagePickerController: UIImagePickerController=UIImagePickerController()
        //para que el
        imagePickerController.modalPresentationStyle = .FullScreen
        //pregunta si selecciona fotos de la galeria
        self.btnFoto.hidden=true
        self.localizador?.pausesLocationUpdatesAutomatically
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        let ac = UIAlertController(title: "Fotografia", message: "Escoger desde  ...", preferredStyle: .Alert)
        let btnCamara = UIAlertAction(title: "Camara .", style: .Default, handler:
            { (UIAlertAction) in
                imagePickerController.sourceType = .Camera
                                //imagePickerController.sourceType = .SavedPhotosAlbum
                self.presentViewController(imagePickerController, animated: true, completion:
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                )
        })
        let btnBiblio = UIAlertAction(title: "PhotoLibrary .", style: .Default, handler:
            { (UIAlertAction) in
                imagePickerController.sourceType = .PhotoLibrary // .
                // pregunta si selecciona fotos de la camara
                //imagePickerController.sourceType = .SavedPhotosAlbum
                self.presentViewController(imagePickerController, animated: true, completion:
                    {
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                )
        })
        let noquiero = UIAlertAction(title: "Foto no gracias ", style: .Destructive, handler: nil)
        ac.addAction(btnCamara)
        ac.addAction(btnBiblio)
        ac.addAction(noquiero)
        self.presentViewController(ac, animated: true, completion: nil)
        
        /*
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let imagePickerController: UIImagePickerController=UIImagePickerController()
            //para que el 
            imagePickerController.modalPresentationStyle = .FullScreen
            //pregunta si selecciona fotos de la galeria
            imagePickerController.sourceType = .Camera //PhotoLibrary // .
            // pregunta si selecciona fotos de la camara
            //imagePickerController.sourceType = .SavedPhotosAlbum
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            self.presentViewController( imagePickerController, animated:true, completion:nil)
            self.btnFoto.hidden=true
            self.localizador?.pausesLocationUpdatesAutomatically
            
        }
 */
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError){
        self.localizador?.stopUpdatingLocation()
        let ac = UIAlertController(title: "Error", message: "Noting list gps", preferredStyle: .Alert)
        let ab = UIAlertAction(title: "Unhability gps so do noting ..", style: .Default, handler: nil)
        ac.addAction(ab)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let ubicacion = locations.last! as CLLocation
        self.lblLat.text = "\(ubicacion.coordinate.latitude)"
        self.lblLon.text = "\(ubicacion.coordinate.longitude)"
        //TODO: determinar si se dejan de tomar lecturas
        //self.ColocarMapa(ubicacion )
        self.fugitivo?.capturedLat = ubicacion.coordinate.latitude
        self.fugitivo?.capturedLon = ubicacion.coordinate.longitude
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //img original
        //let image:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //img modificada
        let image:UIImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.imgFugitivo.image=image
        self.dismissViewControllerAnimated(true,  completion:nil)
        self.btnFoto.hidden=false
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion:nil)
    }
    
}


