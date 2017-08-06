//
//  ViewController.swift
//  Capps
//
//  Created by Corey Brady on 8/2/17.
//  Copyright © 2017 Corey Brady. All rights reserved.
//

import UIKit
import TagListView



    
    class ViewController: UIViewController, UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate, TagListViewDelegate {
        
        @IBOutlet var TLV: TagListView!
        
        @IBOutlet var constructsView: UITextView!
        var picker:UIImagePickerController?=UIImagePickerController()
        
        @IBOutlet var fullConstructView: UITextView!
        
        @IBOutlet weak var imageView: UIImageView!
        
        var  sublevelData:[[String:String]] = []
        var  domains:[String] = ["Length", "Angle", "Area", "Volume"]
        var  columnTitles:[String] = ["Level", "Description", "Examples"]
        var  levels:[[String:String]] = []
        var  descriptions:[String:String] = [:]
        var  examples:[String:String] = [:]
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            picker?.delegate=self
            readDataFromFile()
            setupTags()
            
        }
        
        func setupTags() {
            TLV.delegate = self
            TLV.textFont = UIFont.systemFont(ofSize: 19)
            TLV.shadowRadius = 2
            TLV.shadowOpacity = 0.4
            TLV.shadowColor = UIColor.black
            TLV.shadowOffset = CGSize(width: 1, height: 1)
            TLV.borderWidth = 1
            TLV.paddingY = 5
            TLV.paddingX = 5
            
            
            for dict in sublevelData {
                TLV.addTag( dict[columnTitles[0]]! )
            }

            TLV.alignment = .center

        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
        }
        
        // Open Gallery button click
        @IBAction func OpenGallery(sender: AnyObject) {
            openGalleryBacking()
        }
        
        // Take Photo button click
        @IBAction func TakePhoto(sender: AnyObject) {
            openCameraBacking()
        }
        
        
        func openGalleryBacking()
        {
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(picker!, animated: true, completion: nil)
        }
        
        
        func openCameraBacking()
        {
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                picker!.allowsEditing = false
                picker!.sourceType = UIImagePickerControllerSourceType.camera
                picker!.cameraCaptureMode = .photo
                present(picker!, animated: true, completion: nil)
            }else{
                let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
            }
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [String : AnyObject])
        {
            var  chosenImage = UIImage()
            chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
            imageView.contentMode = .scaleAspectFit //3
            imageView.image = chosenImage //4
            dismiss(animated:true, completion: nil) //5
        }
        
        // interface fullfilment: TagListViewDelegate
        func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
            //print("Tag pressed: \(title), \(sender)")
            tagView.isSelected = !tagView.isSelected
            if tagView.isSelected {
                updateDetailedView( level: title, tag: tagView )
            } else {
                fullConstructView.text = ""
            }
            updateShownDescriptions(sender: sender)
        }
        
        func updateDetailedView( level: String, tag: TagView ) {
            var content = level
            content += "\n\n" + descriptions[level]!
            content += "\n\n" + examples[level]!
            fullConstructView.text = content
        }
        
        func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
            //print("Tag Remove pressed: \(title), \(sender)")
            sender.removeTagView(tagView)
        }

        
        func updateShownDescriptions(sender: TagListView) {
            var stringToShow = ""
            for tagView in sender.selectedTags() {
                let ttl = tagView.titleLabel
                let key = ttl?.text
                stringToShow += key! + ": " + descriptions[key!]! + "\n"
            }
            constructsView.text = stringToShow
        }
        
        func readDataFromFile(){
            
            
            let fileName = "constructs"
            let fileType = "txt"
            
             
            guard let path = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                print("Can't load file \(fileName).\(fileType)")
                return
            }
            do {
                let content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                //let stuff = cleanRows(file: content)
                convertCSV(file: cleanRows(file: content))
                //constructsView.text = content
            } catch {
                print ("File Read Error")
            }
            
            
        }
        
        func convertCSV(file:String){
            let rows = cleanRows(file: file).components(separatedBy: "\n")
            if rows.count > 0 {
                levels = []
                sublevelData = []
                descriptions = [:]
    
                for row in rows{
                    let fields = getStringFieldsForRow(row: row,delimiter: "|")
                    print( "processing " + row)
                    print( "count fields = ")
                    print( fields.count )
                    if fields.count == 2 {
                        //this is a level descriptor.
                        var levelname = [String:String]()
                        levelname[fields.first!]=fields.last
                        levels += [levelname]
                        print("levels added: " + levelname[fields.first!]!)
                    } else if fields.count == 3 {
                        var levelDataRow = [String:String]()
                        for (index,field) in fields.enumerated(){
                            levelDataRow[columnTitles[index]] = field
                        }
                        print("sublevel data added: " + row)
                        sublevelData += [levelDataRow]
                        descriptions[levelDataRow[columnTitles[0]]!] = levelDataRow[columnTitles[1]]
                        examples[levelDataRow[columnTitles[0]]!] = levelDataRow[columnTitles[2]]
                        
                    }
                }
            } else {
                print("No data in file")
            }
        }
        
        func cleanRows(file:String)->String{
            //use a uniform \n for end of lines.
            var cleanFile = file
            cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
            cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
            return cleanFile
        }
        
        func getStringFieldsForRow(row:String, delimiter:String)-> [String]{
            return row.components(separatedBy: delimiter)
        }
        
    }
    
    

    
    
    
    


