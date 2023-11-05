import '../models/route_argument.dart';

import '../models/media.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class GalleryController extends ControllerMVC {
  List<Media> media ;
  Media current = Media();
  String heroTag = '';

  @override
  void initState() async {
    super.initState();
  }

}
