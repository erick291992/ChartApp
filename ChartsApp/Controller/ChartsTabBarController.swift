//
//  ChartsTabBarController.swift
//  ChartsApp
//
//  Created by Erick Manrique on 3/8/18.
//  Copyright © 2018 Erick Manrique. All rights reserved.
//

import Foundation
import UIKit

class ChartsTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chartsController = ChartsController()
        let navigationController1 = UINavigationController(rootViewController: chartsController)
        navigationController1.title = "Search"
        navigationController1.navigationBar.tintColor = .white
//        navigationController1.tabBarItem.image = UIImage(named: "Search")

        viewControllers = [navigationController1]
        
        self.tabBar.tintColor = .red
        self.tabBar.barTintColor = .white
        
    }
}
