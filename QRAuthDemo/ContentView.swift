//
//  ContentView.swift
//  QRAuthDemo
//
//  Created by Amir Zare on 22.05.24.
//

import SwiftUI
import CodeScanner

struct ContentView: View {
    
    @State private var isPresentingScanner = false
    @State private var scannedCode: String = ""
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                
                Button {
                    isPresentingScanner = true
                } label: {
                    Label {
                        Text("Scan QR")
                    } icon: {
                        Image(systemName: "qrcode")
                    }
                }
                .buttonStyle(.bordered)

                
            }
            .padding()
            .sheet(isPresented: $isPresentingScanner) {
                CodeScannerView(codeTypes: [.qr]) { response in
                    if case let .success(result) = response {
                        print(result.string)
                        self.scannedCode = result.string
                        isPresentingScanner = false
                        
                        navigationPath.append("CreateUserView")
                    }
                }
            }
            .navigationDestination(for: String.self) { path in
                if path == "CreateUserView" {
                    CreateUserView(jwt: $scannedCode)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
