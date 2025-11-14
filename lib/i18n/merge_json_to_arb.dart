import 'dart:convert';
import 'dart:io';

void main() async {
  const languageCodes = ['en', 'es'];

  for (final lang in languageCodes) {
    final output = <String, dynamic>{};
    final dir = Directory('lib/i18n');

    final files = dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('_$lang.json'));

    for (final file in files) {
      final jsonData = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      jsonData.forEach((key, value) {
        if (output.containsKey(key)) {
          if (key.startsWith('@')) {
            // Si la clave de descripción ya existe, podrías hacer merge aquí si quieres.
            // Por simplicidad, mantenemos la que ya está.
          } else {
            // Para claves regulares, reemplazamos (último gana).
            output[key] = value;
          }
        } else {
          output[key] = value;
        }
      });
    }

    final outFile = File('lib/i18n/app_$lang.arb');
    await outFile.writeAsString(JsonEncoder.withIndent('  ').convert(output));
    print('🚀 Generated: ${outFile.path}');
  }
}
