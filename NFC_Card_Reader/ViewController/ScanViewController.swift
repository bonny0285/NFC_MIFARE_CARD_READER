//
//  ViewController.swift
//  NFC_Card_Reader
//
//  Created by Massimiliano Bonafede on 22/09/2020.
//

import UIKit
import CoreNFC



class ScanViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Properties
    
    var uidContainer: [String] = []
    var nfcSession: NFCTagReaderSession?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        
        let nib = UINib(nibName: "UidCardCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "UidCardCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
    }
    
    
    //MARK: - Actions
    
    @IBAction func addButtonWasPressed(_ sender: Any) {
        nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        nfcSession?.alertMessage = "Hold your iPhone close to the card."
        nfcSession?.begin()
    }
    
    
}

//MARK: - UITableViewDelegate & UITablrViewDataSource

extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        uidContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UidCardCell", for: indexPath) as? UidCardCell else { return UITableViewCell() }
        
        let uid = uidContainer[indexPath.row]
        cell.setupCellWith(uid)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
}

//MARK: - NFCTagReaderSessionDelegate

extension ScanViewController: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        debugPrint("Session did become active")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        self.nfcSession?.invalidate(errorMessage: error.localizedDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        
        let tag = tags.first!
        
        switch tag {
        case .feliCa(_):
            self.nfcSession?.invalidate(errorMessage: "Card type error: felica")
        case .iso7816(_):
            self.nfcSession?.invalidate(errorMessage: "Card type error: iso7816")
        case .iso15693(_):
            self.nfcSession?.invalidate(errorMessage: "Card type error: iso15693")
        case .miFare(let mifare):
            let readSignature: [UInt8] = [0x90, 0x3c, 0x00, 0x00, 0x01, 0x00, 0x00]
            guard let apdu = NFCISO7816APDU.init(data: Data.init(readSignature)) else { return }
            
            mifare.sendMiFareISO7816Command(apdu) { [weak self] (data, _, _, error) in
                
                guard let self = self else { return }
                
                let id = mifare.identifier.filter { $0 != 0 }.map { String(format: "%02X", $0) }.joined()
                //let signature = data.filter { $0 != 0 }.map { String(format: "%02X", $0) }.joined()

                DispatchQueue.main.async {
                    if self.uidContainer.contains(id) == false {
                        self.uidContainer.append(id)
                        self.tableView.reloadData()
                        self.nfcSession?.restartPolling()
                    } else {
                        self.nfcSession?.restartPolling()
                    }
                }
    
                self.nfcSession?.alertMessage = "New card added on the list - \(id)"
            }
            
        @unknown default:
            self.nfcSession?.invalidate(errorMessage: "Card type error: default")
        }
    }
}
