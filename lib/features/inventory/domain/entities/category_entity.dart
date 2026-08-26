import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconName;
  final String? colorHex;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.iconName,
    this.colorHex,
  });

  @override
  List<Object?> get props => [id, name, iconName, colorHex];
}
