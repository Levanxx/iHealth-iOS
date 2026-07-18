import SwiftUI
import WebKit

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VoiceflowWebView()
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Asistente iHealth")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { Button("Cerrar") { dismiss() } }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct VoiceflowWebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.loadHTMLString(Self.html, baseURL: URL(string: "https://cdn.voiceflow.com"))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private static let html = """
    <!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>html,body{margin:0;background:transparent;height:100%;overflow:hidden}iframe{height:100%!important}</style></head><body><script>(function(d,t){var v=d.createElement(t),s=d.getElementsByTagName(t)[0];v.onload=function(){window.voiceflow.chat.load({verify:{projectID:'6a5bcee7aab64daa115f625b'},url:'https://general-runtime.voiceflow.com',voice:{url:'https://runtime-api.voiceflow.com'}}).then(function(){window.voiceflow.chat.open()})};v.src='https://cdn.voiceflow.com/widget-next/bundle.mjs';v.type='text/javascript';s.parentNode.insertBefore(v,s)})(document,'script');</script></body></html>
    """
}
