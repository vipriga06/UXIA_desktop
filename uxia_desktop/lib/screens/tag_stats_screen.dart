import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../widgets/common_widgets.dart';

class TagStatsScreen extends StatefulWidget {
  final ApiService apiService;
  const TagStatsScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<TagStatsScreen> createState() => _TagStatsScreenState();
}

class _TagStatsScreenState extends State<TagStatsScreen> {
  List<TagStat> tags = [];
  List<TagStat> groupedTags = [];
  List<TagStat> otherTags = [];
  bool showOtherExpanded = false;
  Set<String> selectedTags = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchTags();
  }

  Future<void> fetchTags() async {
    setState(() { loading = true; error = null; });
    try {
      final response = await widget.apiService.get('/api/tags/stats');
      final json = response.body.isNotEmpty ? response.body : '{}';
      final data = jsonDecode(json);
      if (data['status'] == 'OK') {
        final d = data['data'];
        if (d != null && d['tags'] is List) {
          tags = (d['tags'] as List).map((e) => TagStat.fromJson(e)).toList();
          // Agrupar tags menores al 20% del mayor en 'Altres'
          if (tags.isNotEmpty) {
            final maxCount = tags.map((e) => e.count).reduce((a, b) => a > b ? a : b);
            final threshold = (maxCount * 0.2).ceil();
            final mainTags = <TagStat>[];
            final others = <TagStat>[];
            for (final t in tags) {
              if (t.count >= threshold) {
                mainTags.add(t);
              } else {
                others.add(t);
              }
            }
            otherTags = others;
            if (others.isNotEmpty) {
              mainTags.add(TagStat(tag: 'Altres', count: -threshold));
            }
            groupedTags = mainTags;
          } else {
            groupedTags = [];
            otherTags = [];
          }
          // Selecciona todos los tags por defecto
          selectedTags = groupedTags.map((t) => t.tag).toSet();
        } else {
          error = 'Resposta inesperada del servidor (falta camp "tags")';
        }
      } else {
        error = data['message'] ?? 'Error desconegut';
      }
    } catch (e) {
      error = e.toString();
    }
    setState(() { loading = false; });
  }

  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en la gráfica los tags seleccionados
    final filteredTags = groupedTags.where((t) => selectedTags.contains(t.tag)).toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: CommonWidgets.buildAppBar(title: "Estadístiques d'etiquetes"),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!))
                  : Row(
                      children: [
                        // Barra lateral
                        Container(
                          width: 200,
                          color: Colors.grey[100],
                          child: ListView(
                            children: [
                              ...groupedTags.map((tag) {
                                final color = tag.tag == 'Altres' ? Colors.grey : tagColor(tag.tag);
                                final selected = selectedTags.contains(tag.tag);
                                if (tag.tag != 'Altres') {
                                  return ListTile(
                                    title: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            tag.tag,
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ],
                                    ),
                                    leading: CircleAvatar(backgroundColor: color),
                                    trailing: selected
                                        ? const Icon(Icons.check, color: Colors.green)
                                        : null,
                                    selected: selected,
                                    onTap: () => toggleTag(tag.tag),
                                  );
                                } else {
                                  return ExpansionTile(
                                    title: Row(
                                      children: [
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Text(
                                            'Altres',
                                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            otherTags.length.toString(),
                                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                    leading: CircleAvatar(backgroundColor: Colors.grey),
                                    trailing: selected
                                        ? const Icon(Icons.check, color: Colors.green)
                                        : null,
                                    initiallyExpanded: showOtherExpanded,
                                    onExpansionChanged: (expanded) {
                                      setState(() { showOtherExpanded = expanded; });
                                    },
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ...otherTags.map((ot) => Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      dense: true,
                                                      title: Text(
                                                        ot.tag,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(fontSize: 13),
                                                      ),
                                                      leading: const SizedBox(width: 32),
                                                      trailing: Text(ot.count.toString(), style: const TextStyle(fontSize: 12)),
                                                    ),
                                                    // Divider eliminado
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                    // onTap y selected solo en ListTile, no ExpansionTile
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                        // Gràfica de barres
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: TagBarChart(
                              tags: filteredTags,
                              selectedTags: selectedTags,
                              availableWidth: constraints.maxWidth - 200 - 48, // 200 sidebar + 2*24 padding
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  // Assigna un color únic per etiqueta
  Color tagColor(String tag) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.amber, Colors.pink, Colors.cyan, Colors.indigo
    ];
    final idx = tag.hashCode.abs() % colors.length;
    return colors[idx];
  }
}

class TagStat {
  final String tag;
  final int count;
  TagStat({required this.tag, required this.count});
  factory TagStat.fromJson(Map<String, dynamic> json) =>
      TagStat(tag: json['tag'], count: json['count']);
}

class TagBarChart extends StatelessWidget {
  final List<TagStat> tags;
  final Set<String> selectedTags;
  final double availableWidth;
  const TagBarChart({required this.tags, required this.selectedTags, required this.availableWidth, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const Center(child: Text('No hi ha dades d\'etiquetes.'));
    }
    final maxCount = tags.map((e) => e.count).fold(0, (a, b) => a > b ? a : b);
    // Ajustar ancho de barra y espaciado según el espacio disponible
    final barWidth = 40.0;
    final minSpacing = 16.0;
    final n = tags.length;
    double spacing = minSpacing;
    double leftPad = 40;
    double rightPad = 40;
    double totalWidth = n * barWidth + (n - 1) * spacing;
    if (totalWidth + leftPad + rightPad > availableWidth) {
      spacing = ((availableWidth - leftPad - rightPad) - n * barWidth) / (n - 1);
      if (spacing < 2) spacing = 2;
      totalWidth = n * barWidth + (n - 1) * spacing;
    }
    // Centrar la gráfica si sobra espacio
    final extraSpace = availableWidth - (totalWidth + leftPad + rightPad);
    if (extraSpace > 0) {
      leftPad += extraSpace / 2;
      rightPad += extraSpace / 2;
    }
    return CustomPaint(
      size: Size(availableWidth, 400),
      painter: TagBarChartPainter(tags, selectedTags, barWidth: barWidth, spacing: spacing, leftPad: leftPad, rightPad: rightPad),
    );
  }
}

class TagBarChartPainter extends CustomPainter {
  final List<TagStat> tags;
  final Set<String> selectedTags;
  final double barWidth;
  final double spacing;
  final double leftPad;
  final double rightPad;
  TagBarChartPainter(this.tags, this.selectedTags, {required this.barWidth, required this.spacing, required this.leftPad, required this.rightPad});

  @override
  void paint(Canvas canvas, Size size) {
    final maxCount = tags.map((e) => e.count).fold(1, (a, b) => a > b ? a : b);
    final chartHeight = size.height - 40;
    final paint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < tags.length; i++) {
      final tag = tags[i];
      final x = i * (barWidth + spacing) + leftPad;
      double barHeight;
      if (tag.tag == 'Altres' && tag.count < 0) {
        // Mostrar una barra pequeña para 'Altres'
        barHeight = (0.15) * chartHeight;
      } else {
        barHeight = (tag.count / maxCount) * chartHeight;
      }
      final y = size.height - barHeight - 20;
      paint.color = tag.tag == 'Altres' ? Colors.grey : _tagColor(tag.tag, i);
      // Dibuixa la barra
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), paint);
      // Dibuixa el text de la etiqueta (rotado para evitar solapamiento)
      textPainter.text = TextSpan(
        text: tag.tag,
        style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w500),
      );
      textPainter.layout(minWidth: 0, maxWidth: 80);
      // Rotar -45 grados y pintar debajo de la barra
      final labelX = x + barWidth / 2;
      final labelY = size.height - 2;
      const labelOffset = 8.0;
      // Ajuste de centrado para compensar la rotación y el ancho del texto
      final centerCorrectionY = textPainter.height / 2.2;
      final centerCorrectionX = (textPainter.width / 2) * (1 - 1 / 1.4142); // 1/sqrt(2)
      canvas.save();
      canvas.translate(labelX - centerCorrectionX, labelY + labelOffset + centerCorrectionY);
      canvas.rotate(-0.785398); // -45 grados en radianes
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();
      // Dibuixa el valor
      String valueText;
      if (tag.tag == 'Altres' && tag.count < 0) {
        valueText = '>' + (-tag.count).toString();
      } else {
        valueText = tag.count.toString();
      }
      textPainter.text = TextSpan(
        text: valueText,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );
      textPainter.layout(minWidth: 0, maxWidth: barWidth + 10);
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, y - 18));
    }
  }

  Color _tagColor(String tag, int index) {
    // Paleta extendida para evitar repeticiones
    const colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.amber, Colors.pink, Colors.cyan, Colors.indigo,
      Colors.lime, Colors.deepOrange, Colors.deepPurple, Colors.lightBlue,
      Colors.lightGreen, Colors.brown, Colors.blueGrey, Colors.yellow,
      Colors.grey, Colors.lightGreenAccent, Colors.indigoAccent, Colors.purpleAccent
    ];
    // Asignar color por índice para evitar repeticiones visuales
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
