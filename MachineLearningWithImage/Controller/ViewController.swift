//
//  ViewController.swift
//  MachineLearningWithImage
//
//  Created by yekta on 16.02.2024.
//

import UIKit
import CoreML
import Vision
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txtLbl: UILabel!
    @IBOutlet weak var changeButtonUI: UIButton!
    var chosenImage:CIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        changeButtonUI.layer.cornerRadius = 20
        changeButtonUI.layer.masksToBounds = true
        txtLbl.text = "Select image"
    }
    
    @IBAction func changeButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        recognizeImage(image: chosenImage!)
    }
    
    func recognizeImage(image: CIImage) {
        
        
        txtLbl.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            //
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int (confidenceLevel * 100) / 100
                            
                            self.txtLbl.text = "\(rounded)% it's \(topResult!.identifier)"
                            
                        }
                        
                    }
                    
                }
                
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
            
            
        }
        
        
        
    }
    
}

