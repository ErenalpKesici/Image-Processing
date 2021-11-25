import 'dart:ui';

class Sector{
  Color? color;
  List<Point>? points = List.empty(growable: true);
  Sector(this.color, Point point){
    points!.add(point);
  }
  void addPoints(Point point){
    points!.add(point);
  }
  @override
  String toString() {
    return color.toString() +": " + points.toString(); 
  }
}
class Point{
  int? x, y;
  Point({this.x, this.y});
  @override
  String toString() {
    return "("+x.toString()+", "+y.toString()+") ";
  }
}