class CompanyBrand {
  const CompanyBrand({required this.name, required this.logoAsset});

  final String name;
  final String logoAsset;
}

const _srRentACar = CompanyBrand(
  name: 'SR Rent A Car',
  logoAsset: 'assets/images/SR Rent a car.jpg',
);

CompanyBrand companyBrandForUsername(String username) {
  switch (username.trim().toLowerCase()) {
    case 'airport':
      return const CompanyBrand(
        name: 'Airport Parking',
        logoAsset: 'assets/images/AirportParking.jpg',
      );
    case 'transfers':
      return const CompanyBrand(
        name: 'SR Transfers',
        logoAsset: 'assets/images/SR Transfers.png',
      );
    case 'explore':
      return const CompanyBrand(
        name: 'Explore Vacations',
        logoAsset: 'assets/images/Explore Vacations.jpg',
      );
    case 'platinum':
      return const CompanyBrand(
        name: 'PlatinumDrive.LK',
        logoAsset: 'assets/images/Platinum Drive LK.png',
      );
    case 'elite':
      return const CompanyBrand(
        name: 'Elite Rent a Car',
        logoAsset: 'assets/images/Elite Rent a Car.jpg',
      );
    case 'sr':
    case 'agent1':
    default:
      return _srRentACar;
  }
}

CompanyBrand companyBrandForKey(String? key) =>
    companyBrandForUsername(key ?? 'sr');
