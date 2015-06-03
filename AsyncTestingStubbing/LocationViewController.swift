import UIKit
import CoreLocation

public enum LocationState {
    case Searching
    case Found
    case Error(CLError)
}

public class LocationViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let lastLocation = self.lastLocation {
            updateShownLocation(lastLocation)
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private var _locationState = LocationState.Searching
    public var locationState: LocationState {
        return _locationState
    }
    
    private var locationCoordinator: LocationCoordinator?
    private var lastLocation: CLLocation?
    
    public func updateShownLocation(location: CLLocation) {
        let latitude = NSString(format: "%.06f", location.coordinate.latitude)
        let longitude = NSString(format: "%.06f", location.coordinate.longitude)
        locationLabel?.text = "\(latitude) - \(longitude)"
        locationLabel?.sizeToFit()
    }
    
    public func updateViewForLocationDone(done: Bool) {
        if done {
            self.activityIndicator?.stopAnimating()
            self.locationLabel?.hidden = false
        }
        else {
            self.activityIndicator?.startAnimating()
            self.locationLabel?.hidden = true
        }
    }
    
    public func showLocationWithCoordinator(coordinator: LocationCoordinator) {
        
        locationCoordinator = coordinator
        
        _locationState = .Searching
        if isViewLoaded() {
            updateViewForLocationDone(false)
        }
        
        coordinator.onUpdate { [unowned self] location in
            self.lastLocation = location
            self._locationState = .Found
            if self.isViewLoaded() {
                self.updateViewForLocationDone(true)
                self.updateShownLocation(location)
            }
        }
        
        coordinator.onFailure { [unowned self] error in
            let locationError = CLError(rawValue: error.code)
            self._locationState = LocationState.Error(locationError!)
            if self.isViewLoaded() {
                self.updateViewForLocationDone(true)
                self.locationLabel?.text = error.localizedDescription
                self.locationLabel?.sizeToFit()
            }
        }
    }
}

