class RaceState{
  final String name;
  final RaceStatus status;
  RaceState({required this.name,required this.status});
  RaceState copyWith({
    String? name,
    RaceStatus? status,
  }){
    return RaceState(
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }
  factory RaceState.fromJson(Map<String,dynamic> json){
    return RaceState(
      name: json['name'],
      status: RaceStatus.values.byName(json['status']),
    );
  }

  Map<String,dynamic> toJson(){
    return{
      'name' : name,
      'status' : status.name,
    };
  }
}
enum RaceStatus{
  completed,
  ongoing,
  notStarted,
}