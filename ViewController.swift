//
//  ViewController.swift
//  AppleMapDirection
//
//  Created by Kashyap Patel on 24/08/17.
//  Copyright © 2017 DYMK. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ivSnapShot: UIImageView!

    var locationManager : AWLocationManager!

    var arrBikeLocation = [CLLocation(latitude: 39.92254, longitude: 116.37741),
                           CLLocation(latitude: 39.92415, longitude: 116.37724),
                           CLLocation(latitude: 39.92385, longitude: 116.36879),
                           CLLocation(latitude: 39.92384, longitude: 116.36501),
                           CLLocation(latitude: 39.92338, longitude: 116.36487),
                           
                           CLLocation(latitude: 39.92309, longitude: 116.36481),
                           CLLocation(latitude: 39.92282, longitude: 116.36479),
                           CLLocation(latitude: 39.92282, longitude: 116.36573),
                           CLLocation(latitude: 39.92284, longitude: 116.36704),
                           CLLocation(latitude: 39.92286, longitude: 116.36931),
                           
                           CLLocation(latitude: 39.92287, longitude: 116.36943),
                           CLLocation(latitude: 39.92218, longitude: 116.36950),
                           CLLocation(latitude: 39.92217, longitude: 116.36721),
                           CLLocation(latitude: 39.92198, longitude: 116.36701)]
    
    // ---------------------------------------------
    // MARK:- UIViewController LifeCycle
    // —————————————————————————————————————————————
    override func viewDidLoad() {
        super.viewDidLoad()
        initWithObjects()
        setLayout()
        setNavigationItems()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // ---------------------------------------------
    // MARK:- Init Function
    // —————————————————————————————————————————————
    func initWithObjects(){
        
        mapView.showsUserLocation = true
        
        locationManager = AWLocationManager.sharedInstance
        locationManager.beginLocationUpdating { (latitude, longitude, status, verboseMessage, error) in
            if error == nil{
                self.showBikeOnMap()
            }
        }
        locationManager.startLocationUpdating()
    }
    func setLayout(){
        
    }
    func setNavigationItems(){
        
    }
    
    // ---------------------------------------------
    // MARK:- Show Bike On Map
    // —————————————————————————————————————————————
    func showBikeOnMap(){
        
        for index in 0..<arrBikeLocation.count {
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = CLLocationCoordinate2DMake(arrBikeLocation[index].coordinate.latitude, arrBikeLocation[index].coordinate.longitude)
            mapView.addAnnotation(pinAnnotation)
        }
    }
    
    // ---------------------------------------------
    // MARK:- MapView Function
    // —————————————————————————————————————————————
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let mapRegion = MKCoordinateRegionMake(mapView.userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(mapRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            //annotationView?.canShowCallout = false
            annotationView?.image = UIImage(named: "BikeMapPinIcon")
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        for overlay:MKOverlay in self.mapView.overlays  {
            if !(overlay is MKUserLocation){
                self.mapView.remove(overlay)
            }
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(locationManager.latitude, locationManager.longitude), addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2DMake((view.annotation?.coordinate.latitude)!, (view.annotation?.coordinate.longitude)!), addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            var mapRegion = MKCoordinateRegionForMapRect(rect)
            print(mapRegion.span.latitudeDelta)
            print(mapRegion.span.longitudeDelta)
            mapRegion.span = MKCoordinateSpanMake(mapRegion.span.latitudeDelta + 0.020, mapRegion.span.longitudeDelta + 0.020)
            self.mapView.setRegion(mapRegion, animated: true)
        }
        
        mapView.deselectAnnotation(view.annotation, animated: true)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline{
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 3.0
            return polylineRenderer
        }
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    // ---------------------------------------------
    // MARK:- IBAction
    // —————————————————————————————————————————————
    @IBAction func btnCaptureTapped(_ sender: UIButton){
        self.captureImage2()
    }
    
    func captureImage2(){
        
        let rect = self.ivSnapShot.bounds
        
        let mapSnapshotOptions = MKMapSnapshotOptions()
        
        let region = mapView.region
        mapSnapshotOptions.region = region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = self.ivSnapShot.bounds.size
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        
        let snapshot = MKMapSnapshotter(options: mapSnapshotOptions)
        snapshot.start { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("\(error)")
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(mapSnapshotOptions.size, true, 0)
            snapshot.image.draw(at: .zero)
            
            let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            pinView.image = UIImage(named: "BikeMapPinIcon")
            let pinImage = pinView.image
            
            /*
            var point = snapshot.point(for: CLLocationCoordinate2D(latitude: self.locationManager.latitude, longitude: self.locationManager.longitude))
            
            if rect.contains(point) {
                point.x -= pinView.bounds.size.width / 2
                point.y -= pinView.bounds.size.height / 2
                pinImage?.draw(at: point)
            }
            */
            
            for i in 0...self.arrBikeLocation.count-1 {
                var point = snapshot.point(for: CLLocationCoordinate2D(latitude: self.arrBikeLocation[i].coordinate.latitude, longitude: self.arrBikeLocation[i].coordinate.longitude))
                if rect.contains(point) {
                    point.x -= pinView.bounds.size.width / 2
                    point.y -= pinView.bounds.size.height / 2
                    pinImage?.draw(at: point)
                }
            }
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            // draw original image into the context
            image?.draw(at: CGPoint.zero)
            
            // get the context for CoreGraphics
            let context = UIGraphicsGetCurrentContext()
            
            // set stroking width and color of the context
            context!.setLineWidth(2.0)
            context!.setStrokeColor(UIColor.orange.cgColor)
            
            // Here is the trick :
            // We use addLine() and move() to draw the line, this should be easy to understand.
            // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
            // Thus we use snapshot.point() to save the pain.
            context!.move(to: snapshot.point(for: self.arrBikeLocation[0].coordinate))
            for i in 0...self.arrBikeLocation.count-1 {
                context!.addLine(to: snapshot.point(for: self.arrBikeLocation[i].coordinate))
                context!.move(to: snapshot.point(for: self.arrBikeLocation[i].coordinate))
            }
            
            // apply the stroke to the context
            context!.strokePath()
            
            // get the image from the graphics context
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            
            DispatchQueue.main.async {
                self.ivSnapShot.image = resultImage
            }
        }
    }
    /*
    func drawLineOnImage(snapshot: MKMapSnapshot) -> UIImage {
        let image = snapshot.image
        
        // for Retina screen
        UIGraphicsBeginImageContextWithOptions(self.imageView.frame.size, true, 0)
        
        // draw original image into the context
        image.draw(at: CGPoint.zero)
        
        // get the context for CoreGraphics
        let context = UIGraphicsGetCurrentContext()
        
        // set stroking width and color of the context
        context!.setLineWidth(2.0)
        context!.setStrokeColor(UIColor.orange.cgColor)
        
        // Here is the trick :
        // We use addLine() and move() to draw the line, this should be easy to understand.
        // The diificult part is that they both take CGPoint as parameters, and it would be way too complex for us to calculate by ourselves
        // Thus we use snapshot.point() to save the pain.
        context!.move(to: snapshot.point(for: yourCoordinates[0]))
        for i in 0...yourCoordinates.count-1 {
            context!.addLine(to: snapshot.point(for: yourCoordinates[i]))
            context!.move(to: snapshot.point(for: yourCoordinates[i]))
        }
        
        // apply the stroke to the context
        context!.strokePath()
        
        // get the image from the graphics context
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end the graphics context 
        UIGraphicsEndImageContext()
        
        return resultImage!
    }
    */
    func captureImage(){
        
        ///* Type 1
        let mapSnapshotOptions = MKMapSnapshotOptions()
        
        // Set the region of the map that is rendered. (by one specified coordinate)
        // let location = CLLocationCoordinate2DMake(24.78423, 121.01836) // Apple HQ
        // let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        
        // Set the region of the map that is rendered. (by polyline)
        // var yourCoordinates = [CLLocationCoordinate2D]()  <- initinal this array with your polyline coordinates
        //let polyLine = MKPolyline(coordinates: &yourCoordinates, count: yourCoordinates.count)
        let region = mapView.region//MKCoordinateRegionForMapRect(polyLine.boundingMapRect)
        
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = self.ivSnapShot.bounds.size
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start() { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
            let image: UIImage = snapshot.image
            self.ivSnapShot.image = image
        }
    }
}

