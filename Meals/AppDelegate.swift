//
//  AppDelegate.swift
//  Meals
//
//  Created by 김승재 on 2018. 8. 9.
//  Copyright © 2018년 Me. All rights reserved.
//

import Cocoa
import CoreData

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //메뉴바에 들어갈 이미지를 그림
        if let button = statusItem.button {
            button.image = NSImage(named:"MenuBar")
            button.action = #selector(determineClick(sender:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        //밥 데이터가 있는가? 그러면 출력. 아니면 가져오기
        getMeal(date: Date())
        
        //창 그리기
        popover.contentViewController = POViewController.freshController()
        
        
        //창 바깥을 클릭했는지 판단
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
    }
    
    @objc func determineClick(sender: NSStatusBarButton){
        
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.rightMouseUp {
            constructMenu()
            statusItem.menu = nil
        }
        else {
            statusItem.menu = nil
            self.togglePopover(sender: sender)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        //self.saveContext()
    }
    
    
    
    func constructMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "종료", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        statusItem.popUpMenu(menu)
    }
    
    @objc func togglePopover(sender: Any?) {
        
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        eventMonitor?.start()
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        eventMonitor?.stop()
        popover.performClose(sender)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MealData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("이런! 에러잖아!\n \(error)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) 저장 전 수정사항 반영에 실패하였습니다")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) 종료 전 수정사항 반영에 실패하였습니다")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("캐시 저장 중 에러가 발생하였습니다.")
            print(nserror)
            /*
             
             아래 코드는 일반적인 App의 경우로, Core Data를 캐시로 사용하는 이 앱의 경우 필요하지 않음
             
             // Customize this code block to include application-specific recovery steps.
             let result = sender.presentError(nserror)
             if (result) {
             return .terminateCancel
             }
             
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
            */
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

    
}

@objc(Meal)
final class Meal: NSManagedObject {
    @NSManaged var breakfast: String?
    @NSManaged var lunch: String?
    @NSManaged var supper: String?
    @NSManaged var date: Int
}


