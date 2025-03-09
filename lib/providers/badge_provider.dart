import '../widgets/custom_badge.dart';

class BadgeProvider {
  final List<CustomBadge> badges = [
    CustomBadge(id: 1, name: 'Bronze', description: 'Earned at 100 XP', imagePath: 'assets/images/badges/badge_bronze.png'),
    CustomBadge(id: 2, name: 'Silver', description: 'Earned at 200 XP', imagePath: 'assets/images/badges/badge_silver.png'),
    CustomBadge(id: 3, name: 'Gold', description: 'Earned at 300 XP', imagePath: 'assets/images/badges/badge_gold.png'),
    CustomBadge(id: 4, name: 'Platinum', description: 'Earned at 400 XP', imagePath: 'assets/images/badges/badge_platinum.png'),
    CustomBadge(id: 5, name: 'Diamond', description: 'Earned at 500 XP', imagePath: 'assets/images/badges/badge_diamond.png'),
  ];

  List<CustomBadge> getBadgesForXP(int xp) {
    List<CustomBadge> earnedBadges = [];
    if (xp >= 100) earnedBadges.add(badges[0]);
    if (xp >= 200) earnedBadges.add(badges[1]);
    if (xp >= 300) earnedBadges.add(badges[2]);
    if (xp >= 400) earnedBadges.add(badges[3]);
    if (xp >= 500) earnedBadges.add(badges[4]);
    return earnedBadges;
  }
}