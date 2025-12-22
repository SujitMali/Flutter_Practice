// import 'dart:convert';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:path_provider/path_provider.dart';

// // void main() {
// //   runApp(
// //     const MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: ReorderableListScreen(),
// //     ),
// //   );
// // }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // You may set the permission requests to "provisional" which allows the user to choose what type
//   // of notifications they would like to receive once the user receives a notification.
//   final notificationSettings = await FirebaseMessaging.instance
//       .requestPermission(provisional: true);

//   // For apple platforms, make sure the APNS token is available before making any FCM plugin API calls
//   final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//   if (apnsToken != null) {
//     // APNS token is available, make FCM plugin API requests...
//   }

//   runApp(
//     const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ReorderableListScreen(),
//     ),
//   );
// }

// /// ------------------------------
// /// DOMAIN MODEL
// /// ------------------------------
// class ReorderItem {
//   final String id;
//   final String title;
//   final String? imagePath;

//   ReorderItem({required this.id, required this.title, this.imagePath});

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'imagePath': imagePath,
//   };

//   factory ReorderItem.fromJson(Map<String, dynamic> json) {
//     return ReorderItem(
//       id: json['id'],
//       title: json['title'],
//       imagePath: json['imagePath'],
//     );
//   }

//   ReorderItem copyWith({String? imagePath}) {
//     return ReorderItem(id: id, title: title, imagePath: imagePath);
//   }
// }

// /// ------------------------------
// /// SCREEN
// /// ------------------------------
// class ReorderableListScreen extends StatefulWidget {
//   const ReorderableListScreen({super.key});

//   @override
//   State<ReorderableListScreen> createState() => _ReorderableListScreenState();
// }

// /// ------------------------------
// /// SCREEN STATE
// /// ------------------------------
// class _ReorderableListScreenState extends State<ReorderableListScreen> {
//   final ImagePicker _picker = ImagePicker();
//   List<ReorderItem> _items = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   /// ------------------------------
//   /// LOAD / SAVE
//   /// ------------------------------
//   Future<void> _loadItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final saved = prefs.getStringList('items');

//     if (saved != null) {
//       setState(() {
//         _items = saved.map((e) => ReorderItem.fromJson(jsonDecode(e))).toList();
//       });
//     } else {
//       setState(() {
//         _items = [];
//       });
//     }
//   }

//   Future<void> _saveItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final encoded = _items.map((e) => jsonEncode(e.toJson())).toList();
//     await prefs.setStringList('items', encoded);
//   }

//   /// ------------------------------
//   /// ADD NEW ITEM (➕ BUTTON)
//   /// ------------------------------
//   Future<void> _addNewItem() async {
//     final id = DateTime.now().millisecondsSinceEpoch.toString();

//     final newItem = ReorderItem(id: id, title: 'Item ${_items.length + 1}');

//     setState(() {
//       _items.add(newItem);
//     });

//     _saveItems();
//     await _pickImage(newItem);
//   }

//   /// ------------------------------
//   /// REORDER
//   /// ------------------------------
//   void _onReorder(int oldIndex, int newIndex) {
//     setState(() {
//       if (newIndex > oldIndex) newIndex--;
//       final item = _items.removeAt(oldIndex);
//       _items.insert(newIndex, item);
//     });
//     _saveItems();
//   }

//   /// ------------------------------
//   /// IMAGE ACTIONS
//   /// ------------------------------
//   void _handleImageTap(ReorderItem item) {
//     if (item.imagePath == null) {
//       _pickImage(item);
//     } else {
//       _showImageDialog(item);
//     }
//   }

//   Future<void> _pickImage(ReorderItem item) async {
//     final picked = await _picker.pickImage(
//       source: ImageSource.camera,
//       imageQuality: 85,
//     );

//     if (picked == null) return;

//     final appDir = await getApplicationDocumentsDirectory();
//     final newPath =
//         '${appDir.path}/${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

//     final savedImage = await File(picked.path).copy(newPath);

//     setState(() {
//       final index = _items.indexWhere((e) => e.id == item.id);
//       _items[index] = _items[index].copyWith(imagePath: savedImage.path);
//     });

//     _saveItems();
//   }

//   Future<void> _removeImage(ReorderItem item) async {
//     final index = _items.indexWhere((e) => e.id == item.id);
//     final path = _items[index].imagePath;

//     if (path != null) {
//       final file = File(path);
//       if (await file.exists()) {
//         await file.delete();
//       }
//     }

//     setState(() {
//       _items[index] = _items[index].copyWith(imagePath: null);
//     });

//     _saveItems();
//   }

//   void _showImageDialog(ReorderItem item) {
//     showDialog(
//       context: context,
//       builder: (_) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ClipRRect(
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(16),
//                 ),
//                 child: Image.file(
//                   File(item.imagePath!),
//                   height: 250,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   TextButton.icon(
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text('Replace'),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _pickImage(item);
//                     },
//                   ),
//                   TextButton.icon(
//                     icon: const Icon(Icons.delete, color: Colors.red),
//                     label: const Text(
//                       'Remove',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _removeImage(item);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// ------------------------------
//   /// ITEM UI (UNCHANGED)
//   /// ------------------------------
//   Widget _buildItem(ReorderItem item) {
//     final isLandscape =
//         MediaQuery.of(context).orientation == Orientation.landscape;

//     return Padding(
//       key: ValueKey(item.id),
//       padding: EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: isLandscape ? 6 : 8,
//       ),
//       child: Card(
//         elevation: 1,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         clipBehavior: Clip.antiAlias,
//         child: InkWell(
//           onTap: () => _handleImageTap(item),
//           child: SizedBox(
//             height: isLandscape ? 80 : 100,
//             child: Row(
//               children: [
//                 const SizedBox(width: 12),
//                 if (item.imagePath != null)
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.file(
//                       File(item.imagePath!),
//                       width: isLandscape ? 56 : 64,
//                       height: isLandscape ? 56 : 64,
//                       fit: BoxFit.cover,
//                     ),
//                   )
//                 else
//                   Container(
//                     width: isLandscape ? 56 : 64,
//                     height: isLandscape ? 56 : 64,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(Icons.camera_alt, color: Colors.grey),
//                   ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(
//                     item.title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16),
//                   child: Icon(
//                     Icons.drag_indicator,
//                     size: 28,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// ------------------------------
//   /// BUILD
//   /// ------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Reorder + Camera Images'),
//         centerTitle: true,
//         actions: [
//           IconButton(icon: const Icon(Icons.add), onPressed: _addNewItem),
//         ],
//       ),
//       body: SafeArea(
//         child: ReorderableListView(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           onReorder: _onReorder,
//           children: _items.map(_buildItem).toList(),
//           proxyDecorator: (child, index, animation) {
//             return AnimatedBuilder(
//               animation: animation,
//               builder: (context, _) {
//                 return Transform.scale(
//                   scale: 1.04,
//                   child: Material(
//                     elevation: 8,
//                     color: Colors.transparent,
//                     shadowColor: Colors.black54,
//                     borderRadius: BorderRadius.circular(12),
//                     clipBehavior: Clip.antiAlias,
//                     child: child,
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReorderableListScreen(),
    ),
  );
}

/// ------------------------------
/// DOMAIN MODEL
/// ------------------------------
class ReorderItem {
  final String id;
  final String title;
  final String? imagePath;

  ReorderItem({required this.id, required this.title, this.imagePath});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'imagePath': imagePath,
  };

  factory ReorderItem.fromJson(Map<String, dynamic> json) {
    return ReorderItem(
      id: json['id'],
      title: json['title'],
      imagePath: json['imagePath'],
    );
  }

  ReorderItem copyWith({String? imagePath}) {
    return ReorderItem(id: id, title: title, imagePath: imagePath);
  }
}

/// ------------------------------
/// SCREEN
/// ------------------------------
class ReorderableListScreen extends StatefulWidget {
  const ReorderableListScreen({super.key});

  @override
  State<ReorderableListScreen> createState() => _ReorderableListScreenState();
}

/// ------------------------------
/// SCREEN STATE
/// ------------------------------
class _ReorderableListScreenState extends State<ReorderableListScreen> {
  final ImagePicker _picker = ImagePicker();
  List<ReorderItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
    _setupFCMListeners();
  }

  /// ------------------------------
  /// FIREBASE MESSAGING SETUP
  /// ------------------------------
  void _setupFCMListeners() async {
    await FirebaseMessaging.instance.requestPermission();

    // App opened from TERMINATED state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationAction(initialMessage.data);
    }

    // App opened from BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationAction(message.data);
    });

    // App in FOREGROUND
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM Foreground message: ${message.data}');
    });
  }

  /// ------------------------------
  /// NOTIFICATION ACTION ROUTER
  /// ------------------------------
  void _handleNotificationAction(Map<String, dynamic> data) {
    final action = data['action'];

    if (action == 'quick_add') {
      _addNewItem();
    }
  }

  /// ------------------------------
  /// LOAD / SAVE
  /// ------------------------------
  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('items');

    if (saved != null) {
      setState(() {
        _items = saved.map((e) => ReorderItem.fromJson(jsonDecode(e))).toList();
      });
    } else {
      setState(() {
        _items = [];
      });
    }
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _items.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('items', encoded);
  }

  /// ------------------------------
  /// ADD NEW ITEM
  /// ------------------------------
  Future<void> _addNewItem() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = ReorderItem(id: id, title: 'Item ${_items.length + 1}');

    setState(() {
      _items.add(newItem);
    });

    _saveItems();
    await _pickImage(newItem);
  }

  /// ------------------------------
  /// REORDER
  /// ------------------------------
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
    });
    _saveItems();
  }

  /// ------------------------------
  /// IMAGE ACTIONS
  /// ------------------------------
  void _handleImageTap(ReorderItem item) {
    if (item.imagePath == null) {
      _pickImage(item);
    } else {
      _showImageDialog(item);
    }
  }

  Future<void> _pickImage(ReorderItem item) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (picked == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final newPath =
        '${appDir.path}/${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final savedImage = await File(picked.path).copy(newPath);

    setState(() {
      final index = _items.indexWhere((e) => e.id == item.id);
      _items[index] = _items[index].copyWith(imagePath: savedImage.path);
    });

    _saveItems();
  }

  Future<void> _removeImage(ReorderItem item) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    final path = _items[index].imagePath;

    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    setState(() {
      _items[index] = _items[index].copyWith(imagePath: null);
    });

    _saveItems();
  }

  void _showImageDialog(ReorderItem item) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.file(
                  File(item.imagePath!),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Replace'),
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(item);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _removeImage(item);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  /// ------------------------------
  /// ITEM UI (UNCHANGED)
  /// ------------------------------
  Widget _buildItem(ReorderItem item) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Padding(
      key: ValueKey(item.id),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isLandscape ? 6 : 8,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _handleImageTap(item),
          child: SizedBox(
            height: isLandscape ? 80 : 100,
            child: Row(
              children: [
                const SizedBox(width: 12),
                if (item.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(item.imagePath!),
                      width: isLandscape ? 56 : 64,
                      height: isLandscape ? 56 : 64,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: isLandscape ? 56 : 64,
                    height: isLandscape ? 56 : 64,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.grey),
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
                  child: Icon(
                    Icons.drag_indicator,
                    size: 28,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ------------------------------
  /// BUILD
  /// ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder + Camera Images'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addNewItem),
        ],
      ),
      body: SafeArea(
        child: ReorderableListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          onReorder: _onReorder,
          children: _items.map(_buildItem).toList(),
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Transform.scale(
                  scale: 1.04,
                  child: Material(
                    elevation: 8,
                    color: Colors.transparent,
                    shadowColor: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
