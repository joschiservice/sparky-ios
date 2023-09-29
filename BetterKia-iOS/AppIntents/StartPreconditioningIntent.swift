//
//  StartPreconditioningIntent.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 28.09.23.
//

import AppIntents

struct StartPreconditioningIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Preconditioning";
    
    @Parameter(title: "Temperature")
    var temperatureInput: Int?;
    
    func perform() async throws -> some ProvidesDialog {
        var temperature = self.temperatureInput;
        
        if temperature == nil {
            temperature = try await $temperatureInput.requestValue(IntentDialog("To which temperature would you like to precondition your vehicle?"));
        }
        
        return .result(dialog: IntentDialog("Alright. The preconditioning for your vehicle has been started and your vehicle should be ready in about 10 minutes."))
    }
}
