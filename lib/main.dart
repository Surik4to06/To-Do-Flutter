import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gerenciador de Tarefas',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Color(0xFF121212),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: TaskPage(),
    );
  }
}

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _controller = TextEditingController();
  final CollectionReference tasks = FirebaseFirestore.instance.collection(
    'tasks',
  );

  // Adicionar tarefa
  Future<void> addTask(String title) async {
    if (title.isNotEmpty) {
      await tasks.add({
        'title': title,
        'status': 'Pendente',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }
  }

  // Atualizar status
  Future<void> updateTask(String id, String newStatus) async {
    await tasks.doc(id).update({'status': newStatus});
  }

  // Atualizar título
  Future<void> editTask(String id, String currentTitle) async {
    TextEditingController editController = TextEditingController(
      text: currentTitle,
    );
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text("Editar tarefa", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          decoration: InputDecoration(hintText: "Novo título"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              if (editController.text.isNotEmpty) {
                await tasks.doc(id).update({'title': editController.text});
              }
              Navigator.pop(context);
            },
            child: Text("Salvar", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  // Deletar tarefa
  Future<void> deleteTask(String id) async {
    await tasks.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("To-Do"), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Digite uma tarefa"),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => addTask(_controller.text),
                  child: Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: tasks.orderBy("createdAt", descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var doc = data[index];
                    var task = doc.data() as Map<String, dynamic>;
                    return Card(
                      color: Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          "Status: ${task['status']}",
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onSelected: (value) {
                                if (value == 'Editar') {
                                  editTask(doc.id, task['title']);
                                } else {
                                  updateTask(doc.id, value);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: "Pendente",
                                  child: Text("Pendente"),
                                ),
                                PopupMenuItem(
                                  value: "Em andamento",
                                  child: Text("Em andamento"),
                                ),
                                PopupMenuItem(
                                  value: "Concluída",
                                  child: Text("Concluída"),
                                ),
                                PopupMenuItem(
                                  value: "Editar",
                                  child: Text("Editar"),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTask(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
