//
//  ViewController.swift
//  Card Scanner
//
//  Created by Owais on 31/07/24.
//

import UIKit
import AVFoundation
import Vision
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDesignation: UILabel!
    @IBOutlet weak var userMobileNumber: UILabel!
    @IBOutlet weak var userWebsite: UILabel!
    @IBOutlet weak var userAddress: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var dataStack: UIStackView!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var userData: [Card] = []
    var imageToProcess: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        headerView.layer.shadowColor = UIColor.systemGray.cgColor
        headerView.layer.shadowOpacity = 0.5
        headerView.layer.shadowOffset = CGSizeZero
        headerView.layer.shadowRadius = 5
        
        btnScan.clipsToBounds = true
        btnScan.layer.cornerRadius = 8
        
        tableView.showsVerticalScrollIndicator = false
        
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        if let image = imageToProcess {
            recognizeText(from: image)
        }
    }
    
    @IBAction func scanCardButtonTapped(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                return
            }
            imageView.image = selectedImage
            imageToProcess = selectedImage // Store the selected image
            dismiss(animated: true, completion: nil)
            recognizeText(from: selectedImage)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("Error recognizing text: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var name: String?
            var designation: String?
            var mobileNumber: String?
            var address: String?
            var website: String?
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                let recognizedText = topCandidate.string
                print("Recognized Text: \(recognizedText)")
                
                let lines = recognizedText.split(separator: "\n")
                
                for line in lines {
                    let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if name == nil && self.isValidName(text) {
                        name = text
                    } else if mobileNumber == nil && self.isValidPhoneNumber(text) {
                        mobileNumber = text
                    } else if designation == nil && self.isValidDesignation(text) {
                        designation = text
                    } else if address == nil && self.isValidAddress(text) {
                        address = text
                    } else if website == nil && self.isValidWebsite(text) {
                        website = text
                    }
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5, animations: {
                    self.userName.alpha = 0
                    self.userDesignation.alpha = 0
                    self.userMobileNumber.alpha = 0
                    self.userAddress.alpha = 0
                    self.userWebsite.alpha = 0
                }, completion: { _ in
                    self.userName.text = name ?? "Name not found"
                    self.userDesignation.text = designation ?? "Designation not found"
                    self.userMobileNumber.text = mobileNumber ?? "Mobile number not found"
                    self.userAddress.text = address ?? "Address not found"
                    self.userWebsite.text = website ?? "Website not found"
                    
                    UIView.animate(withDuration: 0.5) {
                        self.userName.alpha = 1
                        self.userDesignation.alpha = 1
                        self.userMobileNumber.alpha = 1
                        self.userAddress.alpha = 1
                        self.userWebsite.alpha = 1
                    }
                })
            }
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let cardData = Card(context: context)
            
            cardData.name = name ?? "Name not found"
            cardData.designation = designation ?? "Designation not found"
            cardData.mobilenumber = mobileNumber ?? "Mobile number not found"
            cardData.address = address ?? "Address not found"
            cardData.website = website ?? "Website not found"
            
            print("Demo")
            
            do {
                try context.save()
                print("Card data saved successfully")
            } catch {
                print("Error saving card data:", error.localizedDescription)
            }
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error.localizedDescription)")
        }
    }
    
    func isValidName(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return false
        }
        let nameRegex = "^[a-zA-ZÀ-ÿ'\\- ]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        let isLengthValid = (1...50).contains(trimmedText.count)
        return namePredicate.evaluate(with: trimmedText) && isLengthValid
    }
    
    func isValidDesignation(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return false
        }
        let designationRegex = "^[a-zA-ZÀ-ÿ.,'\\- ]+$"
        let designationPredicate = NSPredicate(format: "SELF MATCHES %@", designationRegex)
        let isLengthValid = (2...100).contains(trimmedText.count)
        return designationPredicate.evaluate(with: trimmedText) && isLengthValid
    }
    
    func isValidAddress(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return false
        }
        let addressRegex = "^[a-zA-Z0-9 ,\\-]+(?:\\s*-\\s*[0-9]{6})?(?:\\s*-\\s*[a-zA-Z ]+)?$"
        let addressPredicate = NSPredicate(format: "SELF MATCHES %@", addressRegex)
        let isLengthValid = (5...200).contains(trimmedText.count)
        return addressPredicate.evaluate(with: trimmedText) && isLengthValid
    }
    
    func isValidWebsite(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return false
        }
        
        let websiteRegex = "^(https?:\\/\\/)?(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+$"
        let websitePredicate = NSPredicate(format: "SELF MATCHES %@", websiteRegex)
        return websitePredicate.evaluate(with: trimmedText)
    }
    
    func isValidPhoneNumber(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneRegex = "^\\+?[0-9]{1,4}?[-.\\s]?\\(?[0-9]{1,3}?\\)?[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,9}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: trimmedText)
    }
    
    func fetchData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            self.userData = try context.fetch(fetchRequest)
            print("DATA IS FETCHING FROM CORE DATA...")
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    for user in self.userData {
                        self.userName.alpha = 0
                        self.userAddress.alpha = 0
                        self.userWebsite.alpha = 0
                        self.userDesignation.alpha = 0
                        self.userMobileNumber.alpha = 0
                    }
                } completion: { _ in
                    for user in self.userData {
                        self.userName.text = user.name
                        self.userAddress.text = user.address
                        self.userWebsite.text = user.website
                        self.userDesignation.text = user.designation
                        self.userMobileNumber.text = user.mobilenumber
                    }
                    UIView.animate(withDuration: 0.5) {
                        for user in self.userData {
                            self.userName.alpha = 1
                            self.userAddress.alpha = 1
                            self.userWebsite.alpha = 1
                            self.userDesignation.alpha = 1
                            self.userMobileNumber.alpha = 1
                        }
                    }
                }
                print("DATA IS FETCHING AFTER DispatchQueue.main.async...")
            }
            
        } catch {
            print("Error fetching data from Core Data: \(error.localizedDescription)")
        }
    }
    
}
