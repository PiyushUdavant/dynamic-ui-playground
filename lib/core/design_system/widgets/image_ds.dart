import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../ds_helpers.dart';

class ImageDS extends BaseDS<Widget> {
  ImageDS({required this.url, this.width, this.height, this.fit, this.showLoading = true, this.showError = true});
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool showLoading;
  final bool showError;

  @override
  String get type => 'image';

  @override
  Widget build() => Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (!showLoading) return child;
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (!showError) return const SizedBox.shrink();
          return SizedBox(
            width: width,
            height: height,
            child: const Center(child: Icon(Icons.broken_image)),
          );
        },
      );

  factory ImageDS.fromJson(Map<String, dynamic> json) => ImageDS(
        url: (json['url'] ?? '').toString(),
        width: (json['width'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        fit: stringToBoxFit(json['fit']),
        showLoading: json['showLoading'] != false,
        showError: json['showError'] != false,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (fit != null) 'fit': boxFitToString(fit!),
        'showLoading': showLoading,
        'showError': showError,
      };
}

