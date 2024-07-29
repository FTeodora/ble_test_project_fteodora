//
//  ScannerView.swift
//  BluetoothApp
//
//  Created by Fariseu, Teodora on 4/10/24.
//

import SwiftUI
import CoreBluetooth

class CentralViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var peripherals = Set<CBPeripheral>()
    @Published var valueToWrite: String = ""
    
    private var cbManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    
    init(peripherals: Set<CBPeripheral> = Set<CBPeripheral>()) {
        self.peripherals = peripherals
        super.init()
        cbManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connect(to peripheral: CBPeripheral) {
        cbManager?.connect(peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[MANAGER] \(central.state.rawValue)" )
        
        if case central.state = .poweredOn {
            cbManager?.scanForPeripherals(withServices: [BTConstants.sampleServiceUUID], options: nil)
            //cbManager?.scanForPeripherals(withServices: [BTConstants.sampleServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("discovered peripheral: \(peripheral.name ?? "unknown") with id \(peripheral.identifier)")
        peripherals.insert(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("peripheral: %@ connected", peripheral)
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices([BTConstants.sampleServiceUUID])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("peripheral: %@ failed to connect", peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("peripheral: %@ disconnected", peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first else { return }
        connectedPeripheral?.discoverCharacteristics([BTConstants.sampleCharacteristicUUID], for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristic = service.characteristics?.first else { return }
        connectedPeripheral?.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        let characteristicValue = String(decoding: data, as: UTF8.self)
        print("Characteristic value: \(characteristicValue)")
    }
}

struct ScannerView: View {
    @StateObject private var viewModel = CentralViewModel()
    var body: some View {
        VStack {
            TextField("", text: $viewModel.valueToWrite)
            Text("Peripherals found:")
            ScrollView {
                ForEach(Array(viewModel.peripherals)) { peripheral in
                    VStack {
                        Text(peripheral.name ?? "Unnamed Peripheral")
                        Text(peripheral.id.uuidString)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .onTapGesture {
                        viewModel.connect(to: peripheral)
                    }
                }
            }.frame(maxWidth: .infinity)
        }.padding()
    }
}

#Preview {
    ScannerView()
}
