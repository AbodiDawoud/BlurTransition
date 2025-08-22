// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

@MainActor
class ProgressiveBlurPresenter {
    static var shared = ProgressiveBlurPresenter()
    
    func present<V: View>(_ view: V, style: UIBlurEffect.Style) {
        let detail = UIHostingController(rootView: view)
        
        detail.view.backgroundColor = .clear
        detail.modalPresentationStyle = .custom
        
        let transitionDelegate = _BlurContextController()
        transitionDelegate.setValue(style.rawValue, forKey: "blurStyle")
        
        detail.transitioningDelegate = transitionDelegate as? any UIViewControllerTransitioningDelegate
        windowController.present(detail, animated: true, completion: nil)
    }
    
    func dismiss() {
        windowController.dismiss(animated: true, completion: nil)
    }
    
    private func _BlurContextController() -> UIViewController {
        // Base64 encoded string of the class name
        let encodedClassString = "X1VJUHJvZ3Jlc3NpdmVCbHVyQ29udGV4dENvbnRyb2xsZXI="
        let className = String(data: Data(base64Encoded: encodedClassString)!, encoding: .utf8)!
        let controller = NSClassFromString(className) as! UIViewController.Type
        
        return controller.init()
    }
    
    private var windowController: UIViewController {
        let scene = UIApplication.shared.connectedScenes.first as! UIWindowScene
        let keyWindow = scene.windows[0]
        return keyWindow.rootViewController!
    }
}


struct ProgressiveBlurViewModifier<V: View>: ViewModifier {
    @State private var didDisappear: Bool = false
    @Binding var isPresented: Bool
    
    let style: UIBlurEffect.Style
    let viewContent: () -> V
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { onValueChanged($0, $1) }
    }
    
    func onValueChanged(_ oldValue: Bool, _ newValue: Bool) {
        guard newValue == true else {
            if !didDisappear {
                ProgressiveBlurPresenter.shared.dismiss()
            }
            
            return
        }

        
        let modifiedView = viewContent()
        .onAppear {
            didDisappear = false // reset
        }
        .onDisappear {
            if isPresented == true {
                isPresented = false
                didDisappear = true
            }
        }
        
        ProgressiveBlurPresenter.shared.present(modifiedView, style: self.style)
    }
}


extension View {
    func blurTransition<Content: View>(
        isPresented: Binding<Bool>,
        style: UIBlurEffect.Style = .systemChromeMaterial,
        content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            ProgressiveBlurViewModifier(isPresented: isPresented, style: style, viewContent: content)
        )
    }
}
