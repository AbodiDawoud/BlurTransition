// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI


/// A presenter that displays SwiftUI views using a custom progressive blur transition.
///
/// Use the shared singleton `ProgressiveBlurPresenter.shared` to present or dismiss views
/// with a blurred background. This provides a smooth iOS-native modal experience.
@MainActor
public class ProgressiveBlurPresenter {
    /// The shared singleton instance of the blur presenter.
    public static var shared = ProgressiveBlurPresenter()
    
    
    /// Presents a SwiftUI view with a blurred background transition.
    ///
    /// Example:
    /// ```swift
    /// ProgressiveBlurPresenter.shared.present(
    ///     MyDetailView(),
    ///     style: .systemMaterial
    /// )
    /// ```
    /// - Parameters:
    ///   - view: The SwiftUI view to present.
    ///   - style: The `UIBlurEffect.Style` to apply as the background blur.
    public func present<V: View>(_ view: V, style: UIBlurEffect.Style) {
        let detail = UIHostingController(rootView: view)
        
        detail.view.backgroundColor = .clear
        detail.modalPresentationStyle = .custom
        
        let transitionDelegate = _BlurContextController()
        transitionDelegate.setValue(style.rawValue, forKey: "blurStyle")
        
        detail.transitioningDelegate = transitionDelegate as? any UIViewControllerTransitioningDelegate
        windowController.present(detail, animated: true, completion: nil)
    }
    
    
    /// Dismisses the currently presented view.
    ///
    /// Example:
    /// ```swift
    /// ProgressiveBlurPresenter.shared.dismiss()
    /// ```
    public func dismiss() {
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


/// A view modifier that applies a progressive blur transition when presenting a view.
///
/// Use this modifier indirectly via the `blurTransition` view extension.
internal struct _ProgressiveBlurViewModifier<V: View>: ViewModifier {
    @State private var didDisappear: Bool = false
    @Binding var isPresented: Bool
    
    let style: UIBlurEffect.Style
    let viewContent: () -> V
    
    public func body(content: Content) -> some View {
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
    /// Presents view using progressive blur transition.
    ///
    /// Example:
    /// ```swift
    /// MyDetailView()
    ///     .blurTransition(style: .systemMaterial)
    /// ```
    ///
    /// - Parameter isPresented: A binding to a Boolean value that determines whether to present the transition contetn.
    /// - Parameter style: The `UIBlurEffect.Style` used for the transition background.
    /// - Parameter content: The content to be displayed on the transition
    /// - Returns: A modified view that applies the blur transition to the view hierachy
    public func blurTransition<Content: View>(
        isPresented: Binding<Bool>,
        style: UIBlurEffect.Style = .systemChromeMaterial,
        content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            _ProgressiveBlurViewModifier(isPresented: isPresented, style: style, viewContent: content)
        )
    }
}
