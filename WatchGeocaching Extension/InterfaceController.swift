//
//  InterfaceController.swift
//  WatchGeocaching Extension
//
//  Created by Marko Lehtola on 14.5.2017.
//  Copyright © 2017 Lestola Industries. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    //muuttuja arrayt pickereiden täyttöön
    var nDecreesList:Array = [-90]
    var eDecreesList:Array = [-180]
    var nDegreesToShowList = [90]
    var eDegreesToShowList = [180]
    var MinutesList:Array = [0]
    var DesimalsList:Array = [0]
    
    //valitut arvot pickereistä
    var selectedNDegrees:Int = 0
    var selectedNMinutes:Int = 0
    var selectedNDesimals:Int = 0
    var selectedEDegrees:Int = 0
    var selectedEMinutes:Int = 0
    var selectedEDesimals:Int = 0
    
    //coreData muuttujat
    //let defaults = UserDefaults(suiteName: "group.com.LestolaIndustries.GeoCachingWatch")
    
    
    //koordinaatit mitä tuodaan edellisestä näkymästä tulevat tähän muuttujaan
    var coordinateContext = CLLocationCoordinate2D()
    
    @IBOutlet var longitudeLabel: WKInterfaceLabel!
    @IBOutlet var latitudeLabel: WKInterfaceLabel!
    @IBOutlet var eDegreePicker: WKInterfacePicker!
    @IBOutlet var nDegreePicker: WKInterfacePicker!
    @IBOutlet var nMinutePicker: WKInterfacePicker!
    @IBOutlet var eMinutePicker: WKInterfacePicker!
    @IBOutlet var nDesimalPicker: WKInterfacePicker!
    @IBOutlet var eDesimalPicker: WKInterfacePicker!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        loadPickers()
        // Configure interface objects here.
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func loadPickers(){
        //alusetaan pohjois pickerin array
        for x in -89...90 {
            nDecreesList.append(x)
        }
        //for index in stride(from: 10, to: 0, by: -1)
        for x in stride(from: 89, to: 0, by: -1) {
            nDegreesToShowList.append(x)
        }
        for x in 0...90 {
            nDegreesToShowList.append(x)
        }
        
        //alustetaan itäisen pickerin array
        for y in -179...180{
            eDecreesList.append(y)
        }
        for y in stride(from: 179, to: 0, by: -1) {
            eDegreesToShowList.append(y)
        }
        for y in 0...180{
            eDegreesToShowList.append(y)
        }
        
        //alustetaan minuutit
        for z in 1...59{
            MinutesList.append(z)
        }
        
        //alustetaan minuuttienDesimaalit
        for o in 1...999{
            DesimalsList.append(o)
        }
        
        //pohjoisen asteet picker
        var pickerItems:[WKPickerItem] = [WKPickerItem]()
        
        for d in nDegreesToShowList{
            let item = WKPickerItem()
            item.title = String(d)
            pickerItems.append(item)
        }
        
        nDegreePicker.setItems(pickerItems)
        
        //idän asteet picker
        var pickerItems2:[WKPickerItem] = [WKPickerItem]()
        
        for d in eDegreesToShowList{
            let item = WKPickerItem()
            item.title = String(d)
            pickerItems2.append(item)
            
        }
        
        eDegreePicker.setItems(pickerItems2)
        
        //minuutti pickerit
        var pickerItems3:[WKPickerItem] = [WKPickerItem]()
        for d in MinutesList{
            let item = WKPickerItem()
            item.title = String(d)
            pickerItems3.append(item)
        }
        
        eMinutePicker.setItems(pickerItems3)
        nMinutePicker.setItems(pickerItems3)
        
        //desiaali pickerit
        var pickerItems4:[WKPickerItem] = [WKPickerItem]()
        for d in DesimalsList{
            let item = WKPickerItem()
            item.title = String(d)
            pickerItems4.append(item)
        }
        
        eDesimalPicker.setItems(pickerItems4)
        nDesimalPicker.setItems(pickerItems4)
        
        //säädetään pickereiden alotusarvot tallennettuihin
        //if let unit = defaults?.integer(forKey: "nDegreeKey") {
        //    nDegreePicker.setSelectedItemIndex(unit)
        //}
        nDegreePicker.setSelectedItemIndex(90)
        eDegreePicker.setSelectedItemIndex(180)
        
    }
    
    @IBAction func setButtonAction() {
        //lasketaan annetuista DMS koordinaateista DD muoto
        print("NORTH:")
        let ndesimalsToMinutes:Double = Double(selectedNDesimals) / 1000
        print(ndesimalsToMinutes)
        let nminutes:Double = Double(selectedNMinutes) + ndesimalsToMinutes
        print(nminutes)
        let nminutesToDegrees:Double = nminutes / 60
        print(nminutesToDegrees)
        let north:Double = Double(selectedNDegrees) + nminutesToDegrees
        print(north)
        print("EAST:")
        let edesimalsToMinutes:Double = Double(selectedEDesimals) / 1000
        print(edesimalsToMinutes)
        let eminutes:Double = Double(selectedEMinutes) + edesimalsToMinutes
        print(eminutes)
        let eminutesToDegrees:Double = eminutes / 60
        print(eminutesToDegrees)
        let east:Double = Double(selectedEDegrees) + eminutesToDegrees
        print(east)
        
        //lähetetään tiedot seuraavaan skriiniin
        coordinateContext.latitude = north
        coordinateContext.longitude = east
        print(coordinateContext)
        presentController(withName: "FinderScreen", context: coordinateContext)
        
    }
    @IBAction func nDegreeChangedAction(_ value: Int) {
        selectedNDegrees = nDecreesList[value]
        //jos mennään alle tietyn pisteen, niin muutetaan labeliksi S
        if value > 90{
            latitudeLabel.setText("Set Latitude(N):")
        }
        if value < 90{
            latitudeLabel.setText("Set Latitude(S):")
        }
        print(selectedNDegrees)
        //tallennetaan pickerin arvo
        //defaults?.setValue(nDecreesList[value], forKey: "nDegreeKey")
    }
    
    @IBAction func nMinutesChangedAction(_ value: Int) {
        selectedNMinutes = MinutesList[value]
        print(selectedNMinutes)
    }
    
    @IBAction func nDesimalsChangedAction(_ value: Int) {
        selectedNDesimals = DesimalsList[value]
        print(selectedNDesimals)
    }
    
    @IBAction func eDegreesChangedAction(_ value: Int) {
        selectedEDegrees = eDecreesList[value]
        //jos mennään alle tietyn pisteen muutetaan labeliksi W
        if value > 180{
            longitudeLabel.setText("And Longitude(E):")
        }
        if value < 180{
            longitudeLabel.setText("And Longitude(W):")
        }
        print(selectedEDegrees)
    }
    
    @IBAction func eMinutesChangedAction(_ value: Int) {
        selectedEMinutes = MinutesList[value]
        print(selectedEMinutes)
    }
    
    @IBAction func eDesimalsChangedAction(_ value: Int) {
        selectedEDesimals = DesimalsList[value]
        print(selectedEDesimals)
    }
    
}
