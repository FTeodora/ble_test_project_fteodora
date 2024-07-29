//
//  PeripheralView.swift
//  BluetoothApp
//
//  Created by Fariseu, Teodora on 3/24/24.
//

import SwiftUI
import CoreBluetooth

class PeripheralViewModel: NSObject, CBPeripheralManagerDelegate, ObservableObject {
    @Published var message: String = ""
    var service = CBMutableService(type: BTConstants.sampleServiceUUID, primary: true)
    let characteristic = CBMutableCharacteristic(type: BTConstants.sampleCharacteristicUUID, properties: .read, value: "Hello".data(using: .utf8), permissions: .readable)
    
    init(service: CBMutableService = CBMutableService(type: BTConstants.sampleServiceUUID, primary: true), peripheralManager: CBPeripheralManager? = nil) {
        self.service = service
        self.peripheralManager = peripheralManager
        super.init()
        setup()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("[PERIPHERAL] \(peripheral.state.rawValue)" )
        switch peripheral.state {
        case .poweredOn:
            peripheralManager?.add(service)
            peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [service.uuid]])
        default:
            break
        }
    }
    
    var peripheralManager: CBPeripheralManager?
    
    func setup() {
        service.characteristics = [characteristic]
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard let error = error else {
            print("Successfully added service with id: \(service.uuid)")
            return
        }
        print("Error adding service: \(error)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("Received read request for value: \(request.characteristic.value)")
    }
}

struct PeripheralView: View {
    var viewModel = PeripheralViewModel()
    var body: some View {
        VStack {
            Text("Peripheral mode")
            Text(viewModel.message)
                .font(.caption)
            Spacer()
        }
    }
}

#Preview {
    PeripheralView()
}
