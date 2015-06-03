import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let viewController = LocationViewController(nibName: "ViewController", bundle: nil)
        viewController.showLocationWithCoordinator(LocationCoordinator())
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.translucent = false
        
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

