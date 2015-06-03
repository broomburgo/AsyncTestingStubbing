import Foundation
import CoreLocation

public class LocationCoordinator: NSObject {
    
    public let locationManager: CLLocationManager
    
    public override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    private var updated: (CLLocation -> ())?
    public func onUpdate(value: CLLocation -> ()) {
        updated = value
    }
    
    private var failed: (NSError -> ())?
    public func onFailure(value: NSError -> ()) {
        failed = value
    }
}

extension LocationCoordinator: CLLocationManagerDelegate {
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        if let updated = self.updated {
            updated(location)
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if let failed = self.failed {
            failed(error)
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}