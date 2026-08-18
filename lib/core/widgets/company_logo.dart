import 'package:flutter/material.dart';

class CompanyLogo extends StatelessWidget {
  const CompanyLogo({super.key, this.size = 90});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Sri Lanka Rent A Car logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Image.asset(
            'assets/images/SR Rent a car.jpg',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.directions_car_rounded, size: 48),
              );
            },
          ),
        ),
      ),
    );
  }
}
