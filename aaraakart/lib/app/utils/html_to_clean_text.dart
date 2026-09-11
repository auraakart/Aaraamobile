import 'package:html/parser.dart';
import 'package:html/dom.dart';

String htmlToCleanText(String htmlString) {
  Document document = parse(htmlString);

  StringBuffer buffer = StringBuffer();

  void parseNode(Node node) {
    if (node is Text) {
      buffer.write(node.text.trim());
    }

    if (node is Element) {
      switch (node.localName) {
        case 'p':
          if (buffer.isNotEmpty) buffer.write("\n\n");
          break;

        case 'br':
          buffer.write("\n");
          break;

        case 'li':
          buffer.write("• ");
          break;

        case 'ul':
          if (buffer.isNotEmpty) buffer.write("\n");
          break;
      }

      node.nodes.forEach(parseNode);

      if (node.localName == 'li') {
        buffer.write("\n");
      }
    }
  }

  document.body?.nodes.forEach(parseNode);

  return buffer.toString().trim();
}


