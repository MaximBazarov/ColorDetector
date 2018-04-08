//
//  AppDelegate.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coordinator: Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        coordinator = Coordinator(window: window!)
        coordinator!.presentMainScreen()
        return true
    }

}
