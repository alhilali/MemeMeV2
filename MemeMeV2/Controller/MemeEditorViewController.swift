//
//  MemeEditorViewController
//  MemeMe
//
//  Created by Saud Alhelali on 25/10/2018.
//  Copyright © 2018 Saud. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initValues()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func initValues() {
        // Disable camera button when not available
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // Configure text
        configure(topTextField, with: "TOP")
        configure(bottomTextField, with: "BOTTOM")
        
        // Set image to nil if image exists
        imagePickerView.image = imagePickerView.image != nil ? nil : imagePickerView.image
        
        // Initially share button is disabled
        shareButton.isEnabled = false
    }
    
    // MARK: Actions from UI

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImageFrom(source: .photoLibrary)

    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImageFrom(source: .camera)
    }
    
    func pickAnImageFrom(source: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        save()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        // Reset to default values
        initValues()
        
        // Go back to sent memes view
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Image specific functions
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func save() {
        let activityViewController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = {
            (activity, completed, items, error) in
            if completed {
                // Create the meme
                let meme = Meme(topText: self.topTextField.text!, bottomText: self.bottomTextField.text!, originalImage: self.imagePickerView.image!, memedImage: self.generateMemedImage())
                
                // Save new meme to global array
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.memes.append(meme)
                print(appDelegate.memes)
                // Go back to sent memes view
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide bars
        toolbarState(hiddenBar: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(imagePickerView.bounds.size)
        view.drawHierarchy(in: imagePickerView.bounds, afterScreenUpdates: false)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show bars
        toolbarState(hiddenBar: false)

        return memedImage
    }
    
    
    // MARK: Keyboard functions
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Only update text values when
        // values are not the default
        if let text = textField.text {
            if text == "TOP" || textField.text == "BOTTOM" {
                textField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: Helper methods
    
    func toolbarState(hiddenBar: Bool){
        self.navigationController?.isToolbarHidden = hiddenBar
        self.navigationController?.isNavigationBarHidden = hiddenBar
    }
    
    func configure(_ textField: UITextField, with defaultText: String) {
        // Mark this class as delegate for text fields
        textField.delegate = self
        
        textField.text = defaultText
        
        // Set text styling
        let memeTextAttributes:[String: Any] = [
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -5.0
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    
}

