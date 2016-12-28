//
//  PhotoPageContainerViewController.swift
//  SimplePhotoViewer
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}

class PhotoPageContainerViewController: UIViewController {
    
    weak var delegate: PhotoPageContainerViewControllerDelegate?
    
    var pageViewController: UIPageViewController {
        return self.childViewControllers[0] as! UIPageViewController
    }
    
    var photos: [UIImage]!
    var currentIndex = 0
    var nextIndex: Int?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGestureRecognizer: UITapGestureRecognizer!
    var fullScreen: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanWith(gestureRecognizer:)))
        self.pageViewController.view.addGestureRecognizer(self.panGestureRecognizer)
        
        self.singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTapWith(gestureRecognizer:)))
        self.pageViewController.view.addGestureRecognizer(self.singleTapGestureRecognizer)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.image = self.photos[self.currentIndex]
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        let viewControllers = [
            vc
        ]
        
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            print("Began")
        } else {
            print("Else")
        }
    }
    
    func didSingleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if self.fullScreen {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.view.backgroundColor = .white
                            self.navigationController?.setNavigationBarHidden(false, animated: true)
            }, completion: { completed in
                self.fullScreen = false
            })
        } else {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.view.backgroundColor = .black
                            self.navigationController?.setNavigationBarHidden(true, animated: true)
            }, completion: { completed in
                self.fullScreen = true
            })
        }
        
    }
}

extension PhotoPageContainerViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == 0 {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        vc.image = self.photos[currentIndex - 1]
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.photos.count - 1) {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PhotoZoomViewController.self)") as! PhotoZoomViewController
        self.singleTapGestureRecognizer.require(toFail: vc.doubleTapGestureRecognizer)
        vc.image = self.photos[currentIndex + 1]
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextVC = pendingViewControllers.first as? PhotoZoomViewController else {
            return
        }
        self.nextIndex = self.photos.index(of: nextVC.image!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {
            self.currentIndex = self.nextIndex!
            self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }
        
        self.nextIndex = nil
    }
    
}

extension PhotoPageContainerViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let zoomAnimator = PhotoZoomAnimator(duration: 0.5, presenting: true)
        let nav = presenting as! UINavigationController
        let presentingViewController = nav.viewControllers[0] as! ViewController
        zoomAnimator.fromDelegate = presentingViewController
        zoomAnimator.toDelegate = self
        return zoomAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let zoomAnimator = PhotoZoomAnimator(duration: 0.5, presenting: false)
        let nav = self.presentingViewController as! UINavigationController
        let presentingViewController = nav.viewControllers[0] as! ViewController
        zoomAnimator.fromDelegate = self
        zoomAnimator.toDelegate = presentingViewController
        return zoomAnimator
    }
    
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        
//        return ZoomDismissalInteractionController()
//    }
}

extension PhotoPageContainerViewController: PhotoZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: PhotoZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: PhotoZoomAnimator) {
        
    }
    
    func referenceImageView(for zoomAnimator: PhotoZoomAnimator) -> UIImageView? {
        
        let currentViewController = self.pageViewController.viewControllers![0] as! PhotoZoomViewController
        return currentViewController.imageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: PhotoZoomAnimator) -> CGRect? {
        let currentViewController = self.pageViewController.viewControllers![0] as! PhotoZoomViewController
        return currentViewController.scrollView.convert(currentViewController.imageView.frame, to: currentViewController.view)
    }
}
