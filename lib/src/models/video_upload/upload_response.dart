import 'package:equatable/equatable.dart';

class UploadResponse extends Equatable{
  final String name;
  final String url;

  UploadResponse({required this.name, required this.url});
  
  @override
  List<Object?> get props => [name,url];
}
