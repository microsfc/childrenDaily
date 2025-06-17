import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageService {

  Future<String?> uploadFile(File file);
  Future<void> deleteFile(String url);
  Future<String> uploadProfileImage(File file, String uid);
}

class FirebaseStorageService implements StorageService {
  final FirebaseStorage _storage;
  final uuid = Uuid();

  FirebaseStorageService(this._storage);

  // 上傳檔案
  @override
  Future<String?> uploadFile(File file) async {
    try {
      final ref = _storage
          .ref()
          .child('images/babyPhotos/${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}');

      if (!file.existsSync()) {
        print('File does not exist: ${file.path}');
      } else {
        print('File path: ${file.path}');
      }

      final uploadTask = ref.putFile(file);
      uploadTask.snapshotEvents.listen((event) {
        print(
            'Uploading: ${(event.bytesTransferred / event.totalBytes)} * 100%');
      });
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('Permission denied: ${e.message}');
      } else if (e.code == 'cancelled') {
        print('Upload cancelled: ${e.message}');
      } else {
        print('Upload failed: ${e.message}');
      }
      return '';
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }

  // 刪除檔案
  @override
  Future<void> deleteFile(String url) async {
    await _storage.refFromURL(url).delete();
  }

  // 上傳頭像
  @override
  Future<String> uploadProfileImage(File file, String uid) async {
    try {
      final ref = _storage
          .ref()
          .child('images/profiles/${uid}/profile.jpg');

      if (!file.existsSync()) {
        print('File does not exist: ${file.path}');
      } else {
        print('File path: ${file.path}');
      }

      final uploadTask = ref.putFile(file);
      uploadTask.snapshotEvents.listen((event) {
        print(
            'Uploading: ${(event.bytesTransferred / event.totalBytes)} * 100%');
      });
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('Permission denied: ${e.message}');
      } else if (e.code == 'cancelled') {
        print('Upload cancelled: ${e.message}');
      } else {
        print('Upload failed: ${e.message}');
      }
      return '';
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }
}
