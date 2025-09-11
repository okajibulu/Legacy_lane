import 'dart:convert';
import 'package:http/http.dart' as http;

class ParsedFile {
  final String filename;
  final String filepath;
  final String content;

  ParsedFile({required this.filename, required this.filepath, required this.content});

  factory ParsedFile.fromJson(Map<String, dynamic> json) {
    return ParsedFile(
      filename: json['filename'],
      filepath: json['filepath'],
      content: json['content'],
    );
  }
}

class ParserService {
  final String baseUrl = 'http://localhost:3000';

  Future<List<ParsedFile>> fetchParsedFiles() async {
    final response = await http.get(Uri.parse('$baseUrl/parse'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ParsedFile.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load parsed files');
    }
  }
}
