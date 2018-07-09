//
//  UIImageNavigationViewController.swift
//  ZZNavBarTransparentDemo
//
//  Created by zerry on 2018/7/9.
//  Copyright © 2018年 zerry. All rights reserved.
//

import UIKit

class UIImageNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationBar
        navBar.setBackgroundImage(UIImage.init(), for: .default)
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navBarImageIsDifferent = true
        
    }

}
