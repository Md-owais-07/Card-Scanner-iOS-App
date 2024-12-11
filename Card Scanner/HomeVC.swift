//
//  ViewController.swift
//  Card Scanner
//
//  Created by Owais on 31/07/24.
//

import UIKit
import AVFoundation
import Vision
import VisionKit
import CoreData

class HomeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lblEmptyCard: UILabel!
    @IBOutlet weak var lblEmptyCardDescription: UILabel!
    @IBOutlet weak var bottomView: UIView!
    
    var userData: [Card] = []
    
    var imageToProcess: UIImage?
    var overlayView: CardOverlayView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = imageToProcess {
            recognizeText(from: image)
        }
        
        printAllCardData()
        fetchData()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    @IBAction func scanCardButtonTapped(_ sender: Any) {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true, completion: nil)
    }
    
    func printAllCardData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            for card in results {
                print("Name: \(card.cdName ?? "No Name")")
                print("Company: \(card.cdCompany ?? "No Company")")
                print("Address: \(card.cdAddress ?? "No Address")")
                // Print other fields as needed
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                print("Error recognizing text: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var cardData = CardDataModel()
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                let recognizedText = topCandidate.string
                print("Recognized Text: \(recognizedText)")
                
                let lines = recognizedText.split(separator: "\n")
                for line in lines {
                    let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
                    if cardData.name == nil && self.isValidName(text) {
                        cardData.name = text
                    } else if cardData.jobProfile == nil && self.isValidDesignation(text) {
                        cardData.jobProfile = text
                    } else if cardData.address == nil && self.isValidAddress(text) {
                        cardData.address = text
                    } else if cardData.email == nil && self.isValidEmail(text) {
                        cardData.email = text
                    } else if cardData.phoneNumber == nil && self.isValidPhoneNumber(text) {
                        cardData.phoneNumber = text
                    } else if cardData.website == nil && self.isValidWebsite(text) {
                        cardData.website = text
                    } else if cardData.company == nil && self.isValidName(text) {
                        cardData.company = text
                    } else if cardData.other == nil && self.isValidName(text) {
                        cardData.other = text
                    } else {
                        print("INVALID DATA RECOGNIZE...:")
                    }
                }
            }
            
            self.saveCardData(cardData)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error.localizedDescription)")
        }
    }
    
    func saveCardData(_ cardData: CardDataModel) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let userDataValues = Card(context: context)
        
        userDataValues.cdName = cardData.name ?? "Name not found"
        userDataValues.cdDesignation = cardData.jobProfile ?? "Designation not found"
        userDataValues.cdMobilenumber = cardData.phoneNumber ?? "Mobile number not found"
        userDataValues.cdEmailAddress = cardData.email ?? "Email not found"
        userDataValues.cdWebsite = cardData.website ?? "Website not found"
        userDataValues.cdAddress = cardData.address ?? "Address not found"
        userDataValues.cdOthers = cardData.other ?? "Other not found"
        userDataValues.cdCompany = cardData.company ?? "Company not found"
        
        do {
            try context.save()
            print("Card data saved successfully.")
        } catch {
            print("Error saving card data:", error.localizedDescription)
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
    
    func isValidEmail(_ text: String) -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return false
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: trimmedText)
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
    
    //    func convertToJSON(data: CardDataModel) -> String? {
    //        guard let jsonData = try? JSONEncoder().encode(data) else {
    //            return nil
    //        }
    //        return String(data: jsonData, encoding: .utf8)
    //    }
    
    func setupUI() {
        headerView.layer.shadowColor = UIColor.systemGray.cgColor
        headerView.layer.shadowOpacity = 0.5
        headerView.layer.shadowOffset = CGSizeZero
        headerView.layer.shadowRadius = 5
        
        bottomView.layer.shadowColor = UIColor.systemGray.cgColor
        bottomView.layer.shadowOpacity = 0.5
        bottomView.layer.shadowOffset = CGSizeZero
        bottomView.layer.shadowRadius = 5
        
        btnScan.clipsToBounds = true
        btnScan.layer.cornerRadius = 8
        
        tableView.register(UINib(nibName: "CardTVC", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.reloadData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func fetchData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                print("No data found for user with ID: . This might be a new user.")
                tableView.isHidden = true
                stackView.isHidden = false
                lblEmptyCard.text = "No Cards"
                lblEmptyCardDescription.text = "No card found. Please scan a card."
                self.userData = []
            } else {
                self.userData = results
                tableView.isHidden = false
                stackView.isHidden = true
                print("Data fetched for user with ID: ")
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching data from Core Data: \(error.localizedDescription)")
        }
    }
    
}

extension HomeVC: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        if scan.pageCount > 0 {
            let scannedImage = scan.imageOfPage(at: 0)
            imageView.image = scannedImage
            imageToProcess = scannedImage
            
            recognizeText(from: scannedImage)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print("Document scanning failed: \(error)")
        controller.dismiss(animated: true, completion: nil)
    }
}


extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CardTVC else {
            return UITableViewCell()
        }
        
        let userData = userData[indexPath.row]
        
        cell.lblCardholderName.text = userData.cdName
        cell.lblJobPosition.text = userData.cdDesignation
        cell.lblEmailAddress.text = userData.cdEmailAddress
        cell.lblMobileNumber.text = userData.cdMobilenumber
        cell.lblWebsite.text = userData.cdWebsite
        cell.lblAddress.text = userData.cdAddress
        cell.lblCompanyName.text = userData.cdCompany
        cell.lblOthers.text = userData.cdOthers
        
        return cell
    }
}


















//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            guard let selectedImage = info[.originalImage] as? UIImage else {
//                return
//            }
//            imageView.image = selectedImage
//            imageToProcess = selectedImage // Store the selected image
//            dismiss(animated: true, completion: nil)
//            recognizeText(from: selectedImage)
//        }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }

//    func recognizeText(from image: UIImage) {
//        guard let cgImage = image.cgImage else { return }
//
//        let request = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
//                print("Error recognizing text: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            var name: String?
//            var designation: String?
//            var mobileNumber: String?
//            var address: String?
//            var website: String?
//
//            for observation in observations {
//                guard let topCandidate = observation.topCandidates(1).first else { continue }
//                let recognizedText = topCandidate.string
//                print("Recognized Text: \(recognizedText)")
//
//                let lines = recognizedText.split(separator: "\n")
//
//                for line in lines {
//                    let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
//                    if name == nil && self.isValidName(text) {
//                        name = text
//                    } else if mobileNumber == nil && self.isValidPhoneNumber(text) {
//                        mobileNumber = text
//                    } else if designation == nil && self.isValidDesignation(text) {
//                        designation = text
//                    } else if address == nil && self.isValidAddress(text) {
//                        address = text
//                    } else if website == nil && self.isValidWebsite(text) {
//                        website = text
//                    }
//                }
//            }
//
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.userName.alpha = 0
//                    self.userDesignation.alpha = 0
//                    self.userMobileNumber.alpha = 0
//                    self.userAddress.alpha = 0
//                    self.userWebsite.alpha = 0
//                }, completion: { _ in
//                    self.userName.text = name ?? "Name not found"
//                    self.userDesignation.text = designation ?? "Designation not found"
//                    self.userMobileNumber.text = mobileNumber ?? "Mobile number not found"
//                    self.userAddress.text = address ?? "Address not found"
//                    self.userWebsite.text = website ?? "Website not found"
//
//                    UIView.animate(withDuration: 0.5) {
//                        self.userName.alpha = 1
//                        self.userDesignation.alpha = 1
//                        self.userMobileNumber.alpha = 1
//                        self.userAddress.alpha = 1
//                        self.userWebsite.alpha = 1
//                    }
//                })
//            }
//
//            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            let cardData = Card(context: context)
//
//            cardData.name = name ?? "Name not found"
//            cardData.designation = designation ?? "Designation not found"
//            cardData.mobilenumber = mobileNumber ?? "Mobile number not found"
//            cardData.address = address ?? "Address not found"
//            cardData.website = website ?? "Website not found"
//
//            do {
//                try context.save()
//                print("Card data saved successfully")
//            } catch {
//                print("Error saving card data:", error.localizedDescription)
//            }
//        }
//
//        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
//        do {
//            try requestHandler.perform([request])
//        } catch {
//            print("Failed to perform text recognition: \(error.localizedDescription)")
//        }
//    }

//    func isValidName(_ text: String) -> Bool {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else {
//            return false
//        }
//        let nameRegex = "^[a-zA-ZÀ-ÿ'\\- ]+$"
//        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
//        let isLengthValid = (1...50).contains(trimmedText.count)
//        return namePredicate.evaluate(with: trimmedText) && isLengthValid
//    }
//
//    func isValidDesignation(_ text: String) -> Bool {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else {
//            return false
//        }
//        let designationRegex = "^[a-zA-ZÀ-ÿ.,'\\- ]+$"
//        let designationPredicate = NSPredicate(format: "SELF MATCHES %@", designationRegex)
//        let isLengthValid = (2...100).contains(trimmedText.count)
//        return designationPredicate.evaluate(with: trimmedText) && isLengthValid
//    }
//
//    func isValidAddress(_ text: String) -> Bool {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else {
//            return false
//        }
//        let addressRegex = "^[a-zA-Z0-9 ,\\-]+(?:\\s*-\\s*[0-9]{6})?(?:\\s*-\\s*[a-zA-Z ]+)?$"
//        let addressPredicate = NSPredicate(format: "SELF MATCHES %@", addressRegex)
//        let isLengthValid = (5...200).contains(trimmedText.count)
//        return addressPredicate.evaluate(with: trimmedText) && isLengthValid
//    }
//
//    func isValidWebsite(_ text: String) -> Bool {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmedText.isEmpty else {
//            return false
//        }
//
//        let websiteRegex = "^(https?:\\/\\/)?(www\\.)?[a-zA-Z0-9-]+(\\.[a-zA-Z]{2,})+$"
//        let websitePredicate = NSPredicate(format: "SELF MATCHES %@", websiteRegex)
//        return websitePredicate.evaluate(with: trimmedText)
//    }

//    func isValidPhoneNumber(_ text: String) -> Bool {
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        let phoneRegex = "^\\+?[0-9]{1,4}?[-.\\s]?\\(?[0-9]{1,3}?\\)?[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,9}$"
//        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
//        return phonePredicate.evaluate(with: trimmedText)
//    }
//
//    func fetchData() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
//
//        do {
//            self.userData = try context.fetch(fetchRequest)
//            print("DATA IS FETCHING FROM CORE DATA...")
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 0.5) {
//                    for user in self.userData {
//                        self.userName.alpha = 0
//                        self.userAddress.alpha = 0
//                        self.userWebsite.alpha = 0
//                        self.userDesignation.alpha = 0
//                        self.userMobileNumber.alpha = 0
//                    }
//                } completion: { _ in
//                    for user in self.userData {
//                        self.userName.text = user.name
//                        self.userAddress.text = user.address
//                        self.userWebsite.text = user.website
//                        self.userDesignation.text = user.designation
//                        self.userMobileNumber.text = user.mobilenumber
//                    }
//                    UIView.animate(withDuration: 0.5) {
//                        for user in self.userData {
//                            self.userName.alpha = 1
//                            self.userAddress.alpha = 1
//                            self.userWebsite.alpha = 1
//                            self.userDesignation.alpha = 1
//                            self.userMobileNumber.alpha = 1
//                        }
//                    }
//                }
//                print("DATA IS FETCHING AFTER DispatchQueue.main.async...")
//            }
//
//        } catch {
//            print("Error fetching data from Core Data: \(error.localizedDescription)")
//        }
//    }
