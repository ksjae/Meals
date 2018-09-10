//
//  POViewController.swift
//  Meals
//
//  Created by 김승재 on 2018. 8. 10..
//  Copyright © 2018년 Me. All rights reserved.
//

import Cocoa
import Foundation

class POViewController: NSViewController {
    
    var dateRef = Date()
    var mealType = "breakfast" //breakfast, lunch and supper
    let calendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        dateLabel.stringValue = Title(date: dateRef, hour: calendar.component(.hour, from: dateRef))
        let zip = MenuforMeal(time: dateRef, type: mealType)
        mealLabel.stringValue = MealtoString(meal: zip as! [String])
    }
    
    @IBOutlet weak var dateLabel: NSTextField!
    
    @IBOutlet weak var mealLabel: NSTextField!
    
    @IBAction func previous(sender: NSButton){
        dateRef = GetDate(date: dateRef, type: mealType, prev: true)
        mealType = GetMealType(type: mealType, prev: true)
        let zip = MenuforMeal(time: dateRef, type: mealType)
        mealLabel.stringValue = MealtoString(meal: zip as! [String])
        dateLabel.stringValue = TitleByType(date: dateRef, type: mealType)
    }
    
    @IBAction func next(sender: NSButton){
        dateRef = GetDate(date: dateRef, type: mealType, prev: false)
        mealType = GetMealType(type: mealType, prev: false)
        let zip = MenuforMeal(time: dateRef, type: mealType)
        mealLabel.stringValue = MealtoString(meal: zip as! [String])
        dateLabel.stringValue = TitleByType(date: dateRef, type: mealType)
    }
    
    @IBAction func refresh(sender: NSButton){
        let zip = MenuatTime(time: dateRef)
        mealLabel.stringValue = MealtoString(meal: zip as! [String])
    }
    
    @IBAction func settings(sender: NSButton){
        print("Settings")
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

