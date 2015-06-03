import UIKit
import XCTest

import CoreLocation

import AsyncTestingStubbing

class AsyncTestingStubbingTests: XCTestCase {
    
    class STUB_LocationCoordinator: LocationCoordinator {
        
        override init() {
            super.init()
            
            super.locationManager.stopUpdatingLocation()
            super.locationManager.delegate = nil
        }
        
        func forceLocation(location: CLLocation) {
            locationManager(locationManager, didUpdateLocations: [location])
        }
        
        func forceError(locationError: CLError) {
            locationManager(locationManager, didFailWithError: NSError(domain: "STUB", code: locationError.rawValue, userInfo: [NSLocalizedDescriptionKey:"STUB fail"]))
        }
        
        func forceRandomDelayedLocations(delay: Double, times: Int) {
            every(delay, times: times) { [unowned self] stop in
                let location = CLLocation(latitude: Double(arc4random()%100), longitude: Double(arc4random()%100))
                self.locationManager(self.locationManager, didUpdateLocations: [location])
            }
        }
        
        func forceDelayedErrorLocationUnknown(delay: Double) {
            after(delay) {
                self.locationManager(self.locationManager, didFailWithError: NSError(domain: "STUB", code: CLError.LocationUnknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"STUB fail"]))
            }
        }
    }
    
    func testLocation() {
        if let vc = mainViewController() {
            let coordinator = STUB_LocationCoordinator()
            vc.showLocationWithCoordinator(coordinator)
            vc.locationState.assertState(.Searching)
            coordinator.forceLocation(CLLocation(latitude: 40, longitude: 10))
            vc.locationState.assertState(.Found)
        }
        else {
            fail("this will never happen")
        }
    }
    
    func testError() {
        if let vc = mainViewController() {
            let coordinator = STUB_LocationCoordinator()
            vc.showLocationWithCoordinator(coordinator)
            vc.locationState.assertState(.Searching)
            coordinator.forceError(.Denied)
            vc.locationState.assertState(.Error(.Denied))
        }
        else {
            fail("this will never happen")
        }
    }
    
    func testDelayedLocation() {
        if let vc = mainViewController() {
            let locationExpectation = expectationWithDescription("locationExpectation")
            let coordinator = STUB_LocationCoordinator()
            vc.showLocationWithCoordinator(coordinator)
            vc.locationState.assertState(.Searching)
            coordinator.forceRandomDelayedLocations(0.25, times:3)
            after(0.5) {
                vc.locationState.assertState(.Found)
                after(0.25) {
                    vc.locationState.assertState(.Found)
                    locationExpectation.fulfill()
                }
            }
            vc.locationState.assertState(.Searching)
            waitForExpectationsWithTimeout(1, handler: nil)
        }
        else {
            fail("this will never happen")
        }
    }
    
    func testDelayedError() {
        if let vc = mainViewController() {
            let locationExpectation = expectationWithDescription("locationExpectation")
            let coordinator = STUB_LocationCoordinator()
            vc.showLocationWithCoordinator(coordinator)
            vc.locationState.assertState(.Searching)
            coordinator.forceDelayedErrorLocationUnknown(0.25)
            after(0.5) {
                vc.locationState.assertState(.Error(.LocationUnknown))
                locationExpectation.fulfill()
            }
            vc.locationState.assertState(.Searching)
            waitForExpectationsWithTimeout(1, handler: nil)
        }
        else {
            fail("this will never happen")
        }
    }
}

/// MARK: utility

/// è buona pratica mantenere il tipo opzionale, e unwrapparlo successiamente con if-let
func mainViewController () -> LocationViewController? {
    
    UIApplication.sharedApplication().keyWindow.assertNotNil("keyWindow")
    UIApplication.sharedApplication().keyWindow?.rootViewController.assertNotNil("rootViewController")
    
    if let navController = UIApplication.sharedApplication().keyWindow?.rootViewController as? UINavigationController {
        if let mainViewController = navController.topViewController as? LocationViewController {
            return mainViewController
        }
        else {
            "topViewController".failType("LocationViewController")
            return nil
        }
    }
    else {
        "rootViewController".failType("UINavigationController")
        return nil
    }
}

extension String {
    func failType(className: String) {
        XCTAssert(false, self + " is not of " + className + " class")
    }
}

extension Optional {
    func assertNotNil (valueName: String) {
        XCTAssert(self != nil, valueName + " is nil")
    }
}

extension LocationState {
    func assertState(state: LocationState) {
        switch (self, state) {
        case (.Searching, .Searching):
            break
        case (.Found,.Found):
            break
        case (.Error(let selfLocationError), .Error(let requiredLocationError)):
            XCTAssert(selfLocationError == requiredLocationError, "wrong location error")
        default:
            XCTAssert(false, "wrong location state")
        }
    }
}

func fail (message: String) {
    XCTAssert(false, message)
}

extension UIColor {
    func equalTo(otherColor: UIColor) -> Bool {
        return CGColorEqualToColor(self.CGColor, otherColor.CGColor)
    }
}

func after(seconds: Double, #action: () ->()) {
    let afterTime = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(afterTime, dispatch_get_main_queue(), action)
}

func every(seconds: Double, #times: Int, #action: (stop: () -> ()) -> ()) {
    
    var shouldStop = false

    if times > 0 {
        after(seconds) {
            action {
                shouldStop = true
            }
            if shouldStop == false {
                every(seconds, times: times-1, action: action)
            }
        }
    }
}




