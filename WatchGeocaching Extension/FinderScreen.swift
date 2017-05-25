//
//  FinderScreen.swift
//  GeoCachingClock
//
//  Created by Marko Lehtola on 17.5.2017.
//  Copyright © 2017 Lestola Industries. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class FinderScreen: WKInterfaceController, CLLocationManagerDelegate, WKCrownDelegate {
    
    var targetN:Int = 0
    var targetE:Int = 0
    var targetCoordinates = CLLocationCoordinate2D()
    var mapCenterCoordinates = CLLocationCoordinate2D()
    var mapZoomLatitude = Double()
    var mapZoomLongitude = Double()
    //kartan suhteellinen zoomLevel (mahollisesti yritetään saada riittävästi kuvaa näkymään että nuppineulan pää mahtuu kuvaan)
    var zoomLevel:Double = 1.5
    //tämä muuttuja kertoo käytetäänkö metri vai maili järjestelmää
    var metric = true
    var tooLongDistance = false
    
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var distanceToTargetLabel: WKInterfaceLabel!
    
    @IBOutlet var mapOutlet: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        locationManager.requestAlwaysAuthorization()
        //ladataan contextista coordinaatit coordinaatti arrayhin
        targetCoordinates = context as! CLLocationCoordinate2D
        //herätetään kruunukytkin käyttöön
        crownSequencer.focus()
        crownSequencer.delegate = self
        
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        //poistetaan nuppineulat jos niitä on jäänyt viimekerroilta
        mapOutlet.removeAllAnnotations()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            //------------ Pituus mitat ruudun yläälaitaan ---------------
            if metric {
                //lasketaan etäisyys measure funktiolla
                print("Olet tässä:", location.coordinate)
                print("Target coords:", targetCoordinates)
                let distance = Int(measure(lat1: location.coordinate.latitude, lon1: location.coordinate.longitude, lat2: targetCoordinates.latitude, lon2: targetCoordinates.longitude))
                if distance > 1000{
                //Muutetaan metrit kilometreiksi yhdellä desimaalilla
                    distanceToTargetLabel.setText(String(Double(Int(distance / 100))/10) + "km")
                }
                else{
                    distanceToTargetLabel.setText(String(distance) + "m")
                }
            }
            else if !metric{
                //lasketaan etäisyydet jos imperialit käytössä
                print("Olet tässä:", location.coordinate)
                print("Target coords:", targetCoordinates)
                var distance:Double = measure(lat1: location.coordinate.latitude, lon1: location.coordinate.longitude, lat2: targetCoordinates.latitude, lon2: targetCoordinates.longitude)
                distance *= 3.2808399
                if distance < 5280.0{
                    distanceToTargetLabel.setText(String(Int(distance)) + " feet")
                }
                else{
                    distanceToTargetLabel.setText(String(Double(Int(distance / 528))/10) + "mi")
                }
            }
            
            //---------------- Kartta zoomaus ----------------
            //latitude keskipiste kartalla
            if location.coordinate.latitude > targetCoordinates.latitude{
                mapCenterCoordinates.latitude = location.coordinate.latitude - (abs(location.coordinate.latitude - targetCoordinates.latitude)/2)
            }
            if targetCoordinates.latitude > location.coordinate.latitude{
                mapCenterCoordinates.latitude = targetCoordinates.latitude - (abs(location.coordinate.latitude - targetCoordinates.latitude)/2)
            }
            //longitude keskipiste kartalla
            if location.coordinate.longitude > targetCoordinates.longitude{
                mapCenterCoordinates.longitude = location.coordinate.longitude - (abs(location.coordinate.longitude - targetCoordinates.longitude)/2)
            }
            if targetCoordinates.longitude > location.coordinate.longitude{
                mapCenterCoordinates.longitude = targetCoordinates.longitude - (abs(location.coordinate.longitude - targetCoordinates.longitude)/2)
            }
            
            //zoom level
            if ((abs(location.coordinate.latitude - targetCoordinates.latitude) * zoomLevel) < 100) && ((abs(location.coordinate.longitude - targetCoordinates.longitude) * zoomLevel) < 100){
                tooLongDistance = false
                mapZoomLatitude = abs(location.coordinate.latitude - targetCoordinates.latitude) * zoomLevel
                mapZoomLongitude = abs(location.coordinate.longitude - targetCoordinates.longitude) * zoomLevel
            }
            else{
                tooLongDistance = true
            }
            
            //-------------- kartan alustus ja piirto--------------
            if tooLongDistance {
                    print("too Long Distance")
                    mapOutlet.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(1), longitudeDelta: CLLocationDegrees(1))))
            }
            
            else {
            //Zoomataan kartta sijaintiin jossa ollaan!
            mapOutlet.setRegion(MKCoordinateRegion(center: mapCenterCoordinates, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(mapZoomLatitude), longitudeDelta: CLLocationDegrees(mapZoomLongitude))))
            
            //poistetaan vanhat pinnit
            mapOutlet.removeAllAnnotations()
            
            //lisätään pinni siihen missä kätkö sijaitsee
            mapOutlet.addAnnotation(targetCoordinates, with: WKInterfaceMapPinColor.purple)
            
            //lisätään tähtäin siihen missä käyttäjä on
            mapOutlet.addAnnotation(location.coordinate, with: #imageLiteral(resourceName: "crosshair"), centerOffset: CGPoint(x: 0, y: 0))
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func measure(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double{
        // yleisesti käytetty geomittaus kaava
        let R = 6378.137; // Maapallon ympärysmitta KM
        let dLat:Double = lat2 * Double.pi / 180 - lat1 * Double.pi / 180
        let dLon:Double = lon2 * Double.pi / 180 - lon1 * Double.pi / 180
        let a:Double = sin(dLat/2) * sin(dLat/2) + cos(lat1 * Double.pi / 180) * cos(lat2 * Double.pi / 180) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let d = R * c
        let tulos = d * 1000
    return tulos; // tulos metreinä
    }
    
    @IBAction func metricForceButtonAction() {
        //force nappulalla metrijärjestelmä käyttöön
        metric = true
    }
    
    @IBAction func imperialForceButtonAction() {
        //force nappulalla imperial järjestelmä käyttöön
        metric = false
    }
    
    func crownDidRotate(_ crownSequencer: WKCrownSequencer?,
                        rotationalDelta: Double){
        //muutetaan zoomleveliä kartalla
        let zoomVarmistus:Double = zoomLevel + rotationalDelta
        if zoomVarmistus < 1{
            zoomLevel = 1.1
        }
        else if zoomVarmistus > 0 && zoomVarmistus < 10{
            zoomLevel = zoomVarmistus
        }
        else if zoomVarmistus > 5{
            zoomLevel = 4.9
        }
        else{
            zoomLevel = 1.5
        }
        print("zoomLevel:", zoomLevel)
    }
}
