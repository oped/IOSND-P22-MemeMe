//
//  ViewController.swift
//  auto resize test
//
//  Created by josh peterson on 11/3/15.
//  Copyright © 2015 Zikursh. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var shareButton: UIBarButtonItem!
	@IBOutlet weak var topTextField: UITextField!
	@IBOutlet weak var bottomTextField: UITextField!
	@IBOutlet weak var topNavigationBar: UINavigationBar!
	@IBOutlet weak var bottomToolBar: UIToolbar!
	
	@IBAction func getImageFromAlbum(sender: AnyObject) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func getImageFromCamera(sender: AnyObject) {
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
		presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func shareMeme(sender: AnyObject) {
		let image: UIImage = generateMemedImage()
		let objectsToShare = [image]
		let meme = Meme( topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: image)
		let activityViewController = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil )
		activityViewController.completionWithItemsHandler = { (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
			if completed {
				(UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
			}
		}
		self.presentViewController(activityViewController, animated: true, completion: nil )
	}

	func generateMemedImage() -> UIImage {
		topNavigationBar.hidden = true
		bottomToolBar.hidden = true
		// render view to an image
		UIGraphicsBeginImageContext(view.frame.size)
		view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
		let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		topNavigationBar.hidden = false
		bottomToolBar.hidden = false
		return memedImage
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageView.image = image
			dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setTextFieldProprties(topTextField, text: "TOP")
		setTextFieldProprties(bottomTextField, text: "BOTTOM")
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated);
		cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
		shareButton.enabled = imageView.image != nil
		subscribeToKeyboardNotifications()
	}
	
	func setTextFieldProprties(textField: UITextField, text: String) {
		let memeTextAttributes = [
			NSStrokeColorAttributeName :  UIColor.blackColor(),
			NSForegroundColorAttributeName : UIColor.whiteColor(),
			NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
			NSStrokeWidthAttributeName : -4.0
		]
		textField.delegate = self
		textField.defaultTextAttributes = memeTextAttributes
		textField.textAlignment = NSTextAlignment.Center
		textField.text = text
		textField.clearsOnBeginEditing = true
	}
	
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func keyboardWillHide(notification: NSNotification) {
		view.frame.origin.y = 0
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if bottomTextField.isFirstResponder() {
			view.frame.origin.y -= getKeyboardHeight(notification)
		}
	}
	
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		textField.clearsOnBeginEditing = false
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

}


