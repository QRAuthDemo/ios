//
//  CreateUserView.swift
//  QRAuthDemo
//
//  Created by Amir Zare on 29.05.24.
//

import SwiftUI

struct CreateUserView: View {
    
    @Binding var jwt: String
    
    @State private var mobileNumber: String = ""
    @State private var password: String = ""
    @State private var isWaiting: Bool = false
    @State private var loggedInMobileNumber: String = "Loading ..."
    
    @State private var isErrorShowing = false
    @State private var isDoneShowing = false
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [Color(red: 237/255, green: 117/255, blue: 26/255),
                                    Color(red: 218/255, green: 54/255, blue: 83/255),
                                    Color(red: 182/255, green: 68/255, blue: 145/255)],
                           startPoint: .leading,
                           endPoint: .trailing
                           
            ).ignoresSafeArea()
            
            VStack {
                
                Text(loggedInMobileNumber)
                    .padding()
                    .font(.system(size: 20))
                    .padding()
                
                
                Spacer()
                    .frame(maxHeight: 80)
                
                
                Text("Create an account")
                
                inputs
                
                Button {
                    Task {
                        
                        var request = URLRequest(url: URL(string: "https://backend.qrauthdemo.amzi.top/createUser")!)
                        request.allHTTPHeaderFields = [
                            "authorization": "Bearer \(jwt)",
                            "Content-Type": "application/json"
                        ]
                        request.httpMethod = "POST"
                        request.httpBody = """
                                {
                                    "mobileNumber": "\(mobileNumber)",
                                    "password": "\(password)"
                                }
                                """.data(using: .utf8)!
                        do {
                            let (data, response) = try await URLSession.shared.data(for: request)
                            isWaiting = false
                            
                            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                                //todo show alert successful
                                print("added")
                                isDoneShowing = true
                                
                            } else {
                                print("errror")
                                // todo show error
                                isErrorShowing = true
                            }
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    Text("Create User")
                }
                .buttonStyle(.bordered)

            }
            .padding()
            .alert("Failed", isPresented: $isErrorShowing) {
                Button("OK", role: .cancel) { }
            }
            .alert("Added!", isPresented: $isDoneShowing) {
                Button("OK", role: .cancel) { }
            }
            
            if isWaiting {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView()
            }
        }
        .task {
            // load logged in mobile Number
            var request = URLRequest(url: URL(string: "https://backend.qrauthdemo.amzi.top/user/mobileNumber")!)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = ["authorization": "Bearer \(jwt)"]
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                isWaiting = false
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let responseData = try? JSONDecoder().decode(MobileNumberResponse.self, from: data) {
                    //todo show alert successful
                    self.loggedInMobileNumber = responseData.mobileNumber
                    
                } else {
                    self.loggedInMobileNumber = "error"
                }
            } catch {
                self.loggedInMobileNumber = error.localizedDescription
            }
        }
    }
    
    
    @ViewBuilder private var inputs: some View {
        Label {
            Text("Mobile Number:")
        } icon: {
            Image(systemName: "phone.fill")
        }
        
        TextField("Mobile Number", text: $mobileNumber)
            .padding()
            .background {
                Capsule()
                    .fill(Color.white.opacity(0.25))
            }
        
        Spacer()
            .frame(maxHeight: 12)
        
        Label {
            Text("Password:")
        } icon: {
            Image(systemName: "lock")
        }
        
        SecureField("Password", text: $password)
            .padding()
            .background {
                Capsule()
                    .fill(Color.white.opacity(0.25))
            }
    }
}

struct MobileNumberResponse: Decodable {
    let mobileNumber: String
}

#Preview {
    CreateUserView(jwt: Binding.constant(""))
}
