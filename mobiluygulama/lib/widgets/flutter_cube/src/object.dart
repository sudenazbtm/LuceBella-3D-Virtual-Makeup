import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';
import 'scene.dart';
import 'mesh.dart';

class Object {
  Object({
    Vector3? position,
    Vector3? rotation,
    Vector3? scale,
    this.name,
    Mesh? mesh,
    Scene? scene,
    this.parent,
    List<Object>? children,
    this.backfaceCulling = true,
    this.lighting = false,
    this.visiable = true,
    bool normalized = true,
    String? fileName,
    bool isAsset = true,
  }) {
    if (position != null) position.copyInto(this.position);
    if (rotation != null) rotation.copyInto(this.rotation);
    if (scale != null) scale.copyInto(this.scale);
    updateTransform();
    this.mesh = mesh ?? Mesh();
    this.children = children ?? <Object>[];
    for (Object child in this.children) {
      child.parent = this;
    }
    this.scene = scene;

    
    if (fileName != null) {
      loadObj(fileName, normalized, isAsset: isAsset).then((List<Mesh> meshes) {
        if (meshes.length == 1) {
          this.mesh = meshes[0];
        } else if (meshes.length > 1) {
          
          for (Mesh mesh in meshes) {
            add(Object(name: mesh.name, mesh: mesh, backfaceCulling: backfaceCulling, lighting: lighting));
          }
        }
        this.scene?.objectCreated(this);
      });
    } else {
      this.scene?.objectCreated(this);
    }
  }

  
  final Vector3 position = Vector3(0.0, 0.0, 0.0);

  
  final Vector3 rotation = Vector3(0.0, 0.0, 0.0);

  
  final Vector3 scale = Vector3(1.0, 1.0, 1.0);

  
  String? name;

  
  Scene? _scene;
  Scene? get scene => _scene;
  set scene(Scene? value) {
    _scene = value;
    for (Object child in children) {
      child.scene = value;
    }
  }

  
  Object? parent;

  
  late List<Object> children;

  
  late Mesh mesh;

  
  bool backfaceCulling;

  
  bool lighting;

  
  bool visiable;

  
  final Matrix4 transform = Matrix4.identity();

  void updateTransform() {
    final Matrix4 m = Matrix4.compose(position, Quaternion.euler(radians(rotation.y), radians(rotation.x), radians(rotation.z)), scale);
    transform.setFrom(m);
  }

  
  void add(Object object) {
    assert(object != this);
    object.scene = scene;
    object.parent = this;
    children.add(object);
  }

  
  void remove(Object object) {
    children.remove(object);
  }

  
  Object? find(Pattern name) {
    for (Object child in children) {
      if (child.name != null && (name as RegExp).hasMatch(child.name!)) return child;
      final Object? result = child.find(name);
      if (result != null) return result;
    }
    return null;
  }
}