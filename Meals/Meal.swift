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
    //let calendar = Calendar.current
    //let appDelegate = NSApplication.shared.delegate as! AppDelegate
    //let context = appDelegate.persistentContainer.viewContext
    //let day = calendar.component(.day, from: date)
    //let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
    //request.predicate = NSPredicate(format: "age = %@", "12")
    //request.returnsObjectsAsFaults = false
    //var hasCache = false
    let hasCache = false //캐시? 나중에...
    /* WILL CRASH!
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
     */
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
            print("나는 노력했지만, 급식을 가져올 수 없었지.\nfetchMeal에서 오류 발생. 인터넷에서 받아오기 실패.")
        } else{
            do{
                let json = ((try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]) as [String : Any]??)
                if let array = json!!["menu"] as? [Dictionary<String,Any>] { //1개의 Dictionary에 1일치 식단이 있음
                    for object in array { // access all objects in array
                        
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
                            
                            //왜인지는 모르겠으나, breakfast-lunch-dinner 순이 아니므로 이렇게 한다
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
        //savemeal() WILL ALSO CRASH
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

func MenuatTime(time: Date) -> [String?]{
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

func MenuforMeal(time: Date, type: String) -> [String?]{
    let calendar = Calendar.current
    let day = calendar.component(.day, from: time)
    for meal in meals {
        if meal.date == day {
            if type == "breakfast" {
                return meal.breakfast
            }
            else if type == "lunch" {
                return meal.lunch
            }
            else {
                return meal.supper
            }
        }
    }
    return [""]
}

func MealtoString(meal : [String]) -> String{
    var printedmeal = ""
    for m in meal {
        //각 메뉴에서 . 및 알러지 정보 숫자 제거
        let numberlessMeal = (m.components(separatedBy: CharacterSet.decimalDigits)).joined(separator: "")
        
        printedmeal = printedmeal + numberlessMeal.replacingOccurrences(of: ".", with: "")
        printedmeal =  printedmeal.replacingOccurrences(of: "_", with: "")
        printedmeal = printedmeal + "\n"
    }
    return printedmeal
}

func GetDate(date: Date, type: String, prev: Bool) -> Date {
    if(prev && type == "breakfast"){
        return Calendar.current.date(byAdding: .day, value: -1, to: date)!
    }
    else if (!prev && type == "supper"){
        return Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }
    return date
}

func GetMealType(type: String, prev: Bool) -> String {
    if(prev) {
        if(type == "breakfast"){
            return "supper"
        }
        if(type == "lunch"){
            return "breakfast"
        }
        if(type == "supper"){
            return "lunch"
        }
    }
    else {
        if(type == "breakfast"){
            return "lunch"
        }
        if(type == "lunch"){
            return "supper"
        }
        if(type == "supper"){
            return "breakfast"
        }
    }
    return "breakfast"
}

func Title(date: Date) -> String{
    var labelString = ""
    var dateRef = date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/d"
    var dateString = dateFormatter.string(from: dateRef)
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    
    if hour<9 {
        labelString = dateString + " - 아침"
    }
    else if hour < 14 {
        labelString = dateString + " - 점심"
    }
    else if hour < 19 {
        labelString = dateString + " - 저녁"
    }
    else {
        dateRef = calendar.date(byAdding: .day, value: 1, to: dateRef)!
        dateString = dateFormatter.string(from: dateRef)
        labelString = dateString + " - 아침" //내일 아침
    }
    return labelString
}

func TitleByType(date: Date, type: String) -> String {
    var labelString = ""
    let dateRef = date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M/d"
    let dateString = dateFormatter.string(from: dateRef)
 
    if type == "breakfast" {
        labelString = dateString + " - 아침"
    }
    else if type == "lunch" {
        labelString = dateString + " - 점심"
    }
    else if type == "supper" {
        labelString = dateString + " - 저녁"
    }
    return labelString
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
