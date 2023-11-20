//
//  StartPreconditioningIntent.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 28.09.23.
//

import AppIntents

struct StartPreconditioningIntent: AuthAppIntent {
    static let title: LocalizedStringResource = "Start Preconditioning"
    static let description: IntentDescription? = IntentDescription("Starts the preconditioning of your active vehicle", categoryName: "Vehicle Control")
    
    @Parameter(title: "Temperature")
    var temperatureInput: Int?
    
    func perform() async throws -> some ProvidesDialog {
        if let errorDialog = try await canPerform() {
            return .result(dialog: errorDialog)
        }
        
        var temperature = self.temperatureInput
        
        if temperature == nil {
            temperature = try await $temperatureInput.requestValue(IntentDialog("To which temperature would you like to precondition your vehicle?"))
        }
        
        let result = await ApiClient.startVehicle(data: StartVehicleRequest(temperature: Double(temperature!), withLiveActivityTip: false, durationMinutes: 10));
        
        if result == nil || result!.error {
            return .result(dialog: IntentDialog("Sorry, but the preconditioning couldn't be started. Please try again later."))
        } else {
            return .result(dialog: IntentDialog("Alright. The preconditioning for your vehicle has been started and your vehicle should be ready in about 10 minutes."))
        }
    }
}
