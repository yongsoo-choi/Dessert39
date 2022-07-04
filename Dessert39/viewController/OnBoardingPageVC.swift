//
//  OnBoardingPageVC.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/10/13.
//

import UIKit

class OnBoardingPageVC: UIPageViewController {
    
    var pages = [UIViewController]()
    var pageControl = UIPageControl()
    let startIndex = 0
    var curIndex = 0 {
        didSet{
            pageControl.currentPage = curIndex
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPageViewController()
        setPageController()
    }
    
    func setPageViewController() {
        
        let item1 = OnBoardingItem.init(nibName: "OnBoardingItem", bundle: nil)
        item1.titleImage = UIImage(named: "onboarding_title1")
        item1.image = UIImage(named: "onboarding_image1")
        
        let item2 = OnBoardingItem.init(nibName: "OnBoardingItem", bundle: nil)
        item2.titleImage = UIImage(named: "onboarding_title2")
        item2.image = UIImage(named: "onboarding_image2")
        
        let item3 = OnBoardingItem.init(nibName: "OnBoardingItem", bundle: nil)
        item3.titleImage = UIImage(named: "onboarding_title3")
        item3.image = UIImage(named: "onboarding_image3")
        item3.btnDisabled = false
        
        pages.append(item1)
        pages.append(item2)
        pages.append(item3)
        
        setViewControllers([item1], direction: .forward, animated: true, completion: nil)
        
        self.dataSource = self
        
    }
    
    func setPageController() {
        
        self.view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColorFromRGB.colorInit(1.0, rgbValue: 0xAEAEAE)
        pageControl.pageIndicatorTintColor = UIColorFromRGB.colorInit(0.48, rgbValue: 0xAEAEAE)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = startIndex
        pageControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
    }
    
}

// MARK: - Extension
extension OnBoardingPageVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        self.curIndex = currentIndex
        
        if currentIndex == 0 {
            return nil
        } else {
            return pages[currentIndex - 1]
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let currentIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        self.curIndex = currentIndex
        
        if currentIndex == pages.count - 1 {
            return nil
        } else {
            return pages[currentIndex + 1]
        }
        
    }
    
}
