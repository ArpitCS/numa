import SwiftUI
import WebKit

@MainActor
struct BrowserView: View {
    @State private var viewModel: BrowserViewModel

    init(container: AppContainer) {
        _viewModel = State(initialValue: container.makeBrowserViewModel())
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            HStack(spacing: NumaSpacing.small) {
                Button(action: viewModel.page.goBack) {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.page.canGoBack)
                .accessibilityLabel("Back")

                Button(action: viewModel.page.goForward) {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.page.canGoForward)
                .accessibilityLabel("Forward")

                Button(action: viewModel.reloadOrStopLoading) {
                    Image(systemName: viewModel.page.isLoading ? "xmark" : "arrow.clockwise")
                }
                .accessibilityLabel(viewModel.page.isLoading ? "Stop Loading" : "Reload")

                TextField("Enter a URL", text: $viewModel.addressText)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("addressField")
                    .onSubmit(viewModel.submitAddress)
            }
            .padding(NumaSpacing.small)

            if viewModel.page.isLoading {
                ProgressView(value: viewModel.page.estimatedProgress)
                    .progressViewStyle(.linear)
            }

            if let errorMessage = viewModel.errorMessage {
                BrowserErrorView(message: errorMessage, retry: viewModel.retry)
            } else {
                BrowserWebView(webView: viewModel.page.webView)
            }
        }
        .onChange(of: viewModel.page.url) {
            viewModel.synchronizeAddressWithPage()
        }
        .onChange(of: viewModel.page.navigationErrorMessage) {
            guard let message = viewModel.page.navigationErrorMessage else {
                return
            }
            viewModel.errorMessage = message
        }
    }
}

private struct BrowserErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Unable to Load Page", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", action: retry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct BrowserWebView: NSViewRepresentable {
    let webView: WKWebView

    func makeNSView(context: Context) -> WKWebView {
        webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
}
