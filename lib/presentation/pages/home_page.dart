import 'package:bmapp/presentation/pages/analysis_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para Numeric Input
//import 'analysis_page.dart'; // Asegúrate de que este import sea correcto
// import 'vertical_jump_page.dart'; // Descomentar cuando crees esta página

class HomePageController {
  final TextEditingController identificationController =
      TextEditingController();
  final TextEditingController sessionController = TextEditingController();
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageController _controller = HomePageController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.identificationController.dispose();
    _controller.sessionController.dispose();
    super.dispose();
  }

  // Lógica para Navegación al Análisis de Marcha
  void _startGaitAnalysis() {
    if (_formKey.currentState!.validate()) {
      final String id = _controller.identificationController.text;
      final int session = int.tryParse(_controller.sessionController.text) ?? 1;

      // Navegar a la pantalla de análisis pasando los parámetros
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AnalysisPage(identification: id, session: session),
        ),
      );
    }
  }

  // Lógica para Navegación a la Medición de Salto Vertical
  void _startVerticalJumpAnalysis() {
    // Aquí podrías agregar lógica si el Salto Vertical también necesita una ID

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const VerticalJumpPage()),
    // );

    // Temporalmente, usa un AlertDialog si la página no está creada
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Análisis de Salto'),
            content: const Text(
              'Navegar a la pantalla de Medición de Salto Vertical (VerticalJumpPage)',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GAIT ANALYSIS - Menú Principal'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Sección de Análisis de Marcha (Requiere Parámetros)
            _buildGaitAnalysisSection(),

            const SizedBox(height: 40),

            // Sección de Medición de Salto Vertical
            _buildVerticalJumpSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildGaitAnalysisSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                '1. Análisis de Marcha (Gait Analysis)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Campo de Identificación
              TextFormField(
                controller: _controller.identificationController,
                decoration: const InputDecoration(
                  labelText: 'Identificación del Paciente',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese la identificación.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Campo de Sesión
              TextFormField(
                controller: _controller.sessionController,
                decoration: const InputDecoration(
                  labelText: 'Número de Sesión',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 1, 2, 3...',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ], // Solo números
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese el número de sesión.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Debe ser un número entero positivo.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Botón para iniciar Análisis de Marcha
              ElevatedButton.icon(
                onPressed: _startGaitAnalysis,
                icon: const Icon(Icons.directions_walk),
                label: const Text(
                  'Iniciar Análisis de Marcha',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalJumpSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              '2. Medición de Salto Vertical',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Botón para iniciar Medición de Salto Vertical
            ElevatedButton.icon(
              onPressed: _startVerticalJumpAnalysis,
              icon: const Icon(Icons.height),
              label: const Text(
                'Medir Distancia de Salto Vertical',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Color diferente para distinguir
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
