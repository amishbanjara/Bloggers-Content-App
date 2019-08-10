//
//  TableViewController.swift
//  Bloggers Content App
//
//  Created by IMCS2 on 8/6/19.
//  Copyright © 2019 patelashish797. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    var saveTitle = [NSManagedObject]()
    var getBlogTitle:[String] = []
    var bloggerUrl:[String] = []
    var savedDataArray: [String] = []
    var savedUrl: [String] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fetchData()
        fetchcoreData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedDataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = savedDataArray[indexPath.row]
        return cell
    }
    func fetchData() {
        let url = URL(string: "https://www.googleapis.com/blogger/v3/blogs/2399953/posts?key=AIzaSyDK8J4NZ_awOcTYTRDrZdXhrA-fFvDXqr4")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                if let unwrappedData = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        let item = jsonResult?["items"] as? NSArray
                        DispatchQueue.main.sync {
                            if let count = item?.count{
                                for i in 0...count-1{
                                    let insideItem = item?[i] as! NSDictionary
                                    self.bloggerUrl.append(insideItem["url"] as! String)
                                    let blogTitle = item?[i] as! NSDictionary
                                    self.getBlogTitle.append(blogTitle["title"] as! String)
                                }
                            }
                            self.save(savingTitle: self.getBlogTitle,savingUrl:self.bloggerUrl)
                            self.tableView.reloadData()
                        }
                    }catch{
                        print("Error Fetching API")
                    }
                }
            }
        }
        task.resume()
    }
    let blogSegueIdentifier = "segueID"
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == blogSegueIdentifier,
            let destination = segue.destination as? ViewController,
            let blogIndex = tableView.indexPathForSelectedRow?.row
        {
            destination.blogName = savedDataArray[blogIndex]
            destination.blogUrl = savedUrl[blogIndex]
        }
    }
    func save(savingTitle:[String],savingUrl:[String]) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Blog",
                                       in: managedContext)!
        let blog = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        blog.setValue(savingTitle, forKeyPath: "title")
        blog.setValue(savingUrl, forKeyPath: "url")
        
        do {
            try managedContext.save()
            saveTitle.append(blog)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchcoreData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Blog")
        do {
            saveTitle = try managedContext.fetch(fetchRequest)
            for blog in saveTitle{
                savedDataArray = (blog.value(forKeyPath:"title") as? [String])!
                savedUrl = (blog.value(forKeyPath:"url") as? [String])!
            }
            print(savedDataArray)
            print(savedUrl)
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }    
}


