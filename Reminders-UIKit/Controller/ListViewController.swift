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

class ListViewController: UITableViewController {
  var context: NSManagedObjectContext?
  private lazy var fetchedResultsController: NSFetchedResultsController<List> = {
    //create the fetch request
    let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
    fetchRequest.fetchLimit = 20
    
    //sort Descriptor
    let sortDescriptior = NSSortDescriptor(key: "title", ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptior]
    
    //predicate can be added
    // section name key path can provide the titles for the table view if neeeded
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: self.context!,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
    
    frc.delegate = self
    return frc
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    
    do{
      try fetchedResultsController.performFetch()
    }catch{
      fatalError("Could not fetch the results")
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "showDetail":
      if let controller = (segue.destination as? UINavigationController)?.topViewController as? RemindersViewController {
        handleShowDetailSegue(remindersViewController: controller)
      }
    case "addNewList":
      if let controller = (segue.destination as? UINavigationController)?.topViewController as? NewListViewController {
        handleAddNewListSegue(newListViewController: controller)
      }
    default: return
    }
  }
}

extension ListViewController {
  private func setupViews() {
    navigationItem.leftBarButtonItem = editButtonItem
  }
  
  private func handleShowDetailSegue(remindersViewController: RemindersViewController) {
    guard let indexPath = tableView.indexPathForSelectedRow else {
      return
    }
    // Prepare the context for detail view
    remindersViewController.context = self.context
    
    //pass the list along with to show the exact reminders
    //find the list tapped using the fetched result controller and then pass that list along
    
    let list = fetchedResultsController.object(at: indexPath)
    remindersViewController.list = list
  }
  
  private func handleAddNewListSegue(newListViewController: NewListViewController) {
    // Prepare the context
    newListViewController.context = self.context
  }
}

// MARK: - Table View -
// for data source controllers
extension ListViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = fetchedResultsController.sections?[section] else {return 0}
    //fetched results exposes this allwoing you to get the number of objects in each section
    return sectionInfo.numberOfObjects
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell  = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
    //takes an index path and returns an instance of fetched result
    let list = fetchedResultsController.object(at: indexPath)
    
    cell.textLabel?.text = list.title
    return cell
  }
}

// MARK: - Fetch Results Controller Delegate-
extension ListViewController: NSFetchedResultsControllerDelegate {
  /*this is called after the fetched results controller
   func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
   //everytime a change occurs we can respond to changes
   tableView.reloadData()
   }
   */
  
  //this is called before the changes are about to be processed
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  //as the fetch results controller makes each change
  //notifies the delegate in the specific chnage in the the obeject
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
    guard let list  = anObject as? List else {return}
    //switch on the type of operation the deledate is being called about
    switch type {
    case .insert:
      guard let newIndexPath = newIndexPath else { return }
      tableView.insertRows(at: [newIndexPath], with: .fade)
    case .delete:
      guard let indexPath = indexPath else {
        return
      }
      tableView.deleteRows(at: [indexPath], with: .fade)
    case .move:
      //use the new index path and ask the table view to move the row to the current to new index path
      guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
        return
      }
      tableView.moveRow(at: indexPath, to: newIndexPath)
    case .update:
      //get the cell at the index path and update it with the change
      guard let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) else {
        return
      }
      cell.textLabel?.text = list.title
      default:
      return
    }
  }
  
  //this is called once the changes are worked through
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}


