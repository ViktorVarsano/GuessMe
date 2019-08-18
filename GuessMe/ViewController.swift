//
//  ViewController.swift
//  GuessMe
//
//  Created by Viktor Varsano on 18.08.19.
//  Copyright © 2019 Viktor Varsano. All rights reserved.
//

import UIKit
import CoreML  
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to  UIImage to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
    
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Could not load CoreML model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                
                print(firstResult)
                
                
                let ids = firstResult.identifier
                
                let prob = Int(firstResult.confidence * 100)
                
                
                
                let allItems = ids.components(separatedBy:", ")
                
                let firstItem: String = allItems[0]
                
                self.navigationItem.title = String(prob) + "% " + firstItem
            }

        }
    
        let handler = VNImageRequestHandler(ciImage: image)
    
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        }
        
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    
        present(imagePicker, animated: true, completion: nil)
    }
}
