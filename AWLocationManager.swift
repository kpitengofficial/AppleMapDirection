//
//  IDLocationManager.swift
//  TagCollectionView
//
//  Created by Pradhyuman on 04/02/16.
//  Copyright © 2016 Openxcell. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

typealias AWLocationCompletionHandler = ((_ latitude:Double, _ longitude:Double, _ status:String, _ verboseMessage:String, _ error:String?)->())?

public class AWLocationManager : NSObject, CLLocationManagerDelegate{
    
    private var completionHandler:AWLocationCompletionHandler
   
    private var locationStatus : NSString = "Calibrating"
    private var verboseMessage = "Calibrating"
    
    var locationManager : CLLocationManager!
    
    internal var latitude : Double = 0
    internal var longitude : Double = 0
    
    
    private let verboseMessageDictionary = [
    CLAuthorizationStatus.notDetermined:"You have not yet made a choice with regards to this application.",
    CLAuthorizationStatus.restricted:"This application is not authorized to use location services. You must turn on 'Always' in the Location Services Settings.",
    CLAuthorizationStatus.denied:"This application is denied to use location services. You must turn on 'Always' in the Location Services Settings.",
    CLAuthorizationStatus.authorizedAlways:"App is Authorized to use location services.",
    CLAuthorizationStatus.authorizedWhenInUse:"You have granted authorization to use your location only when the app is visible to you."]
    
    
    class var sharedInstance : AWLocationManager {
        struct Static {
            static let instance : AWLocationManager = AWLocationManager()
        }
        return Static.instance
    }
    
//    private override init(){
    override init(){
        super.init()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.distanceFilter = 1000
    }
    
    func beginLocationUpdating(completionHandler:((_ latitude:Double, _ longitude:Double, _ status:String, _ verboseMessage:String, _ error:String?)->())? = nil){
        
        // Set the completion handler
        self.completionHandler = completionHandler
        
        // Set the delegate
        locationManager.delegate = self
        /*
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)){
            locationManager.requestAlwaysAuthorization()
        }*/
        
        locationManager.requestAlwaysAuthorization()
        
        // Enable automatic pausing
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Specify the type of activity your app is currently performing
        locationManager.activityType = .automotiveNavigation
        
        // Enable background location updates
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        // Start location updates
        locationManager.startUpdatingLocation()
        
        checkLocationManagerAuthorizationStatus()
    }
    func startLocationUpdating(){
        
        // Set the delegate
        locationManager.delegate = self
        
        /*
        if locationManager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)){
            locationManager.requestAlwaysAuthorization()
        }*/
        
        locationManager.requestAlwaysAuthorization()
        
        // Enable automatic pausing
        locationManager.pausesLocationUpdatesAutomatically = true
        
        // Specify the type of activity your app is currently performing
        locationManager.activityType = .automotiveNavigation
        
        // Enable background location updates
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        // Start location updates
        locationManager.startUpdatingLocation()
    }
    func endLocationUpdating(){
        
        // Clear delegate
        locationManager.delegate = nil
        
        // Stop location updates when they aren't needed anymore
        locationManager.stopUpdatingLocation()
        
        // Disable background location updates when they aren't needed anymore
        if #available(iOS 9.0, *) {
            self.locationManager.allowsBackgroundLocationUpdates = false
        } else {
            // Fallback on earlier versions
        }
    }
    func clearLocation(){
        latitude = 0
        longitude = 0
    }
    func checkLocationManagerAuthorizationStatus(){
        var strStatus : String? = nil
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.restricted{
            strStatus = "Location services are restricted!"
        } else if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied){
            strStatus = "Location services are denied!"
        } else if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined){
            strStatus = "Location services are notdetermined!"
        }
        
        if strStatus != nil{
            completionHandler?(latitude, longitude, strStatus! ,verboseMessageDictionary[CLLocationManager.authorizationStatus()]!, "YES")
        }

    }
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation : CLLocation = locations.last!
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        
        //print("=====didUpdateLocations=====")
        //print(latitude)
        //print(longitude)
        //print("=====")
        
        completionHandler?(latitude, longitude, locationStatus as String,verboseMessage, nil)
        self.endLocationUpdating()
    }
    @nonobjc public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            
            var hasAuthorised = false
            let verboseKey = status
            switch status {
            case CLAuthorizationStatus.restricted:
                locationStatus = "Location services are restricted!"
            case CLAuthorizationStatus.denied:
                locationStatus = "Location services are denied!"
            case CLAuthorizationStatus.notDetermined:
                locationStatus = "Location services are notdetermined!"
            default:
                locationStatus = "Allowed access"
                hasAuthorised = true
            }
            
            let verboseMessage = verboseMessageDictionary[verboseKey]!
            
            if (hasAuthorised == true) {
                startLocationUpdating()
            }else{
                
                clearLocation()
                if (!locationStatus.isEqual(to: "Denied access")){
                    if(completionHandler != nil){
                        completionHandler?(latitude, longitude, locationStatus as String, verboseMessage,"YES")
                    }
                }
            }
            
    }
}
