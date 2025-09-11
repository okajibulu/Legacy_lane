import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class TributeForm extends StatefulWidget {
  final String memberId;

  const TributeForm({required this.memberId, super.key});

  @override
  State<TributeForm> createState() => _TributeFormState();
}

class _TributeFormState extends State<TributeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();

  XFile? _selectedImage;
  String? _voiceFilePath;
  String? _mediaType; // 'photo' or 'voice'
  bool isSubmitting = false;
  bool isPrivate = false;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  int _remainingSeconds = 45;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<String?> compressAndUploadImage(XFile image) async {
    final ext = image.name.split('.').last.toLowerCase();
    if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only JPG and PNG formats are allowed')),
      );
      return null;
    }

    final file = File(image.path);
    final sizeInBytes = await file.length();
    if (sizeInBytes > 2 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image exceeds 2MB limit')),
      );
      return null;
    }

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 60,
    );

    final fileName = 'tributes/${widget.memberId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);

    await ref.putData(compressedBytes!);
    return await ref.getDownloadURL();
  }

  Future<String?> uploadVoiceFile(String path) async {
    final file = File(path);
    final fileName = 'tributes/${widget.memberId}/${DateTime.now().millisecondsSinceEpoch}.aac';
    final ref = FirebaseStorage.instance.ref().child(fileName);

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> pickImage() async {
    if (_mediaType == 'voice') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only one media can be attached per tribute')),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _mediaType = 'photo';
      });
    }
  }

  void startCountdown() {
    _remainingSeconds = 45;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        stopRecording();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void stopCountdown() {
    _countdownTimer?.cancel();
  }

  Future<void> recordVoice() async {
    if (_mediaType == 'photo') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only one media can be attached per tribute')),
      );
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    if (!isRecording) {
      final path = '${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacADTS,
        duration: const Duration(seconds: 45),
      );
      startCountdown();
      setState(() {
        isRecording = true;
        _mediaType = 'voice';
      });
    } else {
      stopRecording();
    }
  }

  Future<void> stopRecording() async {
    final path = await _recorder.stopRecorder();
    stopCountdown();
    setState(() {
      isRecording = false;
      _voiceFilePath = path;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recording saved')),
    );
  }

  Future<void> submitTribute() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final tributeText = _textController.text.trim();
    String? photoUrl;
    String? voiceUrl;

    if (_mediaType == 'photo' && _selectedImage != null) {
      photoUrl = await compressAndUploadImage(_selectedImage!);
      if (photoUrl == null) {
        setState(() => isSubmitting = false);
        return;
      }
    }

    if (_mediaType == 'voice' && _voiceFilePath != null) {
      voiceUrl = await uploadVoiceFile(_voiceFilePath!);
    }

    final tributeData = {
      'text': tributeText,
      'createdBy': 'anonymous',
      'createdAt': Timestamp.now(),
      'isPrivate': isPrivate,
      'reactions': {
        'heart': 0,
        'pray': 0,
        'star': 0,
      },
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (voiceUrl != null) 'voiceUrl': voiceUrl,
    };

    await FirebaseFirestore.instance
        .collection('communities')
        .doc('legacy_lane_001')
        .collection('members')
        .doc(widget.memberId)
        .collection('tributes')
        .add(tributeData);

    setState(() {
      isSubmitting = false;
      _textController.clear();
      _selectedImage = null;
      _voiceFilePath = null;
      _mediaType = null;
      _remainingSeconds = 45;
      isPrivate = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tribute submitted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Leave a Tribute',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _textController,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Write your tribute here...',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  if (value.trim().length > 500) {
                    return 'Tribute must be 500 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Mark as private'),
                value: isPrivate,
                onChanged: (val) => setState(() => isPrivate = val ?? false),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.file(File(_selectedImage!.path), height: 150),
                ),
              if (_voiceFilePath != null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Voice recording attached'),
                ),
              if (isRecording)
                Text(
                  'Recording... $_remainingSeconds sec left',
                  style: const TextStyle(color: Colors.red),
                ),
              TextButton.icon(
                onPressed: isSubmitting ? null : pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Add Photo'),
              ),
              TextButton.icon(
                onPressed: isSubmitting ? null : recordVoice,
                icon: Icon(isRecording ? Icons.stop : Icons.mic),
                label: Text(isRecording ? 'Stop Recording' : 'Record Voice'),
              ),
              const Text(
                'Max file size: 2MB • Formats: JPG, PNG or AAC only