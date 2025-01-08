import 'package:flutter/material.dart';
import 'package:material/material.dart';
export 'shapes/paths_new.dart';

abstract final class Corners {
  static const double none = 0.0;

  static const double extraSmall = 4.0;

  static const double small = 8.0;

  static const double medium = 12.0;

  static const double large = 16.0;

  static const double extraLarge = 28.0;
}

abstract final class Radii {
  static const Radius none = Radius.circular(Corners.none);

  static const Radius extraSmall = Radius.circular(Corners.extraSmall);

  static const Radius small = Radius.circular(Corners.small);

  static const Radius medium = Radius.circular(Corners.medium);

  static const Radius large = Radius.circular(Corners.large);

  static const Radius extraLarge = Radius.circular(Corners.extraLarge);
}

abstract final class Shapes {
  static const OutlinedBorder none = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.none),
  );

  static const OutlinedBorder extraSmall = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.extraSmall),
  );
  static const OutlinedBorder extraSmallTop = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radii.extraSmall),
  );

  static const OutlinedBorder small = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.small),
  );

  static const OutlinedBorder medium = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.medium),
  );

  static const OutlinedBorder large = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.large),
  );
  static const OutlinedBorder largeTop = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radii.large),
  );
  static const OutlinedBorder largeStart = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(left: Radii.large),
  );
  static const OutlinedBorder largeEnd = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radii.large),
  );

  static const OutlinedBorder extraLarge = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radii.extraLarge),
  );
  static const OutlinedBorder extraLargeTop = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radii.extraLarge),
  );

  static const OutlinedBorder full = StadiumBorder();
}
