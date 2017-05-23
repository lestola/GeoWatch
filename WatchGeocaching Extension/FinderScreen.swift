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

class FinderScreen: WKInterfaceController, CLLocationManagerDelegate {
    
    var targetN:Int = 0
    var targetE:Int = 0
    var targetCoordinates = CLLocationCoordinate2D()
    var mapZoomLatitude = Double()
    var mapZoomLongitude = Double()
    //kartan suhteellinen zoomLevel (mahollisesti yritetään saada riittävästi kuvaa näkymään että nuppineulan pää mahtuu kuvaan)
    let zoomLevel:Double = 3.2
    
    let locationManager = CLLocationManager()
    
    @IBOutlet var distanceToTargetLabel: WKInterfaceLabel!
    
    @IBOutlet var mapOutlet: WKInterfaceMap!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        locationManager.requestAlwaysAuthorization()
        //ladataan contextista coordinaatit coordinaatti arrayhin
        targetCoordinates = context as! CLLocationCoordinate2D
        //tehdään karttatemppuja
        
        
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
            //lasketaan latitude zoomin etäisyys
            if location.coordinate.latitude > targetCoordinates.latitude{
                mapZoomLatitude = abs(location.coordinate.latitude - targetCoordinates.latitude)
            }
            
            else if location.coordinate.latitude < targetCoordinates.latitude{
                mapZoomLatitude = abs(targetCoordinates.latitude - location.coordinate.latitude)
            }
            else{
              mapZoomLatitude = 1
            }
            
            //lasketaan longitude zoomin etäisyys
            if location.coordinate.longitude > targetCoordinates.longitude{
                mapZoomLongitude = abs(location.coordinate.longitude - targetCoordinates.longitude)
            }
            
            else if location.coordinate.longitude < targetCoordinates.longitude{
                mapZoomLongitude = abs(targetCoordinates.longitude - location.coordinate.longitude)
            }
            else{
                mapZoomLongitude = 1
            }
            
            
            //kerrotaan vielä constantilla jolla voidaan vähän hioa etäisyyksiä
            mapZoomLatitude *= zoomLevel
            mapZoomLongitude *= zoomLevel

            //Zoomataan kartta sijaintiin jossa ollaan!
            mapOutlet.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(mapZoomLatitude), longitudeDelta: CLLocationDegrees(mapZoomLongitude))))
            
            //poistetaan vanhat pinnit
            mapOutlet.removeAllAnnotations()
            
            //lisätään pinni siihen missä kätkö sijaitsee
            mapOutlet.addAnnotation(targetCoordinates, with: WKInterfaceMapPinColor.purple)
            
            //lisätään tähtäin siihen missä käyttäjä on
            mapOutlet.addAnnotation(location.coordinate, with: #imageLiteral(resourceName: "crosshair"), centerOffset: CGPoint(x: 0, y: 0))
 
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
}
