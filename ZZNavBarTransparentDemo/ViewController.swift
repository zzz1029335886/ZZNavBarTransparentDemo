//
//  ViewController.swift
//  ZZNavBarTransparentDemo
//
//  Created by zerry on 2018/6/14.
//  Copyright © 2018年 zerry. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBarColor = UIColor.defaultNavBarColor
        self.navBarTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.zz_viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

