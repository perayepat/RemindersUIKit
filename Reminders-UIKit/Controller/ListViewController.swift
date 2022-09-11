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
    
    return frc
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    
    do{
      try fetchedResultsController.performFetch()
      tableView.reloadData()
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
    remindersViewController.context = self.context
    // Prepare the context for detail view
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
