from pathlib import Path

TARGETS = (
    Path("aaraakart/lib/presentation/payment/payment_screen.dart"),
    Path("aaraakart/lib/presentation/payment/paytm_webview_screen.dart"),
)

HELPER = "\n// Payment flows must not emit gateway URLs, identifiers, amounts, callback\n// payloads, console output, or raw exceptions from the client.\nvoid _paymentDiagnostic(Object? _) {}\n"
IMPORT_MARKER = "import 'package:intl/intl.dart';\n"

for path in TARGETS:
    text = path.read_text(encoding="utf-8")
    text = text.replace("debugPrint(", "_paymentDiagnostic(")
    text = text.replace("print(", "_paymentDiagnostic(")

    if "void _paymentDiagnostic(Object? _) {}" not in text:
        if IMPORT_MARKER not in text:
            raise SystemExit(f"Expected import marker not found in {path}")
        text = text.replace(IMPORT_MARKER, IMPORT_MARKER + HELPER, 1)

    path.write_text(text, encoding="utf-8")
