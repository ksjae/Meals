//
//  POViewController.swift
//  Meals
//
//  Created by 김승재 on 2018. 8. 10..
//  Copyright © 2018년 Me. All rights reserved.
//

import Cocoa

class POViewController: NSViewController {
    
    @objc dynamic var dateRef = Date()
    @objc dynamic var refreshClicked = 0
    @objc dynamic var settingClicked = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBOutlet weak var dateLabel: NSTextField!
    
    @IBOutlet weak var mealLabel: NSTextField!
    
    @IBAction func previous(sender: NSButton){
        dateRef = Calendar.current.date(byAdding: .day, value: 1, to: dateRef)!
    }
    
    @IBAction func next(sender: NSButton){
        dateRef = Calendar.current.date(byAdding: .day, value: -1, to: dateRef)!
    }
    
    @IBAction func refresh(sender: NSButton){
        refreshClicked+=1
    }
    
    @IBAction func settings(sender: NSButton){
        settingClicked+=1
    }
    
    @IBOutlet weak var spinningwheel: NSProgressIndicator!
    

}
extension POViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> POViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "POViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? POViewController else {
            fatalError("급식을 표시할 화면을 만들 수 없습니다. 다시 실행시키거나 컴퓨터를 재시작해 보세요.")
        }
        return viewcontroller
    }
}

