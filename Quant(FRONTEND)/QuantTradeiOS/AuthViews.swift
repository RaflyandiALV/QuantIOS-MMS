import SwiftUI

// MARK: - LOGIN PAGE
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("QuantTrade")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .foregroundColor(.green)
                    .padding(.bottom, 40)
                
                TextField("Email", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                Button(action: {
                    // Simulasi Login Sukses
                    if !email.isEmpty && !password.isEmpty {
                        isLoggedIn = true
                    } else {
                        showingAlert = true
                    }
                }) {
                    Text("LOGIN")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text("Please fill all fields"), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding(30)
        }
    }
}

// MARK: - REGISTER PAGE (Tampilan Saja)
struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.title)
                    .foregroundColor(.white)
                
                TextField("Email", text: $email)
                    .padding().background(Color.gray.opacity(0.2)).cornerRadius(8).foregroundColor(.white)
                SecureField("Password", text: $password)
                    .padding().background(Color.gray.opacity(0.2)).cornerRadius(8).foregroundColor(.white)
                
                Button(action: {
                    // Logic Register Dummy
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("REGISTER")
                        .frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(8).foregroundColor(.white)
                }
            }.padding()
        }
    }
}

// MARK: - PROFILE PAGE (Dummy Data)
struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    
    // Data Dummy
    let username = "TraderPro_01"
    let email = "user@quanttrade.com"
    let balance = "$12,450.00"
    let totalProfit = "+$2,300.50 (18%)"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    // Avatar Area
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(Text("TP").font(.title).bold().foregroundColor(.green))
                        .padding(.top, 40)
                    
                    Text(username)
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider().background(Color.gray)
                    
                    // Portfolio Stats Dummy
                    HStack(spacing: 40) {
                        VStack {
                            Text("Balance")
                                .foregroundColor(.gray)
                            Text(balance)
                                .font(.title3).bold()
                                .foregroundColor(.white)
                        }
                        VStack {
                            Text("Total Profit")
                                .foregroundColor(.gray)
                            Text(totalProfit)
                                .font(.title3).bold()
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        Text("LOGOUT")
                            .foregroundColor(.red)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
