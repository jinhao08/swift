//
//  HappinessViewController.swift
//  Happiness
//
//  Created by englab on 4/25/15.
//  Copyright (c) 2015 englab. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController, FaceViewDataSource
{
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.dataSource = self
<<<<<<< HEAD
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: "scale:"))
//            faceView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "changeHappiness:"))
        }
    }
    
    private struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    
    @IBAction func changeHappiness(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = sender.translationInView(faceView)
            let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
            if happinessChange != 0 {
                happiness += happinessChange
                sender.setTranslation(CGPointZero, inView: faceView)
            }
        default: break
        }
    }
    
    var happiness: Int = 100 { // 0 = very sad, 100 ecstatic
=======
        }
    }
    
    var happiness: Int = 50 { // 0 = very sad, 100 ecstatic
>>>>>>> c711bde8aac12ac8c89688f042a5b1df8b656454
        didSet {
            happiness = min(max(happiness, 0), 100)
            println("happiness = \(happiness)")
            updateUI()
        }
    }
    
    private func updateUI()
    {
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(sender: FaceView) -> Double? {
<<<<<<< HEAD
        return Double(happiness - 50)/50
=======
        return Double(happiness)/100
>>>>>>> c711bde8aac12ac8c89688f042a5b1df8b656454
    }
    
}
