import 'dart:typed_data';

class Nft {
  const Nft({
    required this.id,
    required this.name,
    required this.creator,
    required this.image,
    required this.price,
    this.likes = 200,
    this.bytes,
  });
  final String id, name, creator, image;
  final double price;
  final int likes;
  final Uint8List? bytes;
}

class Seller {
  const Seller(this.name, this.handle, this.image, this.earnings);
  final String name, handle, image, earnings;
}

class Bid {
  const Bid(this.name, this.image, this.amount, this.date, {this.mine = false});
  final bool mine;
  final String name, image;
  final double amount;
  final DateTime date;
  Map<String, dynamic> toJson() => {
    'name': name,
    'image': image,
    'amount': amount,
    'mine': mine,
    'date': date.toIso8601String(),
  };
  factory Bid.fromJson(Map<String, dynamic> json) => Bid(
    json['name'] as String,
    json['image'] as String,
    (json['amount'] as num).toDouble(),
    DateTime.parse(json['date'] as String),
    mine: json['mine'] as bool? ?? false,
  );
}

class MarketNotice {
  const MarketNotice(this.title, this.subtitle, this.date, {this.nftId});
  final String title, subtitle;
  final DateTime date;
  final String? nftId;
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'date': date.toIso8601String(),
    'nftId': nftId,
  };
  factory MarketNotice.fromJson(Map<String, dynamic> json) => MarketNotice(
    json['title'] as String,
    json['subtitle'] as String,
    DateTime.parse(json['date'] as String),
    nftId: json['nftId'] as String?,
  );
}

const nfts = [
  Nft(
    id: 'sun',
    name: 'Sun-Glass',
    creator: 'Perperzon',
    image: 'sun-glass',
    price: 1.75,
  ),
  Nft(
    id: 'nu',
    name: 'NuEvey',
    creator: 'JenniferS',
    image: 'nu-evey',
    price: 1.25,
    likes: 810,
  ),
  Nft(
    id: 'rotation',
    name: 'Rotation',
    creator: 'Allison Re.',
    image: 'onboarding-2',
    price: .81,
    likes: 324,
  ),
  Nft(
    id: 'orbit',
    name: 'Orbit',
    creator: 'Trevor Pu.',
    image: 'onboarding-3',
    price: 2.4,
    likes: 126,
  ),
];

const sellers = [
  Seller('Alex Ca.', 'Alexy', 'seller-1', '47,102.27'),
  Seller('Juliya Sa.', 'JuliyaS', 'seller-2', '31,102.27'),
  Seller('Trevor Pu.', 'TrevorP', 'seller-3', '28,840.12'),
  Seller('Allison Re.', 'AllisonR', 'seller-4', '21,560.38'),
  Seller('Kaya Za.', 'KayaZ', 'seller-5', '19,430.80'),
  Seller('Maude Ma.', 'Maude007', 'seller-6', '16,985.21'),
  Seller('Jennifer Ni.', 'Jennifer24', 'seller-7', '12,401.63'),
];
