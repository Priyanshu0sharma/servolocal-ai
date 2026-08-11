class DiagnosisResult {
  final String category;
  final String detectedIssue;
  final String icon;
  final int confidence;
  final String severity;
  final List<String> possibleCauses;
  final List<String> requiredParts;
  final double labourCost;
  final double partsCost;
  final double serviceCharge;
  final double rangeMin;
  final double rangeMax;

  DiagnosisResult({
    required this.category,
    required this.detectedIssue,
    required this.icon,
    required this.confidence,
    required this.severity,
    required this.possibleCauses,
    required this.requiredParts,
    required this.labourCost,
    required this.partsCost,
    required this.serviceCharge,
    required this.rangeMin,
    required this.rangeMax,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final pricing = json['pricing'] ?? {};
    return DiagnosisResult(
      category: json['category'] ?? 'AC Repair',
      detectedIssue: json['detected_issue'] ?? 'AC Cooling Failure',
      icon: json['icon'] ?? '❄️',
      confidence: json['confidence'] ?? 92,
      severity: json['severity'] ?? 'HIGH',
      possibleCauses: List<String>.from(json['possible_causes'] ?? []),
      requiredParts: List<String>.from(json['required_parts'] ?? []),
      labourCost: (pricing['labour'] as num? ?? 500).toDouble(),
      partsCost: (pricing['parts'] as num? ?? 800).toDouble(),
      serviceCharge: (pricing['service_charge'] as num? ?? 150).toDouble(),
      rangeMin: (pricing['range_min'] as num? ?? 1200).toDouble(),
      rangeMax: (pricing['range_max'] as num? ?? 1800).toDouble(),
    );
  }
}

class TechnicianModel {
  final int id;
  final String name;
  final String avatar;
  final String speciality;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final double visitCharge;

  TechnicianModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.speciality,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.visitCharge,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    return TechnicianModel(
      id: json['id'] ?? 1,
      name: json['name'] ?? 'Technician',
      avatar: json['avatar'] ?? '',
      speciality: json['speciality'] ?? 'Specialist',
      rating: (json['rating'] as num? ?? 4.8).toDouble(),
      reviewsCount: json['reviews_count'] ?? 100,
      distanceKm: (json['distance_km'] as num? ?? 2.4).toDouble(),
      visitCharge: (json['visit_charge'] as num? ?? 500).toDouble(),
    );
  }
}

class JobModel {
  final int id;
  final String jobCode;
  final String title;
  final String category;
  final String status;
  final String? technicianName;
  final String? technicianAvatar;
  final double? technicianDistance;
  final double labourCost;
  final double partsCost;
  final double serviceCharge;
  final double finalAmount;
  final String? beforeImage;
  final String? afterImage;

  JobModel({
    required this.id,
    required this.jobCode,
    required this.title,
    required this.category,
    required this.status,
    this.technicianName,
    this.technicianAvatar,
    this.technicianDistance,
    this.labourCost = 500.0,
    this.partsCost = 800.0,
    this.serviceCharge = 150.0,
    required this.finalAmount,
    this.beforeImage,
    this.afterImage,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? 0,
      jobCode: json['job_code'] ?? '#1000',
      title: json['title'] ?? 'Repair Service',
      category: json['category'] ?? 'Service',
      status: json['status'] ?? 'CREATED',
      technicianName: json['technician_name'],
      technicianAvatar: json['technician_avatar'],
      technicianDistance: json['technician_distance'] != null ? (json['technician_distance'] as num).toDouble() : 2.4,
      labourCost: (json['labour_cost'] as num? ?? 500.0).toDouble(),
      partsCost: (json['parts_cost'] as num? ?? 800.0).toDouble(),
      serviceCharge: (json['service_charge'] as num? ?? 150.0).toDouble(),
      finalAmount: (json['final_amount'] as num? ?? 1450.0).toDouble(),
      beforeImage: json['before_image'],
      afterImage: json['after_image'],
    );
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'user', 'technician', 'admin'
  final String? avatar;
  final String? address;
  final String? token;
  final Map<String, dynamic>? technicianProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.address,
    this.token,
    this.technicianProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token, Map<String, dynamic>? technicianProfile}) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 1,
      name: json['name'] ?? 'User',
      email: json['email'] ?? 'user@test.com',
      phone: json['phone'] ?? '+91 98765 12345',
      role: json['role'] ?? 'user',
      avatar: json['avatar'],
      address: json['address'] ?? 'Jaipur, Rajasthan',
      token: token ?? json['token'],
      technicianProfile: technicianProfile ?? json['technician'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'avatar': avatar,
    'address': address,
    'token': token,
    'technician': technicianProfile,
  };
}

