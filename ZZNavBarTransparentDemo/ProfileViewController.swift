//
//  ProfileViewController.swift
//  ZZNavBarTransparentDemo
//
//  Created by zerry on 2018/6/14.
//  Copyright © 2018年 zerry. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var statusBarShouldLight = true
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navBarBgAlpha = 0
        self.navBarTintColor = UIColor.defaultNavBarTintColor
        self.navBarColor = UIColor.init(red: 1, green: 0, blue: 0, alpha: 1)

        self.navBarTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]
        
        self.title = "第 \(self.navigationController?.viewControllers.count ?? 0) 个页面"
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if statusBarShouldLight {
            return .lightContent
        } else {
            return .default
        }
    }
    
    
    
    @IBAction func popWithCodeAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func popToRootAction(_ sender: UIButton) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    
}

extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath)
        cell.textLabel?.text = "第\(indexPath.row)行"
        return cell
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK:UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        //        print(scrollView)
        
        let contentOffsetY = scrollView.contentOffset.y
        let showNavBarOffsetY = 200 - topLayoutGuide.length
        
        
        //navigationBar alpha
        if contentOffsetY > showNavBarOffsetY  {
            var navAlpha = (contentOffsetY - (showNavBarOffsetY)) / 40.0
            if navAlpha > 1 {
                navAlpha = 1
            }
            navBarBgAlpha = navAlpha
            if navAlpha > 0.8 {
                navBarTintColor = UIColor.defaultNavBarTintColor
                navBarTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]
                statusBarShouldLight = false
                
            }else{
                navBarTintColor = UIColor.white
                navBarTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18)]
                statusBarShouldLight = true
            }
        }else{
            navBarBgAlpha = 0
            navBarTintColor = UIColor.white
            statusBarShouldLight = true
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.zz_viewWillAppear(animated)
    }
    
    
}
