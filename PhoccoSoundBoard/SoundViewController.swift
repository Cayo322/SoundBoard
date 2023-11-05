//
//  SoundViewController.swift
//  PhoccoSoundBoard
//
//  Created by Cayo on 10/30/23.
//  Copyright © 2023 cayo. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController, AVAudioRecorderDelegate{

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoLabel: UILabel!
    
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer: Timer?
    var recordingTime: TimeInterval = 0.0
    var volumenControl: UISlider!

    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // Detener la grabación
            grabarAudio?.stop()
            // Detener el temporizador si está activo
            timer?.invalidate()
            timer = nil
            // Cambiar texto del botón grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            // Empezar a grabar
            grabarAudio?.record()
            // Iniciar el temporizador solo si aún no está activo
            if timer == nil {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
            }
            // Cambiar el texto del botón grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as!
            AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData (contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController (animated: true)
    }
    @objc func volumenChanged() {
        let nuevoVolumen = volumenControl.value
        reproducirAudio?.volume = nuevoVolumen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        volumenControl = UISlider()
        volumenControl.minimumValue = 0.0
        volumenControl.maximumValue = 1.0
        volumenControl.value = 0.5 // Puedes establecer el valor inicial del volumen aquí
        volumenControl.addTarget(self, action: #selector(volumenChanged), for: .valueChanged)
        self.view.addSubview(volumenControl)

        // Ajusta las restricciones para el control de volumen
        volumenControl.translatesAutoresizingMaskIntoConstraints = false
        volumenControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        volumenControl.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        volumenControl.widthAnchor.constraint(equalToConstant: 200).isActive = true

        // Do any additional setup after loading the view.
    }
    
    
    func configurarGrabacion(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            //impresion de ruta donde se guardan los archivos
            print("********* **********")
            print(audioURL!)
            print("*********************")
            //crear opciones para el grabador de audio
            var settings: [String: AnyObject] = [:]
            settings [AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings [AVSampleRateKey] = 44100.0 as AnyObject?
            settings [AVNumberOfChannelsKey] = 2 as AnyObject?
            //crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    @objc func actualizarTiempo() {
        recordingTime += 1.0
        tiempoLabel.text = (String(format: "%.f", grabarAudio!.currentTime))
    }
    
   

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
