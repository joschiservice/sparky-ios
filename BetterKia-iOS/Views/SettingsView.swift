//
//  SettingsView.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 24.03.23.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct SettingsView: View {
    @ObservedObject var vehicleManager = VehicleManager.shared
    
    @State var isBleAutoUnlockActivated = false;
    @State var obd2Uuid = "";
    
    var body: some View {
        NavigationStack {
            List {
                Section("Current Vehicle") {
                    Label("Model: " + (vehicleManager.primaryVehicle?.modelName ?? "n/a"), systemImage: "car.side")
                    Label("VIN: " + (vehicleManager.primaryVehicle?.vin ?? "n/a"), systemImage: "number")
                    ChangePrimaryVehicleButton()
                }
                
                Section() {
                    NavigationLink("Experimental Features") {
                        List {
                            Section(footer: Text("AutoLock measures the distance between your smartphone and the OBD2 adapter in your car to determine, when you walk away from your vehicle.")) {
                                Toggle("Activate AutoLock", isOn: $isBleAutoUnlockActivated)
                                    .onChange(of: isBleAutoUnlockActivated) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "BLE_AUTOLOCK_ACTIVATED")
                                        
                                        AlertManager.shared.publishAlert("Restart required", description: "A restart of the app is required to activate or deactivate the AutoLock feature.")
                                    }
                                
                                if(isBleAutoUnlockActivated) {
                                    TextField("OBD2 Device UUID", text: $obd2Uuid)
                                        .scrollDismissesKeyboard(.interactively)
                                        .autocorrectionDisabled(true)
                                }
                            }
                        }
                        .navigationTitle("Experimental Features")
                    }
                }
                
                Section("Account") {
                    SignOutButton()
                    DeleteAccountButton()
                }
            }
            .onAppear() {
                isBleAutoUnlockActivated = UserDefaults.standard.bool(forKey: "BLE_AUTOLOCK_ACTIVATED");
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

struct SignOutButton: View {
    @State var isShowingAlert = false;
    
    var body: some View {
        Button("Sign Out") {
            isShowingAlert = true;
        }
        .alert("Are you sure you want to sign out?", isPresented: $isShowingAlert, actions: {
            Button(role: .destructive) {
                AuthManager.shared.signOut();
            } label: {
                Text("Sign Out")
            }
        })
    }
}

struct DeleteAccountButton: View {
    @State var presentConfirmationModal = false;
    
    var body: some View {
        Button("Delete Account") {
            presentConfirmationModal = true;
        }
        .foregroundColor(.red)
        .alert(isPresented: $presentConfirmationModal) {
                    Alert(
                        title: Text("Are you sure you would like to delete your account?"),
                        message: Text("We will delete all data related to your account and it won't be possible to recover the data."),
                        primaryButton: .destructive(Text("Delete")) {
                            // ToDo: Delete account data
                        },
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
    }
}

struct ChangePrimaryVehicleButton: View {
    @State var isVehicleSelectionPresented = false;
    @State var vehicles: [VehicleIdentification]? = nil;
    @State var areSelectionsDisabled = false;
    
    private func onVehicleSelected(vin: String) {
        areSelectionsDisabled = true;
        
        Task {
            let wasSuccessful = await ApiClient.setPrimaryVehicle(vin: vin);
            
            if !wasSuccessful {
                AlertManager.shared.publishAlert("Error: Couldn't set primary vehicle", description: "Sorry, but we were unable to set your primary vehicle. Please try again.");
                isVehicleSelectionPresented = false;
                areSelectionsDisabled = false;
                vehicles = nil;
                return;
            }
            
            // Update primary vehicle info in the app
            _ = await VehicleManager.shared.getPrimaryVehicle(force: true);
            isVehicleSelectionPresented = false;
            areSelectionsDisabled = false;
            vehicles = nil;
        }
    }
    
    var body: some View {
        Button() {
            isVehicleSelectionPresented = true;
            Task {
                vehicles = await VehicleManager.shared.getVehicles();
            }
        }
    label: {
        Label("Change Vehicle", systemImage: "repeat")
    }
    .sheet(isPresented: $isVehicleSelectionPresented) {
        NavigationView {
            VStack () {
                
                Text("Currently, BetterKia does only support managing one vehicle at a time using the app. Therefore, you have to select a vehicle, that is associated with your KiaConnect account, you would like to use in this app.")
                    .padding()
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                if vehicles != nil {
                    List {
                        ForEach(vehicles!, id: \.vin) { vehicle in
                            SelectVehicleButton(vehicleVin: vehicle.vin, onClick: onVehicleSelected, isDisabled: areSelectionsDisabled)
                        }
                    }
                } else {
                    ProgressView()
                }
                
                Spacer()
            }
            .navigationTitle("Change Vehicle")
        }
    }
    }
}

struct SelectVehicleButton: View {
    var vehicleVin: String;
    
    var onClick: (_ vin: String) -> Void;
    
    @State var isLoading = false;
    
    var isDisabled: Bool;
    
    var body: some View {
        if !isLoading {
            Button() {
                isLoading = true;
                onClick(vehicleVin);
            }
        label: {
            Label("VIN: " + vehicleVin, systemImage: "number")
        }
        .disabled(isDisabled)
        } else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        .disabled(true)
        }
    }
}
