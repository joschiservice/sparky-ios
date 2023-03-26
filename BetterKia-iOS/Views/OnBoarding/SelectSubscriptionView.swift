//
//  SelectSubscriptionView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 26.03.23.
//

import Foundation
import SwiftUI
import StoreKit

struct SelectSubscriptionView: View {
    let productFetcher = ProductFetcher()
    
    @State private var subscriptionProduct: SKProduct? = nil;
    
    @State private var formattedSubscriptionPrice = "";
    
    func loadData() {
        let productIdentifiers: Set<String> = ["pro_subscription"]
                productFetcher.fetchProductInformation(for: productIdentifiers) { (products, error) in
                    if let error = error {
                        // Handle error
                        print("Error fetching product information: \(error.localizedDescription)")
                    } else if products != nil && !products!.isEmpty {
                        // Store products and reload table view
                        let product = products!.first!;
                        
                        if product.introductoryPrice != nil {
                            let formatter = NumberFormatter();
                            formatter.locale = product.priceLocale;
                            formatter.numberStyle = .currency;
                            
                            formattedSubscriptionPrice = formatter.string(from: product.price) ?? "";
                        }
                        
                        subscriptionProduct = product;
                    }
                }
    }
    
    func onSubscribeButtonClicked() {
        if subscriptionProduct == nil {
            return;
        }
        
        let payment = SKMutablePayment(product: subscriptionProduct!)
        
        SKPaymentQueue.default().add(payment)
        
        // When successful, send request to our API to associate the order with the user account
    }
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 28) {
                Text("Your upgrade is almost ready")
                    .font(.system(size: 40, weight: .bold))
                
                Text("Thank you for joining Sparky! You're just one step away from enhancing your Kia experience. Subscribe to our service below to gain access to features like support for Siri voice command, enhanced climate control schedules, charging statistics and much more.")
                
                if subscriptionProduct != nil {
                    VStack {
                        VStack (alignment: .leading, spacing: 18) {
                            Text("MONTHLY")
                                .opacity(0.7)
                                .font(.caption)
                            
                            Text("\(formattedSubscriptionPrice)/month")
                                .font(.title2)
                            
                            VStack {
                                Text("3 Days Free Trial")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(6)
                            }
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(red: 115/255, green: 250/255, blue: 151/255))
                                    .opacity(0.2)
                            }
                        }
                        .frame(
                              minWidth: 0,
                              maxWidth: .infinity,
                              alignment: .topLeading
                            )
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 41/255, green: 130/255, blue: 255/255), lineWidth: 2)
                    }
                } else {
                    ProgressView()
                }
                
                Button {
                    onSubscribeButtonClicked();
                }
            label: {
                Text("Start Your Free Trial")
                    .font(.system(size: 20))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
            }
                .padding()
                .background(.blue)
                .clipShape(RoundedRectangle(cornerSize: .init(width: 10, height: 10)))
                
                NavigationLink("Explore our various features", destination: {
                    List {
                        Label("Dark mode", systemImage: "moon.stars")
                        
                        Label("Support for Siri voice commands", systemImage: "speaker.wave.2.bubble.left")
                        
                        Label("Charging Live Activity", systemImage: "bolt.car")
                        
                        Label("Improved climate control schedules", systemImage: "air.conditioner.vertical")
                        
                        Label("Home screen widgets", systemImage: "square.text.square")
                        
                        Label("Lock & unlock your car", systemImage: "key.radiowaves.forward")
                        
                        Label("Start & stop climate control", systemImage: "air.conditioner.vertical")
                        
                        Section("Comming soon") {
                            Label("Apple Watch App", systemImage: "applewatch")
                            
                            Label("Enhanced & detailed drive history", systemImage: "car.rear.road.lane")
                            
                            Label("Enhanced & detailed charging history", systemImage: "bolt.car")
                            
                            Label("Support for ICE vehicles", systemImage: "engine.combustion")
                            
                            Label("Support for Hyundai vehicles", systemImage: "plus")
                        }
                    }
                    .navigationTitle("Pro Features")
                })
                
                Spacer()
                
            }
            .padding()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadData();
        }
    }
}

struct SelectSubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SelectSubscriptionView()
    }
}
