//
//  ViewController.swift
//  MovieBox
//
//  Created by zerry on 2018/7/9.
//  Copyright © 2018年 zerry. All rights reserved.
//

import UIKit

class ImageNavBarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBarImageIsDifferent = true
        self.view.backgroundColor = .white
        self.navBarTintColor = .white

        self.title = "第 \(self.navigationController?.viewControllers.count ?? 0 + 1) 个界面"
        
        //        self.navBarColor = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 1)
        
        let button = UIButton.init(type: .contactAdd)
        button.center = self.view.center
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        view.addSubview(button)
        
        // Color Image
        if (self.navigationController?.viewControllers.count)! % 2 == 0 {
            //            self.navBarBgAlpha = 0
            // color image
            self.navBarImage = IMAGEWITHCOLOR(RGBCOLOR(128, 0, 0))
            
        }else{
            //            self.navBarBgAlpha = 1
            self.navBarImage = IMAGEWITHCOLOR(RGBCOLOR(128, 128, 0))

        }
        
        // Image
//        if (self.navigationController?.viewControllers.count)! % 2 == 0 {
//            //            self.navBarBgAlpha = 0
//            self.navBarImage = UIImage.init(named: "img_navigation1")
//
//        }else{
//            //            self.navBarBgAlpha = 1
//            self.navBarImage = UIImage.init(named: "img_navigation")
//
//        }
        
    }
    
    @objc func click() {
        self.navigationController?.pushViewController(ImageNavBarViewController(), animated: true)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        zz_viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        zz_viewWillAppear(animated)
    }
    
    
    
}

