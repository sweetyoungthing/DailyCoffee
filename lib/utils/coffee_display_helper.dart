import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../db/coffee_record.dart';

class CoffeeDisplayHelper {
  static String getBrandName(BuildContext context, String brandId) {
    final l10n = AppLocalizations.of(context)!;

    switch (brandId) {
      case 'starbucks':
        return l10n.starbucks;
      case 'costa':
        return l10n.costa;
      case 'luckin':
        return l10n.luckin;
      default:
        return brandId; // 如果找不到匹配项，返回原始ID
    }
  }

  static String getTypeName(BuildContext context, String typeId) {
    final l10n = AppLocalizations.of(context)!;

    switch (typeId) {
      case 'americano':
        return l10n.americano;
      case 'latte':
        return l10n.latte;
      case 'cappuccino':
        return l10n.cappuccino;
      default:
        return typeId; // 如果找不到匹配项，返回原始ID
    }
  }

  static String getSizeName(BuildContext context, String sizeId) {
    final l10n = AppLocalizations.of(context)!;

    switch (sizeId) {
      case 'small':
        return l10n.small;
      case 'medium':
        return l10n.medium;
      case 'large':
        return l10n.large;
      default:
        return sizeId; // 如果找不到匹配项，返回原始ID
    }
  }

  static String getFormattedCoffeeInfo(
    BuildContext context,
    CoffeeRecord record,
  ) {
    final brandName = getBrandName(context, record.brand);
    final typeName = getTypeName(context, record.type);
    return '$brandName $typeName';
  }

  static String getFormattedSizeInfo(
    BuildContext context,
    CoffeeRecord record,
  ) {
    return getSizeName(context, record.size);
  }
}
