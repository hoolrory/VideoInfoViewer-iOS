/**
 Copyright (c) 2016 Rory Hool
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **/

import UIKit
import MobileCoreServices
import CoreData
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate,UITableViewDataSource {
    
    let imagePicker = UIImagePickerController()
    
    var videos = [NSManagedObject]()
    
    @IBOutlet
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Video Info Viewer"
        
        let openButton = UIBarButtonItem()
        openButton.title = "Open"
        openButton.action = #selector(ViewController.clickOpen(_:))
        openButton.target = self
        
        self.navigationItem.rightBarButtonItem = openButton
        
        imagePicker.delegate = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Video")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            videos = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    @IBAction func clickOpen(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaUrl = info[UIImagePickerControllerMediaURL] as? NSURL
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let srcURL = mediaUrl {
            let filemgr = NSFileManager.defaultManager()
            
            var videoName = "video_\(NSDate().timeIntervalSince1970).MOV"
            if let lastPathCompontent = srcURL.lastPathComponent {
                videoName = lastPathCompontent
            }
        
            let toURL = getDocumentUrl(videoName)
        
            do {
                try filemgr.copyItemAtURL(srcURL, toURL: toURL)
            } catch _ {
                print("Failed to copy")
                return
            }
            
            let thumbnailURL = getDocumentUrl("\(videoName).png")
            let duration = MediaUtils.getVideoDuration(toURL)
            let thumbTime = CMTime(seconds: duration.seconds / 2.0, preferredTimescale: duration.timescale)
            MediaUtils.renderThumbnailFromVideo(toURL, thumbnailURL: thumbnailURL, time: thumbTime)
            
            saveVideo(toURL, thumbnailURL: thumbnailURL)
            print(videos.count)
        } else {
            print("Failed to unpack media url")
        }
    }

    func saveVideo(videoURL: NSURL, thumbnailURL: NSURL) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Video", inManagedObjectContext:managedContext)
        
        let video = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        video.setValue(videoURL.lastPathComponent, forKey: "videoFile")
        video.setValue(thumbnailURL.lastPathComponent, forKey: "thumbnailFile")
        
        do {
            try managedContext.save()
            videos.append(video)
            tableView.reloadData()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getDocumentUrl(pathComponent : String) -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        guard let documentDirectory: NSURL = urls.first else {
            fatalError("documentDir Error")
        }
        
        return documentDirectory.URLByAppendingPathComponent(pathComponent)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        let videoFile = self.videos[indexPath.row].valueForKey("videoFile") as? String
        let thumbnailFile = self.videos[indexPath.row].valueForKey("thumbnailFile") as? String
        
        if let vf = videoFile {
            let videoURL = getDocumentUrl(vf)
            cell.textLabel?.text = videoURL.lastPathComponent
        }
        
        if let tf = thumbnailFile {
            let thumbnailURL = getDocumentUrl(tf)
            // print("Binding to \(thumbnailURL.path!)")
            cell.imageView?.image = UIImage(named: thumbnailURL.path! )
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let videoFile = self.videos[indexPath.row].valueForKey("videoFile") as? String
        let thumbnailFile = self.videos[indexPath.row].valueForKey("thumbnailFile") as? String
        let videoURL = getDocumentUrl(videoFile!)
        let thumbnailURL = getDocumentUrl(thumbnailFile!)
        let nc = parentViewController as? UINavigationController
        if let navController = nc {
            let videoDetailsController = self.storyboard!.instantiateViewControllerWithIdentifier("videoDetails") as! VideoDetailsViewController
            videoDetailsController.videoURL = videoURL
            videoDetailsController.thumbnailURL = thumbnailURL
            navController.pushViewController(videoDetailsController, animated: true)
        }
    }
}

