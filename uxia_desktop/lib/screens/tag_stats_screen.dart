import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart';

class TagStatsScreen extends StatefulWidget {
  final ApiService apiService;
  const TagStatsScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<TagStatsScreen> createState() => _TagStatsScreenState();
}

class _TagStatsScreenState extends State<TagStatsScreen> {
  List<TagStat> tags = [];
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
        tags = (data['data'] as List)
            .map((e) => TagStat.fromJson(e)).toList();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Estadístiques d\'etiquetes')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Row(
                  children: [
                    // Barra lateral
                    Container(
                      width: 180,
                      color: Colors.grey[100],
                      child: ListView(
                        children: tags.map((tag) {
                          final color = tagColor(tag.tag);
                          final selected = selectedTags.contains(tag.tag);
                          return ListTile(
                            title: Text(tag.tag),
                            leading: CircleAvatar(backgroundColor: color),
                            trailing: selected
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            selected: selected,
                            onTap: () => toggleTag(tag.tag),
                          );
                        }).toList(),
                      ),
                    ),
                    // Gràfica de barres
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: TagBarChart(
                          tags: tags,
                          selectedTags: selectedTags,
                        ),
                      ),
                    ),
                  ],
                ),
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
  const TagBarChart({required this.tags, required this.selectedTags, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const Center(child: Text('No hi ha dades d\'etiquetes.'));
    }
    final maxCount = tags.map((e) => e.count).fold(0, (a, b) => a > b ? a : b);
    return CustomPaint(
      size: Size(double.infinity, 400),
      painter: TagBarChartPainter(tags, selectedTags),
    );
  }
}

class TagBarChartPainter extends CustomPainter {
  final List<TagStat> tags;
  final Set<String> selectedTags;
  TagBarChartPainter(this.tags, this.selectedTags);

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 40.0;
    final spacing = 24.0;
    final maxCount = tags.map((e) => e.count).fold(1, (a, b) => a > b ? a : b);
    final chartHeight = size.height - 40;
    final paint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < tags.length; i++) {
      final tag = tags[i];
      final x = i * (barWidth + spacing) + 40;
      final barHeight = (tag.count / maxCount) * chartHeight;
      final y = size.height - barHeight - 20;
      paint.color = selectedTags.contains(tag.tag)
          ? _tagColor(tag.tag)
          : Colors.grey[400]!;
      // Dibuixa la barra
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), paint);
      // Dibuixa el text de la etiqueta
      textPainter.text = TextSpan(
        text: tag.tag,
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );
      textPainter.layout(minWidth: 0, maxWidth: barWidth + 20);
      textPainter.paint(canvas, Offset(x - 10, size.height - 18));
      // Dibuixa el valor
      textPainter.text = TextSpan(
        text: tag.count.toString(),
        style: const TextStyle(fontSize: 12, color: Colors.black),
      );
      textPainter.layout(minWidth: 0, maxWidth: barWidth + 20);
      textPainter.paint(canvas, Offset(x, y - 18));
    }
  }

  Color _tagColor(String tag) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.amber, Colors.pink, Colors.cyan, Colors.indigo
    ];
    final idx = tag.hashCode.abs() % colors.length;
    return colors[idx];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
