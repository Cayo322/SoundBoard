//
//  ViewController.swift
//  PhoccoSoundBoard
//
//  Created by Cayo on 10/30/23.
//  Copyright © 2023 cayo. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio: AVAudioPlayer?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let grabacion = grabaciones[indexPath.row]
        var tiempo = Double(0)
        do{
        let duraAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
        tiempo = duraAudio.duration
        }catch{}
        cell.textLabel?.text = grabacion.nombre!
        cell.detailTextLabel?.text = "Tiempo: \(String (format: "%.f", tiempo))s"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath) {
        let grabacion = grabaciones [indexPath.row]
        do{
            reproducirAudio = try AVAudioPlayer(data:
                grabacion.audio! as Data)
            reproducirAudio?.play()
        }catch{}
        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as!
            AppDelegate).persistentContainer.viewContext
        do {
            grabaciones = try
                context.fetch (Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
        let grabacion = grabaciones [indexPath.row]
        let context = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
        context.delete(grabacion)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        do{
            grabaciones = try
                context.fetch (Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        }catch{}
        }
    }

}

