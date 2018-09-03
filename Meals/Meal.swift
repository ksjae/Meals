//
//  Meal.swift
//  Meals
//
//  Created by 김승재 on 2018. 8. 10..
//  Copyright © 2018년 Me. All rights reserved.
//

import Foundation
import CoreData
import AppKit

var meals = [DailyMeal]()

struct DailyMeal : Codable{
    var date: Int
    var breakfast: [String?]
    var lunch: [String?]
    var supper: [String?]
    
    private enum CodingKeys: String, CodingKey {
        case date = "day"
        case breakfast = "breakfast"
        case lunch = "lunch"
        case supper = "dinner"
    }
    
}

var name_list = [NSManagedObject]()
var dataFetch = 0

func getMeal(date: Date){
    let calendar = Calendar.current
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let day = calendar.component(.day, from: date)
    //let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    //request.predicate = NSPredicate(format: "age = %@", "12")
    //request.returnsObjectsAsFaults = false
    var hasCache = false
    do {
        let result = try context.fetch(NSFetchRequest(entityName: "Data"))
        
        for data in result as! [NSManagedObject] {
            if data.value(forKey: "date") as? Int == day {
                hasCache = true
                break;
            }
        }
        
    } catch {
        
        print("FAILED")
    }
    if(!hasCache){
        print("NO CACHE")
        fetchMeal(forDate: date)
    }
}

func fetchMeal(forDate: Date){
    dataFetch = 1
    let calendar = Calendar.current
    let year = calendar.component(.year, from: forDate)
    let month = calendar.component(.month, from: forDate)
    let url = URL(string: "https://schoolmenukr.ml/api/high/E100002238?year=\(year)&month=\(month)")
    
    URLSession.shared.dataTask(with: url!, completionHandler: {
        (data, response, error) in
        if(error != nil){
            print("나는 노력했지만, 급식을 가져올 수 없었지.")
        }else{
            do{
                //TODO : "급식이 없습니다" 라는 String 처리
                let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                if let array = json!!["menu"] as? [Dictionary<String,Any>] {
                    for object in array {
                        if let object  = object as? [String: Any] { //경고라고? 그럼 이거 없이도 컴파일 하든가
                            // access all objects in array
                            var menu: DailyMeal = DailyMeal(date: 0, breakfast: [""], lunch: [""], supper: [""])
                            
                            //가끔 날짜가 nil인 경우가 있음
                            guard let daytoday = Int(object["date"] as! String) else{
                                continue
                            }
                            for (key, value) in object {
                                guard let value = value as? [String] else{
                                    //밥이 없다(아, 점, 저 중)
                                    continue
                                }
                                if key == "breakfast" {
                                    menu.breakfast = value
                                }
                                else if key == "lunch" {
                                    menu.lunch = value
                                }
                                else if key == "dinner" {
                                    menu.supper = value
                                }
                            }
                            menu.date = daytoday
                            meals.append (menu)
                        }
                    }
                }
            }
        }
    }).resume()
}

func savemeal(){
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: "Data", in: context)
    let mealSave = NSManagedObject(entity: entity!, insertInto: context)
    for meal in meals {
        mealSave.setValue(meal.date, forKey: "date")
        mealSave.setValue(meal.breakfast, forKey: "breakfast")
        mealSave.setValue(meal.lunch, forKey: "lunch")
        mealSave.setValue(meal.supper, forKey: "supper")
        do {
            try context.save()
        } catch {
            print("캐시 저장 실패")
        }
    }
    
}

func MealatTime(time: Date) -> [String?]{
    let calendar = Calendar.current
    let day = calendar.component(.day, from: time)
    let hour = calendar.component(.hour, from: time)
    for meal in meals {
        if meal.date == day {
            if hour<9 || hour>18 {
                return meal.breakfast
            }
            else if hour < 14 {
                return meal.lunch
            }
            else {
                return meal.supper
            }
        }
    }
    return [""]
}
/*
func save(name:String)
{
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    //Data is in this case the name of the entity
    let entity = NSEntityDescription.entityForName("Data",
                                                   inManagedObjectContext: managedContext)
    let options = NSManagedObject(entity: entity!,
                                  insertIntoManagedObjectContext:managedContext)
    
    options.setValue(name, forKey: "name")
    
    var error: NSError?
    if !managedContext.save(&error)
    {
        print("Could not save")
    }
    //uncomment this line for adding the stored object to the core data array
    //name_list.append(options)
}

func read()
{
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName: "Data")
    
    var error: NSError?
    let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        as [NSManagedObject]?
    
    if let results = fetchedResults
    {
        for i in 0 ..< results.count
        {
            let single_result = results[i]
            let out = single_result.valueForKey("name") as String
            println(out)
            //uncomment this line for adding the stored object to the core data array
            //name_list.append(single_result)
        }
    }
    else
    {
        print("cannot read")
    }
}

func clear_data()
{
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    let fetchRequest = NSFetchRequest(entityName: "Data")
    var error: NSError?
    let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error)
        as [NSManagedObject]?
    if let results = fetchedResults
    {
        for i in 0 ..< results.count
        {
            let value = results[i]
            managedContext.deleteObject(value)
            managedContext.save(nil)
        }
    }
}
 */
