class RoomTypeModel {
  final String title;
  final String subtitle;
  final String floor;
  final String size;
  final String bed;
  final String image;
  final List<String> amenities;
  final List<String> images; //placeholder untuk images

  const RoomTypeModel({
    required this.title,
    required this.subtitle,
    required this.floor,
    required this.size,
    required this.bed,
    required this.image,
    required this.amenities,
    required this.images,
  });
}

const List<RoomTypeModel> roomTypesData = [
  RoomTypeModel(
    title: 'Deluxe room',
    subtitle: 'Deluxe Room 2 guests / Room',
    floor: '1st floor',
    size: '18 m²',
    bed: 'Queen Bed',
    image: 'assets/images/deluxe_1.png',
    amenities: [
      'Free Wi-Fi',
      'AC',
      'Room service',
      'Desk and Chair',
      'Towel',
      'TV Digital',
      'Free Water',
      'Shower ( water heater )',
      'Wardrobe',
    ],
    images: [
      'assets/images/deluxe_1.png',
      'assets/images/deluxe_2.png',
      'assets/images/deluxe_3.png',
      'assets/images/deluxe_4.png',
      'assets/images/deluxe_5.png',
      'assets/images/deluxe_6.png',
      'assets/images/deluxe_7.png',
      'assets/images/deluxe_8.png',
    ],
  ),
  RoomTypeModel(
    title: 'Superior room',
    subtitle: 'Superior Room 2 guests / Room',
    floor: '2nd floor',
    size: '17 m²',
    bed: 'Queen Bed',
    image: 'assets/images/superior_1.png',
    amenities: [
      'Free Wi-Fi',
      'AC',
      'Room service',
      'Desk and Chair',
      'Towel',
      'TV Digital',
      'Free Water',
      'Shower ( water heater )',
      'Wardrobe',
    ],
    images: [
      'assets/images/superior_1.png', 
      'assets/images/superior_2.png', 
      'assets/images/superior_3.png', 
      'assets/images/superior_4.png', 
      'assets/images/superior_5.png', 
      'assets/images/superior_6.png', 
      'assets/images/superior_7.png',
      ],
  ),
  RoomTypeModel(
    title: 'Premier room',
    subtitle: 'Premier Room 2 guests / Room',
    floor: '3rd floor',
    size: '15 m²',
    bed: 'Queen Bed',
    image: 'assets/images/premier_1.png',
    amenities: [
      'Free Wi-Fi',
      'AC',
      'Room service',
      'Desk and Chair',
      'Towel',
      'TV Digital',
      'Free Water',
      'Shower ( water heater )',
      'Wardrobe',
    ],
    images: [
      'assets/images/premier_1.png', 
      'assets/images/premier_2.png', 
      'assets/images/premier_3.png', 
      'assets/images/premier_4.png', 
      'assets/images/premier_5.png', 
      'assets/images/premier_6.png',
      ],
  ),
];
