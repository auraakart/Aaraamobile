import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        showLeading: true,
        centerTitle: false,
        title: MyAppText(data: widget.title),
      ),
      body: widget.url.isEmpty
          ? const Center(
              child: MyAppText(
                data: 'Invalid page link.',
                align: TextAlign.center,
              ),
            )
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    mixedContentMode:
                        MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                    useShouldOverrideUrlLoading: false,
                    transparentBackground: true,
                    cacheEnabled: true,
                  ),
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress >= 70 && _isLoading && mounted) {
                      setState(() {
                        _isLoading = false;
                        _hasError = false;
                      });
                    }
                  },
                  onLoadStop: (controller, url) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _hasError = false;
                      });
                    }
                  },
                  onReceivedServerTrustAuthRequest:
                      (controller, challenge) async {
                    return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED,
                    );
                  },
                  onReceivedError: (controller, request, error) {
                    if (error.type == WebResourceErrorType.CANCELLED ||
                        error.description.contains('ERR_ABORTED')) {
                      return;
                    }
                    final isMainFrame = request.isForMainFrame == true;
                    if (isMainFrame && mounted) {
                      setState(() {
                        _isLoading = false;
                        _hasError = true;
                      });
                    }
                  },
                ),
                if (_hasError)
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MyAppText(
                          data:
                              'Unable to load this page. Please check your internet connection.',
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _hasError = false;
                            });
                            _webViewController?.reload();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                if (_isLoading && !_hasError)
                  Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandPrimary,
                    ),
                  ),
              ],
            ),
    );
  }
}
