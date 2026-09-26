import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/location_helper.dart';
import '../../../data/models/report_model.dart';
import '../../../data/repositories/demo_data.dart';
import '../../../data/repositories/report_repository.dart';
import '../../../providers/report_provider.dart';

class ReportFlowScreen extends ConsumerStatefulWidget {
  const ReportFlowScreen({super.key});

  @override
  ConsumerState<ReportFlowScreen> createState() => _ReportFlowScreenState();
}

class _ReportFlowScreenState extends ConsumerState<ReportFlowScreen> {
  final _pageController = PageController();
  final _picker = ImagePicker();
  final _descriptionController = TextEditingController();
  int _step = 0;
  File? _image;
  Position? _position;
  String _address = '';
  ReportCategory? _category;
  bool _submitting = false;
  bool _loadingLocation = false;
  String? _locationError;

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _nextStep() async {
    if (_step < 3) {
      setState(() => _step += 1);
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _openCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) {
      return;
    }
    setState(() {
      _image = File(file.path);
      _locationError = null;
    });
    await _capturePhotoLocation();
    await _nextStep();
  }

  Future<void> _capturePhotoLocation() async {
    setState(() {
      _loadingLocation = true;
      _locationError = null;
    });

    try {
      final position = await LocationHelper.getPreciseCurrentPosition();
      final address = await LocationHelper.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _position = position;
        _address = address;
      });
    } on LocationServiceDisabledException {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = 'Геолокация өшірулі. Орналасқан жерді қосыңыз.';
      });
    } on PermissionDeniedException {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = 'Локацияға рұқсат берілмеді.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = 'Орналасқан жерді анықтау кезінде қате шықты.';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_category == null || _position == null) {
      return;
    }

    setState(() => _submitting = true);
    await ref
        .read(reportRepositoryProvider)
        .createReport(
          ReportDraft(
            userId: DemoData.currentUser.uid,
            category: _category!,
            description: _descriptionController.text.isEmpty
                ? 'Жаңа мәселе тіркелді.'
                : _descriptionController.text,
            imageFile: _image,
            latitude: _position!.latitude,
            longitude: _position!.longitude,
            address: _address,
          ),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Мәселе тіркелді. +10 балл қосылды.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мәселе тіркеу')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: List.generate(4, (index) {
                final active = index <= _step;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ['Фото', 'GPS', 'Түрі', 'Жіберу'][index],
                          style: TextStyle(
                            fontSize: 11,
                            color: active
                                ? AppColors.accent
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _CameraStep(image: _image, onOpenCamera: _openCamera),
                _LocationStep(
                  position: _position,
                  address: _address,
                  loading: _loadingLocation,
                  errorText: _locationError,
                  onFetchLocation: _capturePhotoLocation,
                  onNext: _position == null ? null : _nextStep,
                ),
                _CategoryStep(
                  selected: _category,
                  descriptionController: _descriptionController,
                  onSelect: (value) => setState(() => _category = value),
                  onNext: _category == null ? null : _nextStep,
                ),
                _ConfirmStep(
                  image: _image,
                  position: _position,
                  address: _address,
                  category: _category,
                  description: _descriptionController.text,
                  submitting: _submitting,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraStep extends StatelessWidget {
  const _CameraStep({required this.image, required this.onOpenCamera});

  final File? image;
  final Future<void> Function() onOpenCamera;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: image == null
                  ? const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 52,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 10),
                        Text('Мәселенің фотосын түсіріңіз'),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(image!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onOpenCamera,
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text('Камераны ашу'),
          ),
        ],
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.position,
    required this.address,
    required this.loading,
    required this.errorText,
    required this.onFetchLocation,
    required this.onNext,
  });

  final Position? position;
  final String address;
  final bool loading;
  final String? errorText;
  final Future<void> Function() onFetchLocation;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final target = position == null
        ? const LatLng(43.238949, 76.889709)
        : LatLng(position!.latitude, position!.longitude);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GoogleMap(
                key: ValueKey(
                  position == null
                      ? 'no-location'
                      : '${position!.latitude},${position!.longitude}',
                ),
                initialCameraPosition: CameraPosition(target: target, zoom: 14),
                myLocationEnabled: position != null,
                myLocationButtonEnabled: position != null,
                markers: {
                  if (position != null)
                    Marker(
                      markerId: const MarkerId('current'),
                      position: target,
                      infoWindow: const InfoWindow(
                        title: 'Фото түсірілген орын',
                      ),
                    ),
                },
                circles: {
                  if (position != null)
                    Circle(
                      circleId: const CircleId('capture-radius'),
                      center: target,
                      radius: 12,
                      fillColor: AppColors.accent.withValues(alpha: 0.18),
                      strokeColor: AppColors.accent,
                      strokeWidth: 2,
                    ),
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position == null
                      ? 'Фото орны анықталмады'
                      : 'Фото түсірілген орын анықталды',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  position == null
                      ? 'Сурет түсірілген сәттегі нақты орынды жүктеңіз'
                      : '${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}\n$address',
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                  ),
                ),
                if (loading) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(),
                ],
                if (errorText != null && errorText!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    errorText!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: loading ? null : onFetchLocation,
            child: Text(
              loading ? 'Локация анықталуда...' : 'Локацияны қайта анықтау',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onNext, child: const Text('Жалғастыру')),
        ],
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.selected,
    required this.descriptionController,
    required this.onSelect,
    required this.onNext,
  });

  final ReportCategory? selected;
  final TextEditingController descriptionController;
  final ValueChanged<ReportCategory> onSelect;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final items = [
      (ReportCategory.trash, '🗑️', 'Қоқыс'),
      (ReportCategory.road, '🚧', 'Жол бұзылған'),
      (ReportCategory.water, '💧', 'Су ағып жатыр'),
      (ReportCategory.other, '⚠️', 'Басқа'),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: items.map((item) {
              final active = item.$1 == selected;
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(item.$1),
                child: Container(
                  decoration: BoxDecoration(
                    color: active ? AppColors.accentDim : AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active ? AppColors.accent : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.$2, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 8),
                      Text(
                        item.$3,
                        style: TextStyle(
                          color: active ? AppColors.accent : AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Сипаттама',
              hintText: 'Мәселе туралы қысқаша жазыңыз',
            ),
          ),
          const Spacer(),
          FilledButton(onPressed: onNext, child: const Text('Жалғастыру')),
        ],
      ),
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.image,
    required this.position,
    required this.address,
    required this.category,
    required this.description,
    required this.submitting,
    required this.onSubmit,
  });

  final File? image;
  final Position? position;
  final String address;
  final ReportCategory? category;
  final String description;
  final bool submitting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Тексеру',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image!, height: 140, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Категория',
                  value: category?.name ?? 'Таңдалмаған',
                ),
                _SummaryRow(
                  label: 'Локация',
                  value: position == null
                      ? 'Анықталмаған'
                      : '${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}',
                ),
                _SummaryRow(
                  label: 'Мекенжай',
                  value: address.isEmpty ? 'Жоқ' : address,
                ),
                _SummaryRow(
                  label: 'Сипаттама',
                  value: description.isEmpty ? 'Жоқ' : description,
                ),
                const _SummaryRow(label: 'Балл', value: '+10'),
                if (position != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 180,
                      child: GoogleMap(
                        key: ValueKey(
                          'confirm-${position!.latitude},${position!.longitude}',
                        ),
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            position!.latitude,
                            position!.longitude,
                          ),
                          zoom: 17,
                        ),
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId('confirm-location'),
                            position: LatLng(
                              position!.latitude,
                              position!.longitude,
                            ),
                            infoWindow: const InfoWindow(
                              title: 'Нақты түсірілген орын',
                            ),
                          ),
                        },
                        circles: {
                          Circle(
                            circleId: const CircleId('confirm-radius'),
                            center: LatLng(
                              position!.latitude,
                              position!.longitude,
                            ),
                            radius: 12,
                            fillColor: AppColors.accent.withValues(alpha: 0.18),
                            strokeColor: AppColors.accent,
                            strokeWidth: 2,
                          ),
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: submitting ? null : onSubmit,
            child: Text(submitting ? 'Жіберілуде...' : 'Жіберу'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
