//
//  QuotesViewController.swift
//  Meals
//
//  Created by 김승재 on 2018. 8. 10..
//  Copyright © 2018년 Me. All rights reserved.
//

import Cocoa

class QuotesViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
extension QuotesViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> QuotesViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "QuotesViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? QuotesViewController else {
            fatalError("Why cant i find QuotesViewController? - Check Main.storyboard")
        }
        fetchMeal(forDate: Date(), justToday: false)
        return viewcontroller
    }
}
