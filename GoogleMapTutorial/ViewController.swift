//
//  ViewController.swift
//  GoogleMapTutorial
//
//  Created by HS on 06/01/21.
//

import GoogleMaps
import GooglePlaces
import UIKit


struct ShareModel {
    var address: GMSAddress?
    var location: CLLocationCoordinate2D?
}

class ViewController: UIViewController {
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblLat: UILabel!
    @IBOutlet var lblLong: UILabel!

    var locationManager = CLLocationManager()
    var shareModel: ShareModel? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initMap()
        // Location Manager code to fetch current location
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    @IBAction func shareBtnAction(sender: UIButton){
        if let model = shareModel {
           // share anywhere where you want.
            print(model)
        } else {
            //  show error
        }
        
        
    }
    
    private func initMap() {
        mapView.settings.myLocationButton = true
    }
    
    
   private func reverseGeo(coordinates: CLLocationCoordinate2D?) {
        if let point = coordinates {
            let geocoder = GMSGeocoder()
            geocoder.reverseGeocodeCoordinate(point) { response, error in
                //
                if error != nil {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    if let places = response?.results() {
                        if let place = places.first {
                            if let lines = place.lines {
                                print("GEOCODE: Formatted Address: \(lines)")
                            }

                            self.lblLocation.text = "\(place.thoroughfare ?? ""), \(place.locality ?? "")"
                            self.lblLat.text = "\(coordinates?.latitude ?? 0.0)"
                            self.lblLong.text = "\(coordinates?.longitude ?? 0.0)"
                            
                            //        Creates a marker in the center of the map.
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: coordinates?.latitude ?? 0.0, longitude: coordinates?.longitude ?? 0.0)
                            marker.title = place.thoroughfare
                            marker.snippet = place.locality
                            marker.map = self.mapView
                            self.shareModel = ShareModel(address: place, location: coordinates)
                        } else {
                            print("GEOCODE: nil first in places")
                        }
                    } else {
                        print("GEOCODE: nil in places")
                    }
                }
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    // Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        reverseGeo(coordinates: location?.coordinate) // reverse geocode
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        mapView.animate(to: camera)
        // Finally stop updating location otherwise it will come again and again in this delegate
        locationManager.stopUpdatingLocation()
    }

}
