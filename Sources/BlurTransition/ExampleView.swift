//
//  ExampleView.swift
//  BlurTransition
    

import SwiftUI


struct ExampleView: View {
    @State private var selectedStyle: UIBlurEffect.Style = .prominent
    @State private var showInfoView: Bool = false
    
    
    var body: some View {
        GroupBox {
            Text("Transition Demo")
                .font(.headline)
                .padding(.bottom)
            
            
            Button {
                showInfoView = true
            } label: {
                Text("Present")
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
            }
            .tint(.purple)
            .buttonStyle(.bordered)
            .padding(.horizontal, 40)
        }
        .padding()
        .blurTransition(isPresented: $showInfoView, style: selectedStyle) {
            infoView
        }
    }
    
    var infoView: some View {
        VStack(spacing: 25) {
            Image(systemName: "swift")
                .font(.system(size: 65))
                .foregroundColor(.orange)
            
            Text("SwiftUI is Awesome!")
                .font(.title3.weight(.heavy))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topTrailing) {
            Image(systemName: "chevron.down.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.gray)
                .symbolRenderingMode(.hierarchical)
                .padding([.top, .trailing], 15)
                .onTapGesture { showInfoView = false }
        }
    }
}

#Preview {
    ExampleView()
}
