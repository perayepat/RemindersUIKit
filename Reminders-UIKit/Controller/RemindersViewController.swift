/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

class RemindersViewController: UITableViewController {
  var list: List?
  var context: NSManagedObjectContext?
   //fetch reminders from the data store
  private lazy var fetchedResultsController: NSFetchedResultsController<Reminder> = {
    let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    //Predicate
    // Fetch only the reminders that match this list
    let predicate  = NSPredicate(format: "%K == %@", "list.title", self.list!.title)
    fetchRequest.predicate = predicate
    
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: nil)
    
    frc.delegate = self
    return frc
    
  }()
  
  //diffable data source
  //using NSMangaedObjectId instead of Reminder becuase insances of NSManagedObjectID contain all the information needed by the fetch result controller to see what changed
  lazy var dataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> = {
    let dataSource = UITableViewDiffableDataSource<String, NSManagedObjectID>(tableView: tableView) { (tableView, indexPath, objectId) -> UITableViewCell? in
      //retrive instance of reminder
      //Using NSmanagedObeject
      guard let reminder = try? self.context?.existingObject(with: objectId) as? Reminder else {return nil}
      let cell = UITableViewCell(style: .default, reuseIdentifier: "ReminderCell")
      cell.textLabel?.text = reminder.title
      return cell
    }
    tableView.dataSource = dataSource
    return dataSource
    //The snapshot is handleded by the fetch results controller
    //when the fetch results controller tells its contents that is has changed it will update the snapshot
}()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    do {
      try fetchedResultsController.performFetch()
    }catch{
      fatalError("Core Data in Reminder")
    }
  }
  //snapshot provided with the argument to apply with the data source
  func  controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    let reminderSnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
    dataSource.apply(reminderSnapshot)
  }
}

extension RemindersViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "addNewReminder": handleAddNewReminderSegue(segue)
    default:
      return
    }
  }
}

// MARK: - Setup Code -
extension RemindersViewController {
  private func handleAddNewReminderSegue(_ segue: UIStoryboardSegue) {
    guard let newReminderViewController = (segue.destination as? UINavigationController)?.topViewController as? NewReminderViewController else {
      return
    }
    // Prepare reminder with core
    newReminderViewController.context = self.context
    newReminderViewController.list = self.list
  }
}

// MARK: - Table View -
extension RemindersViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

// MARK: - Result Controller Delegate -
extension RemindersViewController: NSFetchedResultsControllerDelegate{
  
}
