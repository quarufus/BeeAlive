import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:latlong2/latlong.dart';

class DangerMap {
  getDangerByLocation(LatLng latLng) {}

  Future<img.Image> getImage() async {
    Future<img.Image> image = img
        .decodeImageFile(
            'https://www.civilprotection.gr/sites/default/gscp_uploads/221031.jpg')
        .then((value) => img.Image(width: 256, height: 256));
    return image;
  }
}
