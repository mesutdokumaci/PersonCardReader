//
//  ViewController.swift
//
//
//  Created by Mesut Dokumacı on 28.11.2022.
//

import UIKit
import AVFoundation
import Vision


class ViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker_email: UIPickerView!
    @IBOutlet weak var picker_phone: UIPickerView!
    @IBOutlet weak var picker_name: UIPickerView!
    
    var dataemail = [String] ()
    var dataphone = [String] ()
    var dataname = [String] ()
    var StringAllData = [String] ()
    
    var clened_Phone:String?
    var clenad_Name:String?
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var text_alldata: UITextView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.endEditing(true);
    }
 
    func cameraopen(){
        dataphone.removeAll()
        dataemail.removeAll()
        dataname.removeAll()
        
        performSegue(withIdentifier: "toimage", sender: nil)
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toimage" {
            if let camVC = segue.destination as? PictureTake {
    
                camVC.dataTransferClosure = { [weak self] gelenimg in
                    self!.imageview.image = gelenimg
                    
                    self!.PersonCardReader()
                }
            }
        }
    }
    @IBAction func takepicture(_ sender: Any) {
        
      cameraopen()
 
    }
    
    // Personel Card Image Read Func
    private func PersonCardReader() {
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        let CiImage = CIImage(image: imageview.image!)
        let decimalCharacters = CharacterSet.decimalDigits
      
        let stillImageRequestHandler = VNImageRequestHandler(ciImage: CiImage!  , options: [:])
        try? stillImageRequestHandler.perform([request])

        guard let texts = request.results, texts.count > 0 else {
             
            return
        }

        let arrayLines = texts.flatMap({ $0.topCandidates(20).map({ $0.string}) })
        
      
  

      for line in arrayLines {
         
          print(line)
 
          clened_Phone = PhoneClear(strText: line)
          clenad_Name = NameClear(strText: line)
          
          if line.contains("@")  {
              
              dataemail.append(EmailClear(strText: line))
              
          }else if (clened_Phone!.rangeOfCharacter(from: decimalCharacters) != nil) {
              
              if clened_Phone!.count > 8 && clened_Phone!.count < 15    {
                  if clened_Phone != "" {
                      dataphone.append(clened_Phone!)
                  }
              }
              
          }else {
              
              if clenad_Name != ""
              {
                  dataname.append(clenad_Name!)
              }
          }
          self.StringAllData.append(line)
        }
        
        //pickerviews delegate,datasource
        
        picker_email.delegate = self
        picker_email.dataSource = self
        self.picker_email.tag = 1
        picker_phone.delegate = self
        picker_phone.dataSource = self
        self.picker_phone.tag = 2
        picker_name.delegate = self
        picker_name.dataSource = self
        self.picker_name.tag = 3
        
        
        picker_name.selectRow(0, inComponent: 0, animated: true)
        picker_phone.selectRow(0, inComponent: 0, animated: true)
        picker_email.selectRow(0, inComponent: 0, animated: true)
    
        // all data
        text_alldata.text = self.StringAllData.joined(separator: "\n")
        
    }
    
    
    //email Clera Func

    func EmailClear (strText:String) -> String{
        var comtext = strText.lowercased()
        comtext = comtext.replacingOccurrences(of: ":", with: "")
        comtext = comtext.replacingOccurrences(of: " ", with: "")
        comtext = comtext.replacingOccurrences(of: "e-mail", with: "")
        comtext = comtext.replacingOccurrences(of: "email", with: "")
        comtext = comtext.replacingOccurrences(of: "e-post", with: "")
        comtext = comtext.replacingOccurrences(of: "mail", with: "")

        if (comtext.prefix(1) == "@"){
            comtext = String(comtext.dropFirst(1))
        }
       
        return comtext
    }
    
    
    //Phone Clear Func
    func PhoneClear (strText:String) -> String{
        var comtext = strText
        
        
        if (comtext.prefix(3) == "Fax"){
            comtext = ""
        }
    
        let allowedCharset = CharacterSet
            .decimalDigits
            .union(CharacterSet(charactersIn: "+"))

        comtext = String(comtext.unicodeScalars.filter(allowedCharset.contains))
        
        return comtext
    }
    
    
    //Text Clear Func - Name and all text
    func NameClear(strText:String) -> String {
    
       var comtext = strText
        
        let number = Int(comtext.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        if number != nil {
            comtext = ""
        }else{
            comtext =  comtext.components(separatedBy: CharacterSet.decimalDigits).joined()
        }
        
        if (comtext.prefix(4) == "www." || comtext.prefix(3) == "Web"){
            comtext = ""
        }
 
        if comtext.replacingOccurrences(of: " ", with: "").count <= 6  || comtext.replacingOccurrences(of: " ", with: "").count > 35 {
            comtext = ""
        }
        
        return comtext
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
             return dataemail.count
        }else if (pickerView.tag == 2){
              return dataphone.count
        }else{
            return dataname.count
        }
        
       // return veritel.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         
        if (pickerView.tag == 1) {
            return dataemail[row]
        }else if (pickerView.tag == 2){
            return dataphone[row]
        }else{
            return dataname[row]
        }
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
 
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil else {
            debugPrint("unable to get image from sample buffer")
            return
        }

       
    }
}
extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
       
        
        guard  let image = info [UIImagePickerController.InfoKey.originalImage] as? UIImage else {
           
            return
        }
    
        
        imageview.image = image
        
    }
}

 
