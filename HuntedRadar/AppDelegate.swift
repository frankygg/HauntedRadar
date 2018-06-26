//
//  AppDelegate.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/2.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FirebaseAuth
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        setInitialFirebaseLogInStatus()
        // 設定statusbar為白色
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent

        IQKeyboardManager.shared.enable = true

        IQKeyboardManager.shared.enableAutoToolbar = false

        IQKeyboardManager.shared.shouldResignOnTouchOutside = true

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor(red: 255/255, green: 61/255, blue: 59/255, alpha: 1)
        self.window!.makeKeyAndVisible()

        //隱藏tabbar上架
        var navigationController: UIViewController
        if Auth.auth().currentUser == nil {
            navigationController = UIStoryboard.loginStoryboard().instantiateInitialViewController()!
            if let controller = UIStoryboard.loginStoryboard().instantiateInitialViewController() as? LoginViewController {
               navigationController = controller
                controller.isFromAppFlag = true
                self.window!.rootViewController = controller
            }
        } else {
            navigationController = UIStoryboard.customTabBarStoryboard().instantiateInitialViewController()!
            self.window!.rootViewController = navigationController
        }

        // logo mask
        navigationController.view.layer.mask = CALayer()
        navigationController.view.layer.mask?.contents = UIImage(named: "ghost")!.cgImage
        navigationController.view.layer.mask?.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        navigationController.view.layer.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        navigationController.view.layer.mask?.position = CGPoint(x: navigationController.view.frame.width / 2, y: navigationController.view.frame.height / 2)

        // logo mask background view
        let maskBgView = UIView(frame: navigationController.view.frame)
        maskBgView.backgroundColor = UIColor.white
        navigationController.view.addSubview(maskBgView)
        navigationController.view.bringSubview(toFront: maskBgView)

        handleAnimation(maskBgView, navigationController)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active
        //state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the
        //application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        //See also applicationDidEnterBackground:.
    }

    func setInitialFirebaseLogInStatus() {
        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: "hasRunBefore") == false {
            print("The app is launching for the first time. Setting UserDefaults...")

            do {
                try Auth.auth().signOut()
            } catch {

            }

            // Update the flag indicator
            userDefaults.set(true, forKey: "hasRunBefore")
            userDefaults.synchronize() // This forces the app to update userDefaults

            // Run code here for the first launch

        } else {
            print("The app has been launched before. Loading UserDefaults...")
            // Run code here for every other launch but the first
        }
    }

    func handleAnimation(_ maskBgView: UIView, _ navigationController: UIViewController) {
        // logo mask animation
        let transformAnimation = CAKeyframeAnimation(keyPath: "bounds")
        transformAnimation.delegate = self
        transformAnimation.duration = 1
        transformAnimation.beginTime = CACurrentMediaTime() + 1 //add delay of 1 second
        let initalBounds = NSValue(cgRect: (navigationController.view.layer.mask?.bounds)!)
        let secondBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 50, height: 50))
        let finalBounds = NSValue(cgRect: CGRect(x: 0, y: 0, width: 5000, height: 5000))
        transformAnimation.values = [initalBounds, secondBounds, finalBounds]
        transformAnimation.keyTimes = [0, 0.5, 1]
        transformAnimation.timingFunctions = [CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut), CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)]
        transformAnimation.isRemovedOnCompletion = false
        transformAnimation.fillMode = kCAFillModeForwards
        navigationController.view.layer.mask?.add(transformAnimation, forKey: "maskAnimation")
        // logo mask background view animation
        UIView.animate(withDuration: 0.1,
                       delay: 1.35,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        maskBgView.alpha = 0.0
        },
                       completion: { _ in
                        maskBgView.removeFromSuperview()
        })

        // root view animation
        UIView.animate(withDuration: 0.25,
                       delay: 1.3,
                       options: UIViewAnimationOptions.transitionCurlUp,
                       animations: {
                        self.window!.rootViewController!.view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.3,
                                       delay: 0.0,
                                       options: UIViewAnimationOptions.curveEaseInOut,
                                       animations: {
                                        self.window!.rootViewController!.view.transform = CGAffineTransform.identity
                        },
                                       completion: nil
                        )
        })
    }

}

extension AppDelegate: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.window!.rootViewController!.view.layer.mask = nil

    }
}
