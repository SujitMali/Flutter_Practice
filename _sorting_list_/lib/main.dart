import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reorder With Images',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ReorderableListScreen(),
    );
  }
}

/// ------------------------------
/// DATA MODEL (CRITICAL PART)
/// ------------------------------
class ReorderItem {
  final String id; // Stable identity (never changes)
  final String title; // Display text
  final String? imagePath; // Local image path (nullable)

  ReorderItem({required this.id, required this.title, this.imagePath});

  /// Converts object → JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imagePath': imagePath,
  };

  /// Converts JSON → object when loading
  factory ReorderItem.fromJson(Map<String, dynamic> json) {
    return ReorderItem(
      id: json['id'],
      title: json['title'],
      imagePath: json['imagePath'],
    );
  }

  /// Creates a new copy with updated image
  ReorderItem copyWith({String? imagePath}) {
    return ReorderItem(id: id, title: title, imagePath: imagePath);
  }
}

class ReorderableListScreen extends StatefulWidget {
  const ReorderableListScreen({super.key});

  @override
  State<ReorderableListScreen> createState() => _ReorderableListScreenState();
}

class _ReorderableListScreenState extends State<ReorderableListScreen> {
  final ImagePicker _picker = ImagePicker();

  /// SINGLE SOURCE OF TRUTH
  List<ReorderItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('items');

    if (saved != null) {
      setState(() {
        _items = saved.map((e) => ReorderItem.fromJson(jsonDecode(e))).toList();
      });
    } else {
      setState(() {
        _items = List.generate(
          10,
          (i) => ReorderItem(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            title: 'Item ${i + 1}',
          ),
        );
      });

      _saveItems();
    }
  }

  /// Persists entire list (order + images)
  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('items', encoded);
  }

  /// Handles drag reordering (pure list logic)
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    _saveItems();
  }

  /// Picks image and attaches it to a specific item
  Future<void> _pickImage(ReorderItem item) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      final index = _items.indexWhere((e) => e.id == item.id);
      _items[index] = _items[index].copyWith(imagePath: picked.path);
    });

    _saveItems();
  }

  /// Builds ONE card
  Widget _buildItem(ReorderItem item) {
    return Card(
      key: ValueKey(item.id),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _pickImage(item),
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              const SizedBox(width: 12),

              /// Image (if exists)
              if (item.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(item.imagePath!),
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),

              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.drag_indicator, size: 28, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reorder + Images'), centerTitle: true),
      body: ReorderableListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),

        /// Drag visual effect
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              final scale = 1 + (0.05 * animation.value);
              return Transform.scale(
                scale: scale,
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  shadowColor: Colors.black45,
                  child: child,
                ),
              );
            },
          );
        },

        onReorder: _onReorder,
        children: _items.map(_buildItem).toList(),
      ),
    );
  }
}
