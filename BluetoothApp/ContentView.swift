//
//  ContentView.swift
//  BluetoothApp
//
//  Created by Fariseu, Teodora on 3/10/24.
//

import SwiftUI
import CoreBluetooth

struct BTConstants {
    // These are sample GATT service strings. Your accessory will need to include these services/characteristics in its GATT database
    static let sampleServiceUUID = CBUUID(string: "AAAA")
    static let sampleCharacteristicUUID = CBUUID(string: "BBBB")
}

extension CBPeripheral: Identifiable {
    public var id: UUID {
        self.identifier
    }
}

struct ContentView: View {
    @State var peripheralMode: Bool = false
    var body: some View {
        Toggle(isOn: $peripheralMode) {
            Text("Peripheral mode")
        }
        if !peripheralMode {
            ScannerView()
        } else {
            PeripheralView()
        }
    }
}

#Preview {
    ContentView()
}
