import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';

class FaceScanScreen extends StatefulWidget {
  final void Function(String) onNavigate;
  final void Function(dynamic) onScanComplete;

  const FaceScanScreen({
    super.key,
    required this.onNavigate,
    required this.onScanComplete,
  });

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  String _scanStep = 'intro';
  double _progress = 0;
  String? _capturedImagePath;

  
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  
  bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  
  
  
  Future<void> _startScan() async {
    if (_isDesktop) {
      
      await _pickImageFromGallery();
    } else {
      
      if (!mounted) return;
      setState(() {
        _scanStep = 'scanning';
        _progress = 0;
      });
      await _initCamera();
    }
  }

  
  
  
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return; 

    if (mounted) {
      setState(() {
        _capturedImagePath = picked.path;
        _scanStep = 'processing';
        _progress = 0;
      });
      _processImageTo3D();
    }
  }

  
  
  
  Future<void> _pickObjDirectory() async {
    try {
      final String? selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory != null) {
        final dir = Directory(selectedDirectory);
        final files = dir.listSync();
        
        String? objPath;
        String? jpgPath;
        
        for (var file in files) {
          if (file.path.endsWith('.obj')) objPath = file.path;
          if (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg')) jpgPath = file.path;
        }

        if (objPath != null) {
          if (mounted) {
             widget.onScanComplete({
               'scanned': true,
               'imagePath': objPath,
               'jpgPath': jpgPath,
               'timestamp': DateTime.now().millisecondsSinceEpoch,
             });
             widget.onNavigate('virtualmakeup');
          }
        } else {
           _showError("Seçilen klasörde .obj dosyası bulunamadı.");
        }
      }
    } catch (e) {
      debugPrint("Klasör seçilirken hata: $e");
      _showError("Klasör okunamadı: $e");
    }
  }

  
  
  
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('Kamera bulunamadı.');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Kamera başlatılamadı: $e');
      _showError('Kamera başlatılamadı: $e');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
    setState(() => _scanStep = 'intro');
  }

  
  
  
  Future<void> _processImageTo3D() async {
    if (_capturedImagePath == null) return;

    try {
      
     String serverUrl = 'http://167.172.111.39:8000/api/generate-3d'; 
     

      var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(await http.MultipartFile.fromPath('file', _capturedImagePath!));

      debugPrint("Sunucuya fotoğraf gönderiliyor: $serverUrl");

      
      

var response = await request.send().timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        debugPrint("ZIP dosyası başarıyla alındı. Telefona kaydediliyor...");
        if (!mounted) return;
        setState(() => _progress = 50);

        
        var bytes = await response.stream.toBytes();

        if (!mounted) return;
        setState(() => _progress = 80);

        
        Directory tempDir = await getTemporaryDirectory();
        String zipPath = '${tempDir.path}/3d_model.zip';
        String extractPath = '${tempDir.path}/3d_model_files';
        
        
        File zipFile = File(zipPath);
        await zipFile.writeAsBytes(bytes);

        
        await extractFileToDisk(zipPath, tempDir.path);

        debugPrint("Model çıkartıldı! Klasör yolu: $extractPath veya ilgili klasör.");

        
        final extractDir = Directory(tempDir.path);
        final files = extractDir.listSync(recursive: true);
        String? objPath;
        for (var file in files) {
          if (file.path.endsWith('.obj')) {
            objPath = file.path;
            break;
          }
        }

        if (!mounted) return;
        setState(() {
          _progress = 100;
          _scanStep = 'complete';
        });

        if (objPath != null) {
          debugPrint("Bulunan 3D OBJ dosyası: $objPath");
          
          widget.onScanComplete({
            'scanned': true,
            'imagePath': objPath,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        } else {
          _showError("ZIP içinden .obj dosyası çıkmadı");
        }

      } else {
        _showError("Sunucu Hatası: ${response.statusCode}");
      }
    } catch (e) {
      _showError("Bağlantı hatası: $e");
    }
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    
    if (_scanStep == 'scanning' && !_isDesktop) {
      return _buildCameraFullScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.black,
                border: Border(bottom: BorderSide(color: Colors.white24, width: 0.6)),
              ),
              child: Row(
                children: const [
                  Logo(variant: 'light', size: 'md'),
                  Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentScreen: 'facescan',
        onNavigate: widget.onNavigate,
      ),
    );
  }

  
  
  
  Widget _buildContent() {
    switch (_scanStep) {
      case 'intro':
        return _buildIntro();
      case 'processing':
        return _buildProcessing();
      case 'complete':
        return _buildComplete();
      default:
        return _buildIntro();
    }
  }

  
  
  
  Widget _buildIntro() {
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 64),
        ),
        const SizedBox(height: 32),
        const Text(
          '3D Yüz Modellemesi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Yüzünüzü tarayarak kişiselleştirilmiş 3D modelinizi oluşturacağız. '
          'Bu sayede makyaj ürünlerini gerçekçi bir şekilde deneyebileceksiniz.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _isDesktop
                ? Colors.blue.withOpacity(0.15)
                : Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isDesktop ? Colors.blue.shade700 : Colors.green.shade700,
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isDesktop ? Icons.computer : Icons.smartphone,
                color: _isDesktop ? Colors.blue.shade300 : Colors.green.shade300,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isDesktop
                    ? 'Masaüstü modu: Galeriden fotoğraf seçilecek'
                    : 'Mobil mod: Ön kamera kullanılacak',
                style: TextStyle(
                  color: _isDesktop ? Colors.blue.shade200 : Colors.green.shade200,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tarama Kuralları',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              _Rule(text: 'Aydınlık bir ortamda, yüzünüz tamamen görünür olsun.'),
              _Rule(text: 'Gözlük, şapka gibi yüzünüzü kapatan aksesuarları çıkarın.'),
              _Rule(text: 'Kameraya (veya fotoğrafa) tam karşıdan ve dik bir şekilde bakın.'),
              _Rule(text: 'Yüzünüzün net ve odaklanmış bir şekilde çıkmasına dikkat edin.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _startScan,
          icon: Icon(_isDesktop ? Icons.photo_library : Icons.camera_alt),
          label: Text(_isDesktop ? 'Fotoğraf Seç' : 'Taramayı Başlat'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          onPressed: _pickObjDirectory,
          icon: const Icon(Icons.folder_open),
          label: const Text('Klasörden 3D Model Yükle (.obj)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildCameraFullScreen() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          
          CameraPreview(_cameraController!),

          
          IgnorePointer(
            child: CustomPaint(
              painter: FaceOverlayPainter(),
              child: Container(),
            ),
          ),

          
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                const Padding(
                  padding: EdgeInsets.only(top: 24.0),
                  child: Text(
                    'Yüzünüzü oval çerçeveye hizalayın\nve iyi aydınlatılmış bir ortamda olun.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                    ),
                  ),
                ),

                
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      
                      FloatingActionButton(
                        heroTag: 'cancel',
                        backgroundColor: Colors.black54,
                        onPressed: () {
                          _cameraController?.dispose();
                          _cameraController = null;
                          setState(() {
                            _isCameraInitialized = false;
                            _scanStep = 'intro';
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      
                      FloatingActionButton(
                        heroTag: 'capture',
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          if (!(_cameraController?.value.isInitialized ?? false)) return;
                          final XFile photo = await _cameraController!.takePicture();
                          debugPrint('Fotoğraf çekildi: ${photo.path}');
                          if (mounted) {
                            setState(() {
                              _capturedImagePath = photo.path;
                              _scanStep = 'processing';
                              _progress = 0;
                            });
                            _processImageTo3D();
                          }
                        },
                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildProcessing() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 24),
        Text(
          'Analiz ediliyor... %${_progress.toInt()}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _progress / 100,
          backgroundColor: Colors.white24,
          color: Colors.white,
        ),
        if (_capturedImagePath != null) ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_capturedImagePath!),
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ],
    );
  }

  
  
  
  Widget _buildComplete() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
        const SizedBox(height: 16),
        const Text(
          'Tarama Tamamlandı!',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Yüz modeliniz başarıyla oluşturuldu.',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => widget.onNavigate('virtualmakeup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Makyaj Denemeye Geç →'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _scanStep = 'intro';
            _capturedImagePath = null;
            _progress = 0;
          }),
          child: const Text('Tekrar Tara', style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }
}




class _Rule extends StatelessWidget {
  final String text;
  const _Rule({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}




class FaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2.2),
      width: size.width * 0.72,
      height: size.height * 0.52,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final Path path = Path()..addOval(ovalRect);
    
    
    const double dashWidth = 12.0;
    const double dashSpace = 8.0;
    
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final double len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(
            pathMetric.extractPath(distance, distance + len),
            borderPaint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}