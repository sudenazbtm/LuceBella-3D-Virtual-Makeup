import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/flutter_cube/flutter_cube.dart';

import '../widgets/aibot.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';
import '../utils/makeup_utils.dart';
import '../utils/matrix.dart';


class VirtualMakeupScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final dynamic scannedModel;

  const VirtualMakeupScreen({
    super.key,
    required this.onNavigate,
    this.scannedModel,
  });

  @override
  State<VirtualMakeupScreen> createState() => _VirtualMakeupScreenState();
}

class _VirtualMakeupScreenState extends State<VirtualMakeupScreen> {
  String selectedCategory = 'ruj';
  final List<MakeupProduct> appliedMakeup = [];
  bool cartNotification = false;
  bool isLoadingMakeup = false;
  String? currentObjPath;
  String? originalImagePath; 

  
  String? selectedLipHex;
  String? selectedBlushHex;
  String? selectedEyeshadowHex;
  String? selectedContourHex;
  String? selectedConcealerHex;
  String? selectedEyelinerHex;
  String? selectedFoundationHex;
  String? selectedBronzerHex;
  double selectedFoundationIntensity = 0.0;
  double selectedBronzerIntensity = 0.15;
  double selectedConcealerIntensity = 0.75;
  
  
  
  String aiAnalysisResult = "";
  Map<String, dynamic>? aiAnalysisData;
  bool isLoadingAnalysis = false;
  
  Map<String, String>? activeAutoCombo;
  Map<String, dynamic>? activeComboDetails;
  String? activeEventLabel;

  
  Scene? _modelScene;
  Object? _modelObject;
  double _cameraZoom = 10.0;

  @override
  void initState() {
    super.initState();
    
    if (widget.scannedModel != null) {
      String dosyaYolu = "";
      if (widget.scannedModel is Map) {
        Map data = widget.scannedModel as Map;
        try {
          dosyaYolu = data.values.firstWhere(
              (deger) => deger is String && deger.toString().endsWith('.obj')) as String;
        } catch (_) {
          try {
            dosyaYolu = data.values.firstWhere((d) => d is String) as String;
          } catch (_) {}
        }
      } else {
        dosyaYolu = widget.scannedModel.toString();
      }
      currentObjPath = dosyaYolu.replaceAll('\\', '/');
      
      currentObjPath = dosyaYolu.replaceAll('\\', '/');

      
      if (widget.scannedModel is Map && (widget.scannedModel as Map).containsKey('jpgPath') && (widget.scannedModel as Map)['jpgPath'] != null) {
        originalImagePath = (widget.scannedModel as Map)['jpgPath'];
      } else {
        
        String possibleImagePath = currentObjPath!.replaceAll('.obj', '.jpg');
        if (File(possibleImagePath).existsSync()) {
          originalImagePath = possibleImagePath;
        } else {
          originalImagePath = null; 
        }
      }
      print("Başlangıç obj: $currentObjPath, Orijinal resim (texture): $originalImagePath");
      
      
      if (originalImagePath != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _runAiColorAnalysis();
        });
      }
    }
  }

  final List<Map<String, dynamic>> categories = [
    {'id': 'ruj', 'name': 'Lipstick', 'label': 'Ruj', 'icon': Icons.emoji_emotions_outlined},
    {'id': 'fondöten', 'name': 'Foundation', 'label': 'Fondöten', 'icon': Icons.auto_awesome},
    {'id': 'kapatıcı', 'name': 'Concealer', 'label': 'Kapatıcı', 'icon': Icons.auto_awesome},
    {'id': 'allık', 'name': 'Blush', 'label': 'Allık', 'icon': Icons.palette_outlined},
    {'id': 'kontür', 'name': 'Contour', 'label': 'Kontür', 'icon': Icons.brush_outlined},
    {'id': 'far', 'name': 'Eyeshadow', 'label': 'Far', 'icon': Icons.remove_red_eye_outlined},
    {'id': 'eyeliner', 'name': 'Eyeliner', 'label': 'Eyeliner', 'icon': Icons.edit_outlined},
  ];

  final Map<String, List<ColorItem>> colorPalettes = {
    'fondöten': [
      ColorItem(color: 'transparent', name: 'Temizle', code: 'CLEAR', hexColor: 'CLEAR', brand: '', price: ''),
      ColorItem(color: '#F4EAE6', name: 'Porcelaine', code: 'FT-01', hexColor: '#F4EAE6', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#F2DFCD', name: 'Eggshell', code: 'FT-02', hexColor: '#F2DFCD', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#E0C8B0', name: 'Ivory', code: 'FT-03', hexColor: '#E0C8B0', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#D2B9A1', name: 'Fawn', code: 'FT-04', hexColor: '#D2B9A1', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#CCAF94', name: 'Oatmeal', code: 'FT-05', hexColor: '#CCAF94', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#C6A587', name: 'Bisque', code: 'FT-06', hexColor: '#C6A587', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#E5C09B', name: 'Vanilla', code: 'FT-07', hexColor: '#E5C09B', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#DEC19F', name: 'Cashmere', code: 'FT-08', hexColor: '#DEC19F', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#D4AD86', name: 'Biscuit', code: 'FT-09', hexColor: '#D4AD86', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#CCA37A', name: 'Cashew', code: 'FT-10', hexColor: '#CCA37A', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#C4976D', name: 'Pecan', code: 'FT-11', hexColor: '#C4976D', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#BC8A5E', name: 'Latte', code: 'FT-12', hexColor: '#BC8A5E', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#AF764B', name: 'Amber', code: 'FT-13', hexColor: '#AF764B', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#A56D43', name: 'Cedar', code: 'FT-14', hexColor: '#A56D43', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#9C6239', name: 'Walnut', code: 'FT-15', hexColor: '#9C6239', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#935831', name: 'Caramel', code: 'FT-16', hexColor: '#935831', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#8A4E29', name: 'Toffee', code: 'FT-17', hexColor: '#8A4E29', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#824622', name: 'Almond', code: 'FT-18', hexColor: '#824622', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#763C1B', name: 'Honey', code: 'FT-19', hexColor: '#763C1B', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#633318', name: 'Cocoa', code: 'FT-20', hexColor: '#633318', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#552912', name: 'Chestnut', code: 'FT-21', hexColor: '#552912', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#49210E', name: 'Mocha', code: 'FT-22', hexColor: '#49210E', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#411C0C', name: 'Coffee', code: 'FT-23', hexColor: '#411C0C', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#341508', name: 'Truffle', code: 'FT-24', hexColor: '#341508', brand: 'LuceBella', price: '₺850'),
      ColorItem(color: '#260B03', name: 'Espresso', code: 'FT-25', hexColor: '#260B03', brand: 'LuceBella', price: '₺850'),
    ],
    'kapatıcı': [
      ColorItem(color: 'transparent', name: 'Temizle', code: 'CLEAR', hexColor: 'CLEAR', brand: '', price: ''),
      ColorItem(color: '#F4EAE6', name: 'Porcelaine', code: 'KP-01', hexColor: '#F4EAE6', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#F2DFCD', name: 'Eggshell', code: 'KP-02', hexColor: '#F2DFCD', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#E0C8B0', name: 'Ivory', code: 'KP-03', hexColor: '#E0C8B0', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#D2B9A1', name: 'Fawn', code: 'KP-04', hexColor: '#D2B9A1', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#CCAF94', name: 'Oatmeal', code: 'KP-05', hexColor: '#CCAF94', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#C6A587', name: 'Bisque', code: 'KP-06', hexColor: '#C6A587', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#E5C09B', name: 'Vanilla', code: 'KP-07', hexColor: '#E5C09B', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#DEC19F', name: 'Cashmere', code: 'KP-08', hexColor: '#DEC19F', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#D4AD86', name: 'Biscuit', code: 'KP-09', hexColor: '#D4AD86', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#CCA37A', name: 'Cashew', code: 'KP-10', hexColor: '#CCA37A', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#C4976D', name: 'Pecan', code: 'KP-11', hexColor: '#C4976D', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#BC8A5E', name: 'Latte', code: 'KP-12', hexColor: '#BC8A5E', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#AF764B', name: 'Amber', code: 'KP-13', hexColor: '#AF764B', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#A56D43', name: 'Cedar', code: 'KP-14', hexColor: '#A56D43', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#9C6239', name: 'Walnut', code: 'KP-15', hexColor: '#9C6239', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#935831', name: 'Caramel', code: 'KP-16', hexColor: '#935831', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#8A4E29', name: 'Toffee', code: 'KP-17', hexColor: '#8A4E29', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#824622', name: 'Almond', code: 'KP-18', hexColor: '#824622', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#763C1B', name: 'Honey', code: 'KP-19', hexColor: '#763C1B', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#633318', name: 'Cocoa', code: 'KP-20', hexColor: '#633318', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#552912', name: 'Chestnut', code: 'KP-21', hexColor: '#552912', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#49210E', name: 'Mocha', code: 'KP-22', hexColor: '#49210E', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#411C0C', name: 'Coffee', code: 'KP-23', hexColor: '#411C0C', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#341508', name: 'Truffle', code: 'KP-24', hexColor: '#341508', brand: 'LuceBella', price: '₺550'),
      ColorItem(color: '#260B03', name: 'Espresso', code: 'KP-25', hexColor: '#260B03', brand: 'LuceBella', price: '₺550'),
    ],
    'allık': [
      ColorItem(color: '#FF6B81', name: 'U Know Butta', code: 'AL-01', hexColor: '#FF6B81', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FF9DBB', name: 'Butta Together', code: 'AL-02', hexColor: '#FF9DBB', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#B86B52', name: 'Feeling Butta', code: 'AL-03', hexColor: '#B86B52', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FF4D85', name: 'Getting Butta', code: 'AL-04', hexColor: '#FF4D85', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FF66CC', name: 'My Butta Half', code: 'AL-05', hexColor: '#FF66CC', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#D84B79', name: 'Butta With Me', code: 'AL-06', hexColor: '#D84B79', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#D28A7C', name: 'Metallic Rosy Biscuit', code: 'AL-07', hexColor: '#D28A7C', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#CD8586', name: 'Vintage Robe', code: 'AL-08', hexColor: '#CD8586', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#F3CCDD', name: 'Lavender Perfume', code: 'AL-09', hexColor: '#F3CCDD', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FFA08A', name: 'My Candyshop', code: 'AL-10', hexColor: '#FFA08A', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#D49D79', name: 'Mamas Camel Coat', code: 'AL-11', hexColor: '#D49D79', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FFA06A', name: 'Carrot Butter Cream', code: 'AL-12', hexColor: '#FFA06A', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FFD1C4', name: 'Ballet Shoes', code: 'AL-13', hexColor: '#FFD1C4', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FF9B85', name: 'Picnic Blanket', code: 'AL-14', hexColor: '#FF9B85', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#B36675', name: 'Romantic Rose', code: 'AL-15', hexColor: '#B36675', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#F39EBA', name: 'Pastel Pembe', code: 'AL-16', hexColor: '#F39EBA', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#9A2B5A', name: 'rich berry', code: 'AL-17', hexColor: '#9A2B5A', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#8B0000', name: 'chilli red', code: 'AL-18', hexColor: '#8B0000', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#BA6E53', name: 'soft mocha', code: 'AL-19', hexColor: '#BA6E53', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#FF7CBA', name: 'radiant pink', code: 'AL-20', hexColor: '#FF7CBA', brand: 'LuceBella', price: '₺500'),
      ColorItem(color: '#E83F3F', name: 'Daylily', code: 'AL-21', hexColor: '#E83F3F', brand: 'LuceBella', price: '₺500'),
    ],
    'kontür': [
      ColorItem(color: '#E8D4C4', name: 'Açık Boz', code: 'KN-01', hexColor: '#E8D4C4', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#DCC8B5', name: 'Yumuşak Boz', code: 'KN-02', hexColor: '#DCC8B5', brand: 'NYX', price: '₺159'),
      ColorItem(color: '#D4BCA8', name: 'Boz', code: 'KN-03', hexColor: '#D4BCA8', brand: 'Maybelline', price: '₺139'),
      ColorItem(color: '#C9AF98', name: 'Orta Boz', code: 'KN-04', hexColor: '#C9AF98', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#BCA085', name: 'Koyu Boz', code: 'KN-05', hexColor: '#BCA085', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#D4A574', name: 'Açık Bronz', code: 'KN-06', hexColor: '#D4A574', brand: 'NYX', price: '₺159'),
      ColorItem(color: '#C9A07A', name: 'Yumuşak Bronz', code: 'KN-07', hexColor: '#C9A07A', brand: 'Maybelline', price: '₺139'),
      ColorItem(color: '#C68E5A', name: 'Bronz', code: 'KN-08', hexColor: '#C68E5A', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#BC8860', name: 'Orta Bronz', code: 'KN-09', hexColor: '#BC8860', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#A67C52', name: 'Koyu Bronz', code: 'KN-10', hexColor: '#A67C52', brand: 'NYX', price: '₺159'),
      ColorItem(color: '#9D7049', name: 'Koyu Bronz', code: 'KN-11', hexColor: '#9D7049', brand: 'Maybelline', price: '₺139'),
      ColorItem(color: '#8B6F47', name: 'Espresso', code: 'KN-12', hexColor: '#8B6F47', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#B8956A', name: 'Soğuk Boz', code: 'KN-13', hexColor: '#B8956A', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#A88A68', name: 'Sıcak Kahve', code: 'KN-14', hexColor: '#A88A68', brand: 'NYX', price: '₺159'),
      ColorItem(color: '#9C8568', name: 'Soğuk Kahve', code: 'KN-15', hexColor: '#9C8568', brand: 'Maybelline', price: '₺139'),
      ColorItem(color: '#8A7355', name: 'Çikolata', code: 'KN-16', hexColor: '#8A7355', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#7D6647', name: 'Koyu Kahve', code: 'KN-17', hexColor: '#7D6647', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#6F5C42', name: 'Koyu Kahve', code: 'KN-18', hexColor: '#6F5C42', brand: 'NYX', price: '₺159'),
    ],
    'aydınlatıcı': [
      ColorItem(color: '#FFFEF7', name: 'İnci', code: 'AY-01', hexColor: '#FFFEF7', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#FFFCF0', name: 'Aytaşı', code: 'AY-02', hexColor: '#FFFCF0', brand: 'NYX', price: '₺179'),
      ColorItem(color: '#FFF9E6', name: 'Şampanya', code: 'AY-03', hexColor: '#FFF9E6', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#FFF5D6', name: 'Elmas', code: 'AY-04', hexColor: '#FFF5D6', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#FFF0C8', name: 'Vanilya Işıltısı', code: 'AY-05', hexColor: '#FFF0C8', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#FFEDC4', name: 'Krem', code: 'AY-06', hexColor: '#FFEDC4', brand: 'NYX', price: '₺179'),
      ColorItem(color: '#FFE5B4', name: 'Altın', code: 'AY-07', hexColor: '#FFE5B4', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#FFDDA0', name: 'Güneş Işığı', code: 'AY-08', hexColor: '#FFDDA0', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#F5DEB3', name: 'Gül Altın', code: 'AY-09', hexColor: '#F5DEB3', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#F0D890', name: 'Bal Işıltısı', code: 'AY-10', hexColor: '#F0D890', brand: 'NYX', price: '₺179'),
      ColorItem(color: '#E6CF8F', name: 'Bronz Işıltı', code: 'AY-11', hexColor: '#E6CF8F', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#FFE4E1', name: 'Pembe İnci', code: 'AY-12', hexColor: '#FFE4E1', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#FFD7D4', name: 'Gül Kuvars', code: 'AY-13', hexColor: '#FFD7D4', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#FFC9C6', name: 'Pembe Işıltı', code: 'AY-14', hexColor: '#FFC9C6', brand: 'NYX', price: '₺179'),
      ColorItem(color: '#F5E6FF', name: 'Lavanta', code: 'AY-15', hexColor: '#F5E6FF', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#E6E6FA', name: 'Leylak Işıltısı', code: 'AY-16', hexColor: '#E6E6FA', brand: 'MAC', price: '₺899'),
      ColorItem(color: '#D8D0FF', name: 'Mor İnci', code: 'AY-17', hexColor: '#D8D0FF', brand: 'NYX', price: '₺179'),
      ColorItem(color: '#F0E68C', name: 'Haki Işıltı', code: 'AY-18', hexColor: '#F0E68C', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#FAFAD2', name: 'Açık Altınbaşak', code: 'AY-19', hexColor: '#FAFAD2', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#EEE8AA', name: 'Soluk Altınbaşak', code: 'AY-20', hexColor: '#EEE8AA', brand: 'MAC', price: '₺899'),
    ],
    'bronzer': [
      ColorItem(color: '#E5C9A5', name: 'Açık Bronz', code: 'BR-01', hexColor: '#E5C9A5', brand: 'MAC', price: '₺799'),
      ColorItem(color: '#DDB896', name: 'Yumuşak Bronz', code: 'BR-02', hexColor: '#DDB896', brand: 'NYX', price: '₺149'),
      ColorItem(color: '#D2A679', name: 'Güneş Öpücüğü', code: 'BR-03', hexColor: '#D2A679', brand: 'Maybelline', price: '₺129'),
      ColorItem(color: '#D2B48C', name: 'Bronz', code: 'BR-04', hexColor: '#D2B48C', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#D2691E', name: 'Açık Bronz', code: 'BR-05', hexColor: '#D2691E', brand: 'MAC', price: '₺799'),
      ColorItem(color: '#CD853F', name: 'Peru', code: 'BR-06', hexColor: '#CD853F', brand: 'NYX', price: '₺149'),
      ColorItem(color: '#C9A07A', name: 'Altın Bronz', code: 'BR-07', hexColor: '#C9A07A', brand: 'Maybelline', price: '₺129'),
      ColorItem(color: '#BC8F8F', name: 'Gül Kahve', code: 'BR-08', hexColor: '#BC8F8F', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#B8956A', name: 'Kumlu Bronz', code: 'BR-09', hexColor: '#B8956A', brand: 'MAC', price: '₺799'),
      ColorItem(color: '#B38B6D', name: 'Sıcak Bronz', code: 'BR-10', hexColor: '#B38B6D', brand: 'NYX', price: '₺149'),
      ColorItem(color: '#A88A68', name: 'Koyu Bronz', code: 'BR-11', hexColor: '#A88A68', brand: 'Maybelline', price: '₺129'),
      ColorItem(color: '#A0522D', name: 'Sienna', code: 'BR-12', hexColor: '#A0522D', brand: 'Sephora', price: '₺899'),
      ColorItem(color: '#9C8568', name: 'Soğuk Bronz', code: 'BR-13', hexColor: '#9C8568', brand: 'MAC', price: '₺799'),
      ColorItem(color: '#8B7355', name: 'Çikolata Bronz', code: 'BR-14', hexColor: '#8B7355', brand: 'NYX', price: '₺149'),
      ColorItem(color: '#8B4513', name: 'Eyer Kahvesi', code: 'BR-15', hexColor: '#8B4513', brand: 'Maybelline', price: '₺129'),
      ColorItem(color: '#7D5E42', name: 'Koyu Bronz', code: 'BR-16', hexColor: '#7D5E42', brand: 'Sephora', price: '₺899'),
    ],
    'far': [
      ColorItem(color: '#FFFFFF', name: 'Beyaz', code: 'FR-01', hexColor: '#FFFFFF', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#FFF8E7', name: 'Krem', code: 'FR-02', hexColor: '#FFF8E7', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#FFE4E1', name: 'Puslu Gül', code: 'FR-03', hexColor: '#FFE4E1', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#FFE4B5', name: 'Mokasen', code: 'FR-04', hexColor: '#FFE4B5', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#FFDAB9', name: 'Şeftali', code: 'FR-05', hexColor: '#FFDAB9', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#F5DEB3', name: 'Buğday', code: 'FR-06', hexColor: '#F5DEB3', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#DEB887', name: 'Sağlam Ahşap', code: 'FR-07', hexColor: '#DEB887', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#D2B48C', name: 'Bronz', code: 'FR-08', hexColor: '#D2B48C', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#C19A6B', name: 'Deve', code: 'FR-09', hexColor: '#C19A6B', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#B8956A', name: 'Bronz', code: 'FR-10', hexColor: '#B8956A', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#A67C52', name: 'Esmer Şeker', code: 'FR-11', hexColor: '#A67C52', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#8B6F47', name: 'Koyu Haki', code: 'FR-12', hexColor: '#8B6F47', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#FFB6C1', name: 'Açık Pembe', code: 'FR-13', hexColor: '#FFB6C1', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#FFA6C9', name: 'Pembe', code: 'FR-14', hexColor: '#FFA6C9', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#FF85A1', name: 'Gül', code: 'FR-15', hexColor: '#FF85A1', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#FF69B4', name: 'Canlı Pembe', code: 'FR-16', hexColor: '#FF69B4', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#DB7093', name: 'Soluk Menekşe Kırmızısı', code: 'FR-17', hexColor: '#DB7093', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#C08081', name: 'Tozlu Gül', code: 'FR-18', hexColor: '#C08081', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#E6E6FA', name: 'Lavanta', code: 'FR-19', hexColor: '#E6E6FA', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#DDA0DD', name: 'Erik', code: 'FR-20', hexColor: '#DDA0DD', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#DA70D6', name: 'Orkide', code: 'FR-21', hexColor: '#DA70D6', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#BA55D3', name: 'Orta Orkide', code: 'FR-22', hexColor: '#BA55D3', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#9370DB', name: 'Orta Mor', code: 'FR-23', hexColor: '#9370DB', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#8B7AB8', name: 'Mor', code: 'FR-24', hexColor: '#8B7AB8', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#663399', name: 'Rebecca Moru', code: 'FR-25', hexColor: '#663399', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#4B0082', name: 'Çivit', code: 'FR-26', hexColor: '#4B0082', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#B0C4DE', name: 'Açık Çelik Mavisi', code: 'FR-27', hexColor: '#B0C4DE', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#87CEEB', name: 'Gök Mavisi', code: 'FR-28', hexColor: '#87CEEB', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#6495ED', name: 'Peygamber Çiçeği', code: 'FR-29', hexColor: '#6495ED', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#4682B4', name: 'Çelik Mavisi', code: 'FR-30', hexColor: '#4682B4', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#4169E1', name: 'Kraliyet Mavisi', code: 'FR-31', hexColor: '#4169E1', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#191970', name: 'Gece Mavisi', code: 'FR-32', hexColor: '#191970', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#8FBC8F', name: 'Koyu Deniz Yeşili', code: 'FR-33', hexColor: '#8FBC8F', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#90EE90', name: 'Açık Yeşil', code: 'FR-34', hexColor: '#90EE90', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#66CDAA', name: 'Orta Akuamarin', code: 'FR-35', hexColor: '#66CDAA', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#3CB371', name: 'Orta Deniz Yeşili', code: 'FR-36', hexColor: '#3CB371', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#2E8B57', name: 'Deniz Yeşili', code: 'FR-37', hexColor: '#2E8B57', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#808080', name: 'Gri', code: 'FR-38', hexColor: '#808080', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#696969', name: 'Sönük Gri', code: 'FR-39', hexColor: '#696969', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#556B2F', name: 'Koyu Zeytin', code: 'FR-40', hexColor: '#556B2F', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#F4A460', name: 'Kumlu Kahve', code: 'FR-41', hexColor: '#F4A460', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#CD853F', name: 'Peru', code: 'FR-42', hexColor: '#CD853F', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#D2691E', name: 'Çikolata', code: 'FR-43', hexColor: '#D2691E', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#8B4513', name: 'Eyer Kahvesi', code: 'FR-44', hexColor: '#8B4513', brand: 'Maybelline', price: '₺99'),
      ColorItem(color: '#654321', name: 'Koyu Kahve', code: 'FR-45', hexColor: '#654321', brand: 'NYX', price: '₺89'),
      ColorItem(color: '#FFD700', name: 'Altın', code: 'FR-46', hexColor: '#FFD700', brand: 'Sephora', price: '₺349'),
      ColorItem(color: '#DAA520', name: 'Altınbaşak', code: 'FR-47', hexColor: '#DAA520', brand: 'MAC', price: '₺499'),
      ColorItem(color: '#B8860B', name: 'Koyu Altınbaşak', code: 'FR-48', hexColor: '#B8860B', brand: 'Maybelline', price: '₺99'),
    ],
    'eyeliner': [
      ColorItem(color: '#000000', name: 'Siyah', code: 'EL-01', hexColor: '#000000', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#1C1C1C', name: 'Jet Siyah', code: 'EL-02', hexColor: '#1C1C1C', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#2F4F4F', name: 'Koyu Arduvaz', code: 'EL-03', hexColor: '#2F4F4F', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#36454F', name: 'Kömür', code: 'EL-04', hexColor: '#36454F', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#3D3D3D', name: 'Oniks', code: 'EL-05', hexColor: '#3D3D3D', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#454545', name: 'Koyu Gri', code: 'EL-06', hexColor: '#454545', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#696969', name: 'Sönük Gri', code: 'EL-07', hexColor: '#696969', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#808080', name: 'Gri', code: 'EL-08', hexColor: '#808080', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#654321', name: 'Koyu Kahve', code: 'EL-09', hexColor: '#654321', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#704214', name: 'Sepya', code: 'EL-10', hexColor: '#704214', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#8B4513', name: 'Eyer Kahvesi', code: 'EL-11', hexColor: '#8B4513', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#A0522D', name: 'Sienna', code: 'EL-12', hexColor: '#A0522D', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#191970', name: 'Gece Mavisi', code: 'EL-13', hexColor: '#191970', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#000080', name: 'Lacivert', code: 'EL-14', hexColor: '#000080', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#00008B', name: 'Koyu Mavi', code: 'EL-15', hexColor: '#00008B', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#0047AB', name: 'Kobalt', code: 'EL-16', hexColor: '#0047AB', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#4169E1', name: 'Kraliyet Mavisi', code: 'EL-17', hexColor: '#4169E1', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#4B0082', name: 'Çivit', code: 'EL-18', hexColor: '#4B0082', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#663399', name: 'Rebecca Moru', code: 'EL-19', hexColor: '#663399', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#800080', name: 'Mor', code: 'EL-20', hexColor: '#800080', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#9370DB', name: 'Orta Mor', code: 'EL-21', hexColor: '#9370DB', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#4B5320', name: 'Ordu Yeşili', code: 'EL-22', hexColor: '#4B5320', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#556B2F', name: 'Koyu Zeytin', code: 'EL-23', hexColor: '#556B2F', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#2E8B57', name: 'Deniz Yeşili', code: 'EL-24', hexColor: '#2E8B57', brand: 'Sephora', price: '₺699'),
      ColorItem(color: '#8B0000', name: 'Koyu Kırmızı', code: 'EL-25', hexColor: '#8B0000', brand: 'MAC', price: '₺599'),
      ColorItem(color: '#A52A2A', name: 'Kahverengi', code: 'EL-26', hexColor: '#A52A2A', brand: 'NYX', price: '₺139'),
      ColorItem(color: '#B8860B', name: 'Koyu Altınbaşak', code: 'EL-27', hexColor: '#B8860B', brand: 'Maybelline', price: '₺149'),
      ColorItem(color: '#DAA520', name: 'Altınbaşak', code: 'EL-28', hexColor: '#DAA520', brand: 'Sephora', price: '₺699'),
    ],
    'ruj': [
      
      ColorItem(color: '#8B1C2A', name: 'Lippy', code: 'RJ-01', hexColor: '#8B1C2A', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#D18A82', name: 'Peachy', code: 'RJ-02', hexColor: '#D18A82', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#C47A7A', name: 'Cheeky', code: 'RJ-03', hexColor: '#C47A7A', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#9C585C', name: 'Witty', code: 'RJ-04', hexColor: '#9C585C', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#D16279', name: 'Coy', code: 'RJ-05', hexColor: '#D16279', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#C41535', name: 'Wicked', code: 'RJ-06', hexColor: '#C41535', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#731722', name: 'Royal', code: 'RJ-07', hexColor: '#731722', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#7C1C45', name: 'Unrivaled', code: 'RJ-08', hexColor: '#7C1C45', brand: 'LuceBella', price: '₺450'),

      
      ColorItem(color: '#CD8F7C', name: 'Upstate', code: 'RJ-09', hexColor: '#CD8F7C', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A46152', name: 'Out \'Til 4', code: 'RJ-10', hexColor: '#A46152', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A45B52', name: 'Make It Work', code: 'RJ-11', hexColor: '#A45B52', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#853D3F', name: 'Maybe It\'s Intense', code: 'RJ-12', hexColor: '#853D3F', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A1594F', name: 'Maybe It\'s Soft', code: 'RJ-13', hexColor: '#A1594F', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#8C3839', name: 'Blind Date', code: 'RJ-14', hexColor: '#8C3839', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#CD8173', name: 'Crop Top', code: 'RJ-15', hexColor: '#CD8173', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A45044', name: 'Open Late', code: 'RJ-16', hexColor: '#A45044', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A8111A', name: 'Wild Card', code: 'RJ-17', hexColor: '#A8111A', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#AF5752', name: 'Take The 1', code: 'RJ-18', hexColor: '#AF5752', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A3564A', name: 'Hold The Door', code: 'RJ-19', hexColor: '#A3564A', brand: 'LuceBella', price: '₺450'),

      
      ColorItem(color: '#C77E6D', name: 'Kinda Sexy', code: 'RJ-20', hexColor: '#C77E6D', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A66052', name: 'Velvet Teddy', code: 'RJ-21', hexColor: '#A66052', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#9C594D', name: 'Warm Teddy', code: 'RJ-22', hexColor: '#9C594D', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#874B40', name: 'Taupe', code: 'RJ-23', hexColor: '#874B40', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#AF1024', name: 'Ruby Woo', code: 'RJ-24', hexColor: '#AF1024', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#B0635B', name: 'Mull It To The Max', code: 'RJ-25', hexColor: '#B0635B', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A85B56', name: 'Sweet Deal', code: 'RJ-26', hexColor: '#A85B56', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#8F514F', name: 'Whirl', code: 'RJ-27', hexColor: '#8F514F', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#985759', name: 'Twig Twist', code: 'RJ-28', hexColor: '#985759', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#5C161E', name: 'Diva', code: 'RJ-29', hexColor: '#5C161E', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A33423', name: 'Chili', code: 'RJ-30', hexColor: '#A33423', brand: 'LuceBella', price: '₺450'),

      
      ColorItem(color: '#CCA49D', name: 'Harmony', code: 'RJ-31', hexColor: '#CCA49D', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#C18F87', name: 'So You', code: 'RJ-32', hexColor: '#C18F87', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#BC8680', name: 'Pinky Nude', code: 'RJ-33', hexColor: '#BC8680', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#C47A6B', name: 'W. Peach', code: 'RJ-34', hexColor: '#C47A6B', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#B5666B', name: 'Pretty Peach', code: 'RJ-35', hexColor: '#B5666B', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#D44A3C', name: 'Tangerine', code: 'RJ-36', hexColor: '#D44A3C', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#B54271', name: 'Fan Of F.', code: 'RJ-37', hexColor: '#B54271', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#C17482', name: 'Baby Girl', code: 'RJ-38', hexColor: '#C17482', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#BC6872', name: 'Thulian Pink', code: 'RJ-39', hexColor: '#BC6872', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#B3666A', name: 'Rosy Lust', code: 'RJ-40', hexColor: '#B3666A', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#964B4D', name: 'Intense Love', code: 'RJ-41', hexColor: '#964B4D', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A46559', name: 'Gaia', code: 'RJ-42', hexColor: '#A46559', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#73283E', name: 'Go For B.', code: 'RJ-43', hexColor: '#73283E', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#B8756F', name: 'Peachy Glow', code: 'RJ-44', hexColor: '#B8756F', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#AF7274', name: 'E. Kiss', code: 'RJ-45', hexColor: '#AF7274', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A6596A', name: 'Mystic Rose', code: 'RJ-46', hexColor: '#A6596A', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#A1515A', name: 'Hidden Desire', code: 'RJ-47', hexColor: '#A1515A', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#C26361', name: 'Sweet Moment', code: 'RJ-48', hexColor: '#C26361', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#B35441', name: 'Daring Whisper', code: 'RJ-49', hexColor: '#B35441', brand: 'LuceBella', price: '₺450'),
      ColorItem(color: '#AE2E65', name: 'Candy Crush', code: 'RJ-50', hexColor: '#AE2E65', brand: 'LuceBella', price: '₺450'),
    ],
  };

  Color hexToColor(String hex) {
    try {
      var h = hex.replaceFirst('#', '');
      if (h.length == 6) h = 'FF$h';
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }



  void applyColor(ColorItem item) async {
    setState(() {
      isLoadingMakeup = true;
      appliedMakeup.removeWhere((m) => m.category == selectedCategory);
      
      if (item.code == 'CLEAR') {
        
        if (selectedCategory == 'ruj') selectedLipHex = null;
        else if (selectedCategory == 'allık') selectedBlushHex = null;
        else if (selectedCategory == 'far') selectedEyeshadowHex = null;
        else if (selectedCategory == 'kontür') selectedContourHex = null;
        else if (selectedCategory == 'kapatıcı') selectedConcealerHex = null;
        else if (selectedCategory == 'eyeliner') selectedEyelinerHex = null;
        else if (selectedCategory == 'fondöten') selectedFoundationHex = null;
      } else {
        appliedMakeup.add(MakeupProduct(
          category: selectedCategory,
          color: item.color,
          name: item.name,
          code: item.code,
          hexColor: item.hexColor,
        ));

        
        if (selectedCategory == 'ruj') selectedLipHex = item.hexColor;
        else if (selectedCategory == 'allık') selectedBlushHex = item.hexColor;
        else if (selectedCategory == 'far') selectedEyeshadowHex = item.hexColor;
        else if (selectedCategory == 'kontür') selectedContourHex = item.hexColor;
        else if (selectedCategory == 'kapatıcı') {
          selectedConcealerHex = item.hexColor;
          selectedConcealerIntensity = 0.75;
        }
        else if (selectedCategory == 'eyeliner') selectedEyelinerHex = item.hexColor;
        else if (selectedCategory == 'fondöten') {
          selectedFoundationHex = item.hexColor;
          selectedFoundationIntensity = 0.6; 
        }
      }
    });

    if (originalImagePath == null) {
      if (mounted) {
        setState(() => isLoadingMakeup = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Makyaj uygulanamıyor: 3D modelin orijinal .jpg kaplaması bulunamadı.')),
        );
      }
      return;
    }

    
    String? newTexPath = await applyMakeupToTexture(
      originalImagePath: originalImagePath!,
      lipColorHex: selectedLipHex,
      blushColorHex: selectedBlushHex,
      eyeshadowColorHex: selectedEyeshadowHex,
      contourColorHex: selectedContourHex,
      concealerColorHex: selectedConcealerHex,
      eyelinerColorHex: selectedEyelinerHex,
      foundationColorHex: selectedFoundationHex,
      foundationIntensity: selectedFoundationIntensity,
      concealerIntensity: selectedConcealerIntensity,
    );

    if (newTexPath != null && mounted) {
      try {
        
        
        String sessionPath = Directory(newTexPath).parent.path;
        
        String objName = currentObjPath!.split('/').last;
        String mtlName = objName.replaceAll('.obj', '.mtl');
        
        String oldDir = Directory(currentObjPath!).parent.path;
        
        File('$oldDir/$objName').copySync('$sessionPath/$objName');
        File('$oldDir/$mtlName').copySync('$sessionPath/$mtlName');

        setState(() {
          currentObjPath = '$sessionPath/$objName';
          isLoadingMakeup = false;
          
          if (_modelScene != null) {
            _modelScene!.world.children.clear();
            _modelScene!.world.add(Object(
              fileName: currentObjPath!,
              isAsset: false,
              lighting: true,
              scale: Vector3(4.5, 4.5, 4.5),
              position: Vector3(1.5, -1.5, 0.0),
              rotation: Vector3(0.0, 180.0, 0.0),
            ));
            
            _modelScene!.updateTexture();
          }
        });
      } catch (e) {
         debugPrint("Dosya kopyalama hatası: $e");
         if (mounted) {
           setState(() => isLoadingMakeup = false);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dosyalar kopyalanamadı: $e')));
         }
      }
    } else {
      if (mounted) setState(() => isLoadingMakeup = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Makyaj uygulanamadı.')));
    }
  }

  void _runAiColorAnalysis() async {

    if (originalImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen önce yüz taramasını tamamlayın.')));
      return;
    }

    setState(() {
      isLoadingAnalysis = true;
      aiAnalysisResult = "";
    });

    var analysisData = await fetchAiColorAnalysis(imagePath: originalImagePath!, apiKey: ""); 

    if (mounted) {
      setState(() {
        isLoadingAnalysis = false;
      });
      
      if (analysisData != null && analysisData.containsKey("hex")) {
         setState(() {
            aiAnalysisData = analysisData;
         });
         
         
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analiz başarısız oldu. Sunucu hatası.')));
      }
    }
  }

  void _showAiRecommendationBottomSheet(Map<String, dynamic> data) {
    String hex = data['hex'] ?? '#FFFFFF';
    String undertone = data['undertone'] ?? 'Bilinmiyor';
    String advice = data['advice'] ?? '';
    List foundations = data['closest_foundations'] ?? [];
    List concealers = data['closest_concealers'] ?? [];
    Map makeup = data['recommended_makeup'] ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2)),
            ),
            const Text('✨ AI Renk & Ürün Danışmanı', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              color: Color(int.parse(hex.replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24, width: 2)
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tespit Edilen Ton: $hex', style: const TextStyle(color: Colors.white, fontSize: 16)),
                                Text('Alt Ton: $undertone', style: TextStyle(color: Colors.blue.shade200, fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(advice, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                    
                    const SizedBox(height: 24),
                    const Text('💄 Senin İçin Seçilen Ürünler', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    
                    const Text('Mükemmel Fondöten Eşleşmeleri', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...foundations.map((f) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(backgroundColor: Color(int.parse(f['hex'].replaceFirst('#', '0xFF')))),
                      title: Text(f['brand'] + ' - ' + f['product'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text(f['shade'], style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                    )),
                    
                    const SizedBox(height: 16),
                    
                    const Text('Kapatıcı Eşleşmeleri', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...concealers.map((c) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(backgroundColor: Color(int.parse(c['hex'].replaceFirst('#', '0xFF')))),
                      title: Text(c['brand'] + ' - ' + c['product'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text(c['shade'], style: const TextStyle(color: Colors.white54)),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                    )),
                    
                    const SizedBox(height: 16),
                    const Text('Önerilen Renk Paleti', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (makeup['blush'] != null) Text('• Allık: ' + (makeup['blush'] as List).join(', '), style: const TextStyle(color: Colors.white70)),
                    if (makeup['lipstick'] != null) Text('• Ruj: ' + (makeup['lipstick'] as List).join(', '), style: const TextStyle(color: Colors.white70)),
                    if (makeup['eyeshadow'] != null) Text('• Far: ' + (makeup['eyeshadow'] as List).join(', '), style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 40),
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }

  

  double colorDistance(String hex1, String hex2) {
    hex1 = hex1.replaceFirst('#', '');
    hex2 = hex2.replaceFirst('#', '');
    if (hex1.length == 8) hex1 = hex1.substring(2);
    if (hex2.length == 8) hex2 = hex2.substring(2);
    if (hex1.length != 6 || hex2.length != 6) return 999999.0;

    int r1 = int.tryParse(hex1.substring(0, 2), radix: 16) ?? 0;
    int g1 = int.tryParse(hex1.substring(2, 4), radix: 16) ?? 0;
    int b1 = int.tryParse(hex1.substring(4, 6), radix: 16) ?? 0;

    int r2 = int.tryParse(hex2.substring(0, 2), radix: 16) ?? 0;
    int g2 = int.tryParse(hex2.substring(2, 4), radix: 16) ?? 0;
    int b2 = int.tryParse(hex2.substring(4, 6), radix: 16) ?? 0;

    return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2));
  }

  ColorItem? findProductByCode(String category, String code) {
    if (!colorPalettes.containsKey(category)) return null;
    try {
      return colorPalettes[category]!.firstWhere((item) => item.code == code && item.name != 'CLEAR');
    } catch (e) {
      return null;
    }
  }

  ColorItem? findFirstExistingProductByCodes(String category, List<String> codes) {
    if (!colorPalettes.containsKey(category)) return null;
    for (String code in codes) {
      final product = findProductByCode(category, code);
      if (product != null) return product;
    }
    return null;
  }

  ColorItem findClosestProductByHex(String category, String targetHex, {List<String>? allowedCodes}) {
    if (!colorPalettes.containsKey(category) || colorPalettes[category]!.isEmpty) {
      return ColorItem(color: targetHex, name: 'Bilinmeyen', code: 'N/A', hexColor: targetHex, brand: 'Auto', price: '');
    }

    List<ColorItem> candidates = colorPalettes[category]!.where((item) => item.name != 'CLEAR').toList();
    if (allowedCodes != null && allowedCodes.isNotEmpty) {
      final filtered = candidates.where((item) => allowedCodes.contains(item.code)).toList();
      if (filtered.isNotEmpty) {
        candidates = filtered;
      }
    }

    if (candidates.isEmpty) {
      candidates = colorPalettes[category]!.where((item) => item.name != 'CLEAR').toList();
      if (candidates.isEmpty) return colorPalettes[category]!.first;
    }

    ColorItem closest = candidates.first;
    double minDistance = double.infinity;

    for (var item in candidates) {
      double dist = colorDistance(targetHex, item.color);
      if (dist < minDistance) {
        minDistance = dist;
        closest = item;
      }
    }
    return closest;
  }

  List<ColorItem> getProductsByCodes(String category, List<String> codes) {
    List<ColorItem> result = [];
    for (String code in codes) {
      var prod = findProductByCode(category, code);
      if (prod != null) result.add(prod);
    }
    return result;
  }

  
  Map<String, dynamic> generatePersonalizedMakeupCombo(String eventId) {
    
    final skinColorStr = aiAnalysisData?['cilt_rengi']?.toString() ?? 'Buğday';
    final undertoneStr = aiAnalysisData?['undertone']?.toString() ?? 'Nötr Alt Tonlu';
    final eyeCategory  = aiAnalysisData?['eye_category']?.toString() ?? 'kahve';
    final hairCategory = aiAnalysisData?['hair_category']?.toString() ?? 'koyu_kahve';
    final shapeStr     = aiAnalysisData?['shape']?.toString() ?? 'Oval';
    final skinHex      = aiAnalysisData?['hex']?.toString() ?? '#D2B9A1';

    
    String skinGroup = 'BUĞDAY';
    final scLow = skinColorStr.toLowerCase();
    if (scLow.contains('açık') || scLow.contains('acik') || scLow.contains('porselen')) {
      skinGroup = 'AÇIK';
    } else if (scLow.contains('esmer') || scLow.contains('bronz') || scLow.contains('karamel')) {
      skinGroup = 'ESMER';
    } else if (scLow.contains('koyu') || scLow.contains('derin')) {
      skinGroup = 'KOYU';
    }

    
    String underGroup = 'NÖTR';
    final uLow = undertoneStr.toLowerCase();
    if (uLow.contains('sarı') || uLow.contains('sari') || uLow.contains('sıcak') || uLow.contains('sicak') || uLow.contains('warm')) {
      underGroup = 'SICAK';
    } else if (uLow.contains('pembe') || uLow.contains('soğuk') || uLow.contains('soguk') || uLow.contains('cool')) {
      underGroup = 'SOĞUK';
    }

    final events = [
      {'id': 'gunluk',  'label': 'Günlük'},
      {'id': 'is',      'label': 'İş / Ofis'},
      {'id': 'aksam',   'label': 'Akşam Yemeği'},
      {'id': 'dugun',   'label': 'Düğün / Nişan'},
      {'id': 'parti',   'label': 'Gece / Parti'},
      {'id': 'plaj',    'label': 'Plaj / Tatil'},
    ];
    final eventLabel = events.firstWhere((e) => e['id'] == eventId, orElse: () => {'label': 'Yapay Zeka'})['label'];

    
    String matrixKey = '${skinGroup}_${underGroup}';
    var eventMatrix = makeupMatrix[matrixKey]?[eventId] ?? makeupMatrix['BUĞDAY_NÖTR']!['gunluk']!;

    
    List<String> ftCodes = [];
    if (skinGroup == 'AÇIK') ftCodes = ['FT-01', 'FT-02', 'FT-03', 'FT-04'];
    else if (skinGroup == 'BUĞDAY') ftCodes = ['FT-04', 'FT-05', 'FT-06', 'FT-07', 'FT-08', 'FT-09'];
    else if (skinGroup == 'ESMER') ftCodes = ['FT-09', 'FT-10', 'FT-11', 'FT-12', 'FT-13', 'FT-14', 'FT-15', 'FT-16'];
    else if (skinGroup == 'KOYU') ftCodes = ['FT-17', 'FT-18', 'FT-19', 'FT-20', 'FT-21', 'FT-22', 'FT-23', 'FT-24', 'FT-25'];
    
    ColorItem foundationProduct = findClosestProductByHex('fondöten', skinHex, allowedCodes: ftCodes);

    
    int ftNum = int.tryParse(foundationProduct.code.replaceAll(RegExp(r'[^0-9]'), '')) ?? 5;
    int kpNum = ftNum;
    if (eventId == 'aksam' || eventId == 'dugun' || eventId == 'parti') {
      kpNum = (ftNum - 1).clamp(1, 25);
    } else if (eventId == 'plaj') {
      kpNum = ftNum; 
    } else {
      kpNum = ftNum;
    }
    
    List<String> kpCodes = [
      'KP-${kpNum.toString().padLeft(2, '0')}',
      'KP-${(kpNum-1).clamp(1,25).toString().padLeft(2, '0')}',
      'KP-${(kpNum+1).clamp(1,25).toString().padLeft(2, '0')}'
    ];
    ColorItem concealerProduct = findFirstExistingProductByCodes('kapatıcı', kpCodes) ?? findClosestProductByHex('kapatıcı', skinHex);

    
    List<String> blushCodes = eventMatrix['allık'] ?? [];
    List<String> lipCodes = eventMatrix['ruj'] ?? [];
    List<String> eyeCodes = eventMatrix['far'] ?? [];
    List<String> eyelinerCodes = eventMatrix['eyeliner'] ?? [];
    List<String> contourCodes = eventMatrix['kontür'] ?? [];
    List<String> highlighterCodes = eventMatrix['aydınlatıcı'] ?? [];
    List<String> bronzerCodes = eventMatrix['bronzer'] ?? [];

    
    if (eyeCategory == 'mavi' || eyeCategory == 'mavi_gri') {
      eyeCodes.insertAll(0, ['FR-05', 'FR-08', 'FR-09', 'FR-10', 'FR-41', 'FR-42'].where((c) => findProductByCode('far', c) != null));
    } else if (eyeCategory == 'yesil' || eyeCategory == 'yeşil' || eyeCategory == 'ela') {
      eyeCodes.insertAll(0, ['FR-20', 'FR-21', 'FR-22', 'FR-23', 'FR-24', 'FR-42', 'FR-43'].where((c) => findProductByCode('far', c) != null));
      eyelinerCodes.insertAll(0, ['EL-23', 'EL-24', 'EL-09'].where((c) => findProductByCode('eyeliner', c) != null));
    } else {
      eyeCodes.insertAll(0, ['FR-08', 'FR-10', 'FR-11', 'FR-42', 'FR-43', 'FR-46', 'FR-47'].where((c) => findProductByCode('far', c) != null));
      eyelinerCodes.insertAll(0, ['EL-01', 'EL-09', 'EL-13'].where((c) => findProductByCode('eyeliner', c) != null));
    }

    
    if (hairCategory == 'sari' || hairCategory == 'sarı') {
      if (eventId == 'gunluk' || eventId == 'is') {
        eyelinerCodes.remove('EL-01'); 
        eyelinerCodes.insertAll(0, ['EL-09', 'EL-10', 'EL-11', 'EL-14'].where((c) => findProductByCode('eyeliner', c) != null));
      }
    } else if (hairCategory == 'kizil' || hairCategory == 'kızıl') {
      eyelinerCodes.insertAll(0, ['EL-11', 'EL-23', 'EL-24'].where((c) => findProductByCode('eyeliner', c) != null));
    }

    
    ColorItem blushProduct = findFirstExistingProductByCodes('allık', blushCodes) ?? colorPalettes['allık']!.firstWhere((i) => i.name != 'CLEAR');
    ColorItem lipProduct = findFirstExistingProductByCodes('ruj', lipCodes) ?? colorPalettes['ruj']!.firstWhere((i) => i.name != 'CLEAR');
    ColorItem eyeshadowProduct = findFirstExistingProductByCodes('far', eyeCodes) ?? colorPalettes['far']!.firstWhere((i) => i.name != 'CLEAR');
    ColorItem eyelinerProduct = findFirstExistingProductByCodes('eyeliner', eyelinerCodes) ?? colorPalettes['eyeliner']!.firstWhere((i) => i.name != 'CLEAR');
    ColorItem contourProduct = findFirstExistingProductByCodes('kontür', contourCodes) ?? colorPalettes['kontür']!.firstWhere((i) => i.name != 'CLEAR');
    ColorItem highlighterProduct = findFirstExistingProductByCodes('aydınlatıcı', highlighterCodes) ?? colorPalettes['aydınlatıcı']!.firstWhere((i) => i.name != 'CLEAR');
    ColorItem bronzerProduct = findFirstExistingProductByCodes('bronzer', bronzerCodes) ?? colorPalettes['bronzer']!.firstWhere((i) => i.name != 'CLEAR');

    
    String contourAdvice = "";
    String blushAdvice = "";
    String highlightAdvice = "";
    switch (shapeStr) {
      case 'Oval':
        contourAdvice = "Kontürü elmacık kemiği altına çok hafif uygulayın.";
        blushAdvice = "Allığı elmacık kemiği üzerine uygulayın.";
        highlightAdvice = "Aydınlatıcıyı elmacık kemiği üstü ve burun üstüne az miktarda sürün.";
        break;
      case 'Yuvarlak':
        contourAdvice = "Kontürü şakaktan yanak boşluğuna ve çene hattına doğru uzatın.";
        blushAdvice = "Allığı yanak ortasına değil yukarı doğru çekerek sürün.";
        highlightAdvice = "Aydınlatıcıyı yüz merkezinde kontrollü tutun.";
        break;
      case 'Kare':
        contourAdvice = "Kontürü çene köşelerine ve alın yanlarına uygulayın.";
        blushAdvice = "Allığı yuvarlak hareketle yukarı doğru uygulayın.";
        highlightAdvice = "Sert köşeleri çok aydınlatmayın.";
        break;
      case 'Dikdörtgen':
        contourAdvice = "Kontürü alın üstü ve çene altına uygulayarak yüzü kısaltın.";
        blushAdvice = "Yüzü geniş göstermek için allığı yatay uygulayın.";
        highlightAdvice = "Aydınlatıcıyla orta bölüme denge verin.";
        break;
      case 'Kalp':
        contourAdvice = "Kontürü alın köşelerine sürün, çene ucunu sertleştirmeyin.";
        blushAdvice = "Allığı elmacıktan yanağa doğru yumuşak dağıtın.";
        highlightAdvice = "Çene ucu çok sivriyse aydınlatıcıyı kontrollü sürün.";
        break;
      case 'Elmas':
        contourAdvice = "Elmacık kemikleri çok geniş görünmesin diye kontürü kontrollü uygulayın.";
        blushAdvice = "Allığı çok yumuşak geçişli sürün.";
        highlightAdvice = "Alın ve çene merkezi hafif aydınlatılabilir.";
        break;
      default:
        contourAdvice = "Kontürü yüz hatlarınızı belirginleştirmek için kullanın.";
        blushAdvice = "Allığı yanaklarınıza taze bir görünüm için sürün.";
        highlightAdvice = "Yüksek noktalara aydınlatıcı sürün.";
    }

    return {
      "eventId": eventId,
      "eventLabel": eventLabel,
      "summary": "Bu kombin $skinGroup ten, $underGroup alt ton, $eyeCategory göz ve $shapeStr yüz yapısına göre özel olarak $eventLabel için hazırlandı.",
      "products": {
        "fondöten": foundationProduct,
        "kapatıcı": concealerProduct,
        "allık": blushProduct,
        "kontür": contourProduct,
        "aydınlatıcı": highlighterProduct,
        "bronzer": bronzerProduct,
        "far": eyeshadowProduct,
        "eyeliner": eyelinerProduct,
        "ruj": lipProduct,
      },
      "applicationAdvice": {
        "fondöten": "Ten renginizle en uyumlu seçilen fondöten kodu: ${foundationProduct.code}.",
        "kapatıcı": "Fondötene uygun (${concealerProduct.code}) kapatıcı önerildi.",
        "allık": blushAdvice,
        "kontür": contourAdvice,
        "aydınlatıcı": highlightAdvice,
        "bronzer": "Yüz hatlarını ısıtmak ve hafif boyut katmak için kullanın.",
        "far": "Göz renginize ($eyeCategory) uygun far paleti seçildi.",
        "eyeliner": "$eventLabel stili için seçilen eyeliner.",
        "ruj": "Alt tonunuzla ($underGroup) ve etkinlikle uyumlu ruj."
      }
    };
  }

  Map<String, String> generateAutoComboHexOnly(String eventId) {
    var combo = generatePersonalizedMakeupCombo(eventId);
    var products = combo['products'] as Map<String, dynamic>;
    
    Map<String, String> hexMap = {};
    products.forEach((key, value) {
      if (value is ColorItem) {
        hexMap[key] = value.hexColor;
      }
    });
    return hexMap;
  }

  Future<void> _applyAutoCombo(String eventId) async {
    final combo = generateAutoComboHexOnly(eventId);
    final detailsCombo = generatePersonalizedMakeupCombo(eventId);
    final events = [
      {'id': 'gunluk',  'label': 'Günlük'},
      {'id': 'is',      'label': 'İş / Ofis'},
      {'id': 'aksam',   'label': 'Akşam Yemeği'},
      {'id': 'dugun',   'label': 'Düğün / Nişan'},
      {'id': 'parti',   'label': 'Gece / Parti'},
      {'id': 'plaj',    'label': 'Plaj / Tatil'},
    ];
    final evLabel = events.firstWhere((e) => e['id'] == eventId, orElse: () => {'label': 'Yapay Zeka Kombini'})['label'];

    double fIntensity = 0.19;
    double bIntensity = 0.15;
    if (eventId == 'gunluk') { fIntensity = 0.16; bIntensity = 0.13; }
    else if (eventId == 'is') { fIntensity = 0.18; bIntensity = 0.10; }
    else if (eventId == 'aksam') { fIntensity = 0.22; bIntensity = 0.17; }
    else if (eventId == 'dugun') { fIntensity = 0.25; bIntensity = 0.16; }
    else if (eventId == 'parti') { fIntensity = 0.27; bIntensity = 0.19; }
    else if (eventId == 'plaj') { fIntensity = 0.12; bIntensity = 0.22; }

    setState(() {
      isLoadingMakeup = true;
      activeAutoCombo = combo;
      activeComboDetails = detailsCombo;
      activeEventLabel = evLabel as String?;
      appliedMakeup.clear();
      selectedLipHex        = combo['ruj'];
      selectedBlushHex      = combo['allık'];
      selectedEyeshadowHex  = combo['far'];
      selectedEyelinerHex   = combo['eyeliner'];
      selectedContourHex    = combo['kontür'];
      selectedFoundationHex = combo['fondöten'];
      selectedConcealerHex  = combo['kapatıcı'];
      selectedBronzerHex    = combo['bronzer'];
      selectedFoundationIntensity = fIntensity;
      selectedBronzerIntensity = bIntensity;
      selectedConcealerIntensity = 0.22;     });

    if (originalImagePath == null) {
      if (mounted) {
        setState(() => isLoadingMakeup = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Makyaj uygulanamıyor: Lütfen önce yüz taraması yapın.')),
        );
      }
      return;
    }

    String? newTexPath = await applyMakeupToTexture(
      originalImagePath:   originalImagePath!,
      lipColorHex:         selectedLipHex,
      blushColorHex:       selectedBlushHex,
      eyeshadowColorHex:   selectedEyeshadowHex,
      contourColorHex:     selectedContourHex,
      concealerColorHex:   selectedConcealerHex,
      eyelinerColorHex:    selectedEyelinerHex,
      foundationColorHex:  selectedFoundationHex,
      foundationIntensity: selectedFoundationIntensity,
      concealerIntensity:  selectedConcealerIntensity,
      bronzerColorHex:     selectedBronzerHex,
      bronzerIntensity:    selectedBronzerIntensity,
    );

    if (newTexPath != null && mounted) {
      try {
        String sessionPath = Directory(newTexPath).parent.path;
        String objName = currentObjPath!.split('/').last;
        String mtlName = objName.replaceAll('.obj', '.mtl');
        String oldDir  = Directory(currentObjPath!).parent.path;
        File('$oldDir/$objName').copySync('$sessionPath/$objName');
        File('$oldDir/$mtlName').copySync('$sessionPath/$mtlName');
        setState(() {
          currentObjPath = '$sessionPath/$objName';
          isLoadingMakeup = false;
          if (_modelScene != null) {
            _modelScene!.world.children.clear();
            _modelScene!.world.add(Object(
              fileName: currentObjPath!,
              isAsset: false,
              lighting: true,
              scale: Vector3(4.5, 4.5, 4.5),
              position: Vector3(1.5, -1.5, 0.0),
              rotation: Vector3(0.0, 180.0, 0.0),
            ));
            _modelScene!.updateTexture();
          }
        });
      } catch (e) {
        if (mounted) setState(() => isLoadingMakeup = false);
      }
    } else {
      if (mounted) setState(() => isLoadingMakeup = false);
    }
  }

  void _showEventPickerSheet() {
    final events = [
      {'id': 'gunluk',  'emoji': '☀️',  'label': 'Günlük',           'desc': 'Hafif, doğal, bakımlı'},
      {'id': 'is',      'emoji': '💼',  'label': 'İş / Ofis',        'desc': 'Net, profesyonel, şık'},
      {'id': 'aksam',   'emoji': '🌙',  'label': 'Akşam Yemeği',     'desc': 'Sofistike, belirgin'},
      {'id': 'dugun',   'emoji': '💍',  'label': 'Düğün / Nişan',   'desc': 'Zarif, özenli, romantik'},
      {'id': 'parti',   'emoji': '🎉',  'label': 'Gece / Parti',     'desc': 'Kalın hat, çarpıcı renk'},
      {'id': 'plaj',    'emoji': '🏖️',  'label': 'Plaj / Tatil',    'desc': 'Canlı, taze, enerjik'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('AI Makyaj Kombinasyonu', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Etkinliğini seç, kombini otomatik hazırlansın', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (aiAnalysisData != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        color: Color(int.parse((aiAnalysisData!['hex'] ?? '#F2DFCD').replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Cilt tonu analiz edildi: ${aiAnalysisData!['undertone'] ?? ''}', style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
              physics: const NeverScrollableScrollPhysics(),
              children: events.map((e) => GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _applyAutoCombo(e['id']!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${e['emoji']} ${e['label']} kombini uygulanıyor...'),
                      backgroundColor: Colors.grey.shade900,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Text(e['emoji']!, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e['label']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(e['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  MakeupProduct? getCurrentColor() {
    try {
      return appliedMakeup.firstWhere((m) => m.category == selectedCategory);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final currentCat = categories.firstWhere((c) => c['id'] == selectedCategory);
    final currentList = colorPalettes[selectedCategory] ?? [];
    final currentColor = getCurrentColor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              
              Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 16),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Logo(variant: 'light', size: 'md', onClick: () => widget.onNavigate('home')),
                      if (!isMobile)
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.share, color: Colors.white, size: 20), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.download, color: Colors.white, size: 20), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.refresh, color: Colors.white, size: 20), onPressed: () => setState(() => appliedMakeup.clear())),
                            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20), onPressed: () => widget.onNavigate('cart')),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () => widget.onNavigate('products'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Mağaza'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: isLoadingAnalysis ? null : _runAiColorAnalysis,
                              icon: isLoadingAnalysis ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)) : const Icon(Icons.psychology, size: 18),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade900,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              label: const Text('AI Renk Analizi'),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            IconButton(icon: const Icon(Icons.refresh, color: Colors.white, size: 20), onPressed: () => setState(() => appliedMakeup.clear())),
                            IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20), onPressed: () => widget.onNavigate('cart')),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              
              Expanded(
                child: Flex(
                  direction: isMobile ? Axis.vertical : Axis.horizontal,
                  children: [
                    
                    Expanded(
                      flex: isMobile ? 3 : 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF111827), Colors.black],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
                            margin: EdgeInsets.all(isMobile ? 12 : 32),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              gradient: LinearGradient(
                                colors: [Colors.grey.shade900, Colors.black],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Stack(
                                children: [
                                 if (currentObjPath != null)
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Cube(
                                          interactive: true,
                                          onSceneCreated: (Scene scene) {
                                            _modelScene = scene;
                                            scene.camera.zoom = 5.0;
                                            scene.world.add(Object(
                                              fileName: currentObjPath!,
                                              isAsset: false,
                                              lighting: true,
                                              scale: Vector3(4.5, 4.5, 4.5),
                                              position: Vector3(1.5, -1.5, 0.0),
                                              rotation: Vector3(0.0, 180.0, 0.0),
                                            ));
                                          },
                                        ),
                                        if (isLoadingMakeup)
                                          Container(
                                            color: Colors.black.withOpacity(0.5),
                                            child: const Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircularProgressIndicator(color: Colors.white),
                                                  SizedBox(height: 16),
                                                  Text("Makyaj Uygulanıyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  
                                  Positioned(
                                    top: 20, right: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: const Text('3D Görünüm', style: TextStyle(color: Colors.white54, fontSize: 10)),
                                    ),
                                  ),
                                  
                                  
                                  if (aiAnalysisData != null)
                                    Positioned(
                                      top: 20, left: 20,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF151816).withOpacity(0.9), 
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5),
                                          boxShadow: [
                                            BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)
                                          ]
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  const TextSpan(text: 'Senin Cildin: ', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                                  TextSpan(text: '${aiAnalysisData?['hex'] ?? ""}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                                ]
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text('Alt Tonun: ${aiAnalysisData?['undertone'] ?? ""}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    
                    Flexible(
                      flex: isMobile ? 5 : 0,
                      fit: isMobile ? FlexFit.tight : FlexFit.loose,
                      child: Container(
                        width: isMobile ? double.infinity : 400,
                        decoration: BoxDecoration(
                        color: const Color(0xFF0F1115),
                        border: Border(
                          left: BorderSide(color: isMobile ? Colors.transparent : const Color(0xFF1F2937)),
                          top: BorderSide(color: isMobile ? const Color(0xFF1F2937) : Colors.transparent),
                        ),
                      ),
                      child: Column(
                        children: [
                          
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('KATEGORİ', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                    Icon(currentCat['icon'], color: Colors.grey, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  itemCount: categories.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.4,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemBuilder: (context, index) {
                                    final cat = categories[index];
                                    final isSelected = selectedCategory == cat['id'];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = cat['id'];
                                          appliedMakeup.clear();
                                          selectedLipHex = null;
                                          selectedBlushHex = null;
                                          selectedEyeshadowHex = null;
                                          selectedContourHex = null;
                                          selectedConcealerHex = null;
                                          selectedEyelinerHex = null;
                                          selectedFoundationHex = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade800),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(cat['icon'], color: isSelected ? Colors.black : Colors.grey, size: 20),
                                            const SizedBox(height: 4),
                                            Text(
                                              cat['label'],
                                              style: TextStyle(
                                                color: isSelected ? Colors.black : Colors.grey,
                                                fontSize: 11,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          
                          Expanded(
                            child: Stack(
                              children: [
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(currentCat['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Serif')),
                                          Text(' ton', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: currentList.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: isMobile ? 5 : 6,
                                          crossAxisSpacing: 8,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemBuilder: (context, index) {
                                          final item = currentList[index];
                                          final isSelected = currentColor?.code == item.code;
                                          
                                          
                                          bool isAiRecommended = false;
                                          if (aiAnalysisData != null) {
                                            String skinHex = aiAnalysisData!['hex'] ?? "#FFFFFF";
                                            String undertone = aiAnalysisData!['undertone'] ?? "";
                                            
                                            
                                            List<int> hexToRgbList(String h) {
                                              h = h.replaceAll('#', '');
                                              if (h.length != 6) return [255, 255, 255];
                                              return [int.parse(h.substring(0, 2), radix: 16), int.parse(h.substring(2, 4), radix: 16), int.parse(h.substring(4, 6), radix: 16)];
                                            }
                                            
                                            List<int> skinRgb = hexToRgbList(skinHex);
                                            List<int> itemRgb = hexToRgbList(item.color);
                                            
                                            
                                            double dist = (skinRgb[0] - itemRgb[0]) * (skinRgb[0] - itemRgb[0]) +
                                                          (skinRgb[1] - itemRgb[1]) * (skinRgb[1] - itemRgb[1]) +
                                                          (skinRgb[2] - itemRgb[2]) * (skinRgb[2] - itemRgb[2]) + 0.0;
                                            
                                            if (selectedCategory == 'fondöten' || selectedCategory == 'kapatıcı') {
                                              
                                              if (dist < 4000) {
                                                isAiRecommended = true;
                                              }
                                            } else {
                                              
                                              int indexNum = int.tryParse(item.code.split('-').last) ?? 0;
                                              
                                              if (undertone.contains("Soğuk")) {
                                                
                                                if (item.name.contains('Mürdüm') || item.name.contains('Kırmızı') || item.name.contains('Vişne') || item.name.contains('Bordo') || indexNum > 18) {
                                                  isAiRecommended = true;
                                                }
                                              } else if (undertone.contains("Nötr")) {
                                                if (item.name.contains('Kırmızı') || item.name.contains('Nude') || item.name.contains('Karamel') || (indexNum > 8 && indexNum < 15)) {
                                                  isAiRecommended = true;
                                                }
                                              } else {
                                                
                                                if (item.name.contains('Kiremit') || item.name.contains('Bakır') || item.name.contains('Toprak') || item.name.contains('Kahve') || item.name.contains('Bronz') || indexNum > 15) {
                                                  isAiRecommended = true;
                                                }
                                              }
                                            }
                                          }

                                          return GestureDetector(
                                            onTap: () => applyColor(item),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: hexToColor(item.color),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isSelected 
                                                      ? Colors.white 
                                                      : isAiRecommended 
                                                          ? Colors.greenAccent 
                                                          : Colors.white12,
                                                  width: isSelected || isAiRecommended ? 2.5 : 1
                                                ),
                                                boxShadow: isAiRecommended
                                                    ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.6), blurRadius: 15, spreadRadius: 1)]
                                                    : isSelected 
                                                        ? [const BoxShadow(color: Colors.white24, blurRadius: 8)] 
                                                        : null,
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  if (isSelected)
                                                    Container(
                                                      width: 20, 
                                                      height: 20, 
                                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                                      child: Center(
                                                        child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
                                                      ),
                                                    ),
                                                  if (isAiRecommended)
                                                    Positioned(
                                                      bottom: -2, right: -2,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(2),
                                                        decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                                        child: const Icon(Icons.star, color: Colors.white, size: 8),
                                                      )
                                                    )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      
                                      if (currentColor != null) ...[
                                        const SizedBox(height: 32),
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text('SEÇİLEN TON', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.2)),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 48, height: 48,
                                                    decoration: BoxDecoration(
                                                      color: hexToColor(currentColor.color),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.white24),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(currentColor.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                                                        Text(currentColor.code, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() => cartNotification = true);
                                                    Future.delayed(const Duration(seconds: 2), () {
                                                      if(mounted) setState(() => cartNotification = false);
                                                    });
                                                  },
                                                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                                                  label: const Text('Sepete Ekle'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    foregroundColor: Colors.black,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      
                                      
                                      if (activeAutoCombo != null) ...[
                                        const SizedBox(height: 24),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.auto_awesome, color: Colors.greenAccent, size: 18),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    '${activeEventLabel ?? "AI"} Kombini Etkin',
                                                    style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Wrap(
                                                spacing: 12,
                                                runSpacing: 12,
                                                children: activeAutoCombo!.entries.map((e) {
                                                  if (e.value.isEmpty || e.value == '#FFFFFF') return const SizedBox.shrink();
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 32, height: 32,
                                                        decoration: BoxDecoration(
                                                          color: Color(int.parse(e.value.replaceFirst('#', '0xFF'))),
                                                          shape: BoxShape.circle,
                                                          border: Border.all(color: Colors.white24, width: 2),
                                                          boxShadow: [
                                                            BoxShadow(color: Color(int.parse(e.value.replaceFirst('#', '0xFF'))).withOpacity(0.3), blurRadius: 4, spreadRadius: 1)
                                                          ]
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        e.key.toUpperCase(),
                                                        style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                              const SizedBox(height: 12),
                                              SizedBox(
                                                width: double.infinity,
                                                child: TextButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      activeAutoCombo = null;
                                                      appliedMakeup.clear();
                                                    });
                                                  },
                                                  icon: const Icon(Icons.clear, size: 14, color: Colors.white54),
                                                  label: const Text('Kombini Temizle', style: TextStyle(color: Colors.white54, fontSize: 11)),
                                                  style: TextButton.styleFrom(
                                                    backgroundColor: Colors.white10,
                                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                                                              ],
                                      const SizedBox(height: 24),
                                      Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          alignment: WrapAlignment.center,
                                          children: [
                                                                                        InkWell(
                                              onTap: _showEventPickerSheet,
                                              borderRadius: BorderRadius.circular(30),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.greenAccent.shade700,
                                                  borderRadius: BorderRadius.circular(30),
                                                  border: Border.all(color: Colors.greenAccent),
                                                  boxShadow: [BoxShadow(color: Colors.greenAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 4))],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Icon(Icons.auto_fix_high, color: Colors.black, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('Etkinlik Sec', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                                                                        InkWell(
                                              onTap: () {
                                                if (aiAnalysisData != null) {
                                                  _showAiRecommendationBottomSheet(aiAnalysisData!);
                                                } else {
                                                  _runAiColorAnalysis();
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(30),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(30),
                                                  border: Border.all(color: Colors.white24),
                                                  boxShadow: const [BoxShadow(color: Colors.white12, blurRadius: 10, offset: Offset(0, 4))],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                                                    SizedBox(width: 8),
                                                    Text('AI Asistan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 100), 
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (cartNotification)
            Positioned(
              top: 100,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Sepete eklendi', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentScreen: 'virtualmakeup', onNavigate: widget.onNavigate),
      floatingActionButton: const AIBotAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ColorItem {
  final String color;
  final String name;
  final String code;
  final String hexColor;
  final String brand;
  final String price;

  ColorItem({
    required this.color,
    required this.name,
    required this.code,
    required this.hexColor,
    required this.brand,
    required this.price,
  });
}

class MakeupProduct {
  final String category;
  final String color;
  final String name;
  final String code;
  final String hexColor;

  MakeupProduct({
    required this.category,
    required this.color,
    required this.name,
    required this.code,
    required this.hexColor,
  });
}