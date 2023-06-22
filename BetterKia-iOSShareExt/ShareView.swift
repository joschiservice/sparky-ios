//
//  ShareView.swift
//  BetterKia-iOSShareExt
//
//  Created by Joschua Haß on 17.06.23.
//
// iOS-App target is selected to make the Preview work

import Foundation
import SwiftUI

enum ShareViewLoadingStatus {
    case loading
    case success
    case error
}

class ShareViewState: ObservableObject {
    @Published var status = ShareViewLoadingStatus.loading
}

struct ShareView: View {
    init(status: ShareViewLoadingStatus = ShareViewLoadingStatus.loading) {
        self.state = ShareViewState();
        self.state.status = status
    }
    
    init(state: ShareViewState) {
        self.state = state;
    }
    
    @ObservedObject var state: ShareViewState
    @State private var showView = false;
    
    var body: some View {
        HStack {
            if showView {
                HStack {
                    switch state.status {
                    case .loading:
                        HStack(spacing: 20) {
                            ProgressView()
                            Text("Sending location to vehicle...")
                        }
                        .padding(26)
                        
                    case .success:
                        HStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(UIColor.systemGreen))
                                .font(.system(size: 24))
                            Text("Location sent to vehicle")
                        }
                        .padding(22)
                        
                    case .error:
                        HStack(spacing: 16) {
                            Image(systemName: "mappin.slash.circle")
                                .foregroundColor(Color(UIColor.systemRed))
                                .font(.system(size: 24))
                            Text("Failed to sent location to vehicle")
                        }
                        .padding(22)
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .animation(.easeInOut, value: 0.5)
            }
        }
        .onAppear {
            withAnimation {
                showView = true
            }
        }
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareView()
            .previewDisplayName("Loading")
        
        ShareView(status: .success)
            .previewDisplayName("Success")
        
        ShareView(status: .error)
            .previewDisplayName("Error")
    }
}
