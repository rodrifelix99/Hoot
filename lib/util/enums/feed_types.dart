import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

// Feed order constants to control the relative position of special feeds.
const kGeneralFeedOrder = 0; // Ensures the general feed appears first.
const kOtherFeedOrder = 1000; // Places the miscellaneous feed at the end.

enum FeedType {
  general,
  activism,
  activities,
  adultContent,
  art,
  beauty,
  celebrities,
  comedy,
  design,
  environment,
  family,
  fitness,
  gaming,
  history,
  inspiration,
  jobs,
  lgbtQ,
  marketing,
  movies,
  music,
  nature,
  news,
  onlineCourses,
  outdoors,
  parenting,
  pets,
  photography,
  quotes,
  relationships,
  recipes,
  religion,
  school,
  science,
  selfImprovement,
  series,
  sports,
  technology,
  travel,
  tv,
  university,
  vegetarian,
  wellness,
  writing,
  yoga,
  business,
  cooking,
  diY,
  economics,
  education,
  entertainment,
  entrepreneurship,
  gardening,
  health,
  investing,
  journalism,
  kids,
  literature,
  urbanExploration,
  virtualReality,
  zoology,
  other
}

extension FeedTypeExtension on FeedType {
  int get order {
    if (this == FeedType.general)
      return kGeneralFeedOrder; // General feed comes first.
    if (this == FeedType.other)
      return kOtherFeedOrder; // Other feed is sorted last.

    final firstLetter = toString().substring(0, 1).toLowerCase();
    return firstLetter.codeUnitAt(0);
  }

  String? get rssTopic {
    switch (this) {
      case FeedType.general:
        return 'WORLD';
      case FeedType.news:
        return 'NATION';
      case FeedType.business:
        return 'BUSINESS';
      case FeedType.technology:
        return 'TECHNOLOGY';
      case FeedType.entertainment:
        return 'ENTERTAINMENT';
      case FeedType.science:
        return 'SCIENCE';
      case FeedType.sports:
        return 'SPORTS';
      case FeedType.health:
        return 'HEALTH';
      default:
        return null;
    }
  }

  static String toTranslatedString(BuildContext context, FeedType type) {
    switch (type) {
      case FeedType.activism:
        return 'activism'.tr;
      case FeedType.activities:
        return 'activities'.tr;
      case FeedType.adultContent:
        return 'adultContent'.tr;
      case FeedType.art:
        return 'art'.tr;
      case FeedType.beauty:
        return 'beauty'.tr;
      case FeedType.celebrities:
        return 'celebrities'.tr;
      case FeedType.comedy:
        return 'comedy'.tr;
      case FeedType.design:
        return 'design'.tr;
      case FeedType.environment:
        return 'environment'.tr;
      case FeedType.family:
        return 'family'.tr;
      case FeedType.fitness:
        return 'fitness'.tr;
      case FeedType.general:
        return 'general'.tr;
      case FeedType.gaming:
        return 'gaming'.tr;
      case FeedType.history:
        return 'history'.tr;
      case FeedType.inspiration:
        return 'inspiration'.tr;
      case FeedType.jobs:
        return 'jobs'.tr;
      case FeedType.lgbtQ:
        return 'lgbtQ'.tr;
      case FeedType.marketing:
        return 'marketing'.tr;
      case FeedType.movies:
        return 'movies'.tr;
      case FeedType.music:
        return 'music'.tr;
      case FeedType.nature:
        return 'nature'.tr;
      case FeedType.news:
        return 'news'.tr;
      case FeedType.onlineCourses:
        return 'onlineCourses'.tr;
      case FeedType.outdoors:
        return 'outdoors'.tr;
      case FeedType.parenting:
        return 'parenting'.tr;
      case FeedType.pets:
        return 'pets'.tr;
      case FeedType.photography:
        return 'photography'.tr;
      case FeedType.quotes:
        return 'quotes'.tr;
      case FeedType.relationships:
        return 'relationships'.tr;
      case FeedType.recipes:
        return 'recipes'.tr;
      case FeedType.religion:
        return 'religion'.tr;
      case FeedType.school:
        return 'school'.tr;
      case FeedType.science:
        return 'science'.tr;
      case FeedType.selfImprovement:
        return 'selfImprovement'.tr;
      case FeedType.series:
        return 'series'.tr;
      case FeedType.sports:
        return 'sports'.tr;
      case FeedType.technology:
        return 'technology'.tr;
      case FeedType.travel:
        return 'travel'.tr;
      case FeedType.tv:
        return 'tv'.tr;
      case FeedType.university:
        return 'university'.tr;
      case FeedType.vegetarian:
        return 'vegetarian'.tr;
      case FeedType.wellness:
        return 'wellness'.tr;
      case FeedType.writing:
        return 'writing'.tr;
      case FeedType.yoga:
        return 'yoga'.tr;
      case FeedType.business:
        return 'business'.tr;
      case FeedType.cooking:
        return 'cooking'.tr;
      case FeedType.diY:
        return 'diY'.tr;
      case FeedType.economics:
        return 'economics'.tr;
      case FeedType.education:
        return 'education'.tr;
      case FeedType.entertainment:
        return 'entertainment'.tr;
      case FeedType.entrepreneurship:
        return 'entrepreneurship'.tr;
      case FeedType.gardening:
        return 'gardening'.tr;
      case FeedType.health:
        return 'health'.tr;
      case FeedType.investing:
        return 'investing'.tr;
      case FeedType.journalism:
        return 'journalism'.tr;
      case FeedType.kids:
        return 'kids'.tr;
      case FeedType.literature:
        return 'literature'.tr;
      case FeedType.urbanExploration:
        return 'urbanExploration'.tr;
      case FeedType.virtualReality:
        return 'virtualReality'.tr;
      case FeedType.zoology:
        return 'zoology'.tr;
      default:
        return 'other'.tr;
    }
  }

  static String toEmoji(FeedType type) {
    switch (type) {
      case FeedType.activism:
        return '✊';
      case FeedType.activities:
        return '🏐';
      case FeedType.adultContent:
        return '🔥';
      case FeedType.art:
        return '🎨';
      case FeedType.beauty:
        return '💄';
      case FeedType.celebrities:
        return '⭐';
      case FeedType.comedy:
        return '🎭';
      case FeedType.design:
        return '✏️';
      case FeedType.environment:
        return '🌿';
      case FeedType.family:
        return '👪';
      case FeedType.fitness:
        return '💪';
      case FeedType.general:
        return '🌍';
      case FeedType.gaming:
        return '🎮';
      case FeedType.history:
        return '📜';
      case FeedType.inspiration:
        return '💡';
      case FeedType.jobs:
        return '💼';
      case FeedType.lgbtQ:
        return '🏳️‍🌈';
      case FeedType.marketing:
        return '📈';
      case FeedType.movies:
        return '🎬';
      case FeedType.music:
        return '🎵';
      case FeedType.nature:
        return '🌳';
      case FeedType.news:
        return '📰';
      case FeedType.onlineCourses:
        return '🎓';
      case FeedType.outdoors:
        return '🏕️';
      case FeedType.parenting:
        return '🤱';
      case FeedType.pets:
        return '🐾';
      case FeedType.photography:
        return '📷';
      case FeedType.quotes:
        return '💬';
      case FeedType.relationships:
        return '💑';
      case FeedType.recipes:
        return '👩‍🍳';
      case FeedType.religion:
        return '🙏';
      case FeedType.school:
        return '🏫';
      case FeedType.science:
        return '🔬';
      case FeedType.selfImprovement:
        return '🌱';
      case FeedType.series:
        return '📺';
      case FeedType.sports:
        return '🏀';
      case FeedType.technology:
        return '💻';
      case FeedType.travel:
        return '✈️';
      case FeedType.tv:
        return '📺';
      case FeedType.university:
        return '🎓';
      case FeedType.vegetarian:
        return '🥗';
      case FeedType.wellness:
        return '🧘';
      case FeedType.writing:
        return '✍️';
      case FeedType.yoga:
        return '🧘';
      case FeedType.business:
        return '📊';
      case FeedType.cooking:
        return '🍳';
      case FeedType.diY:
        return '🔧';
      case FeedType.economics:
        return '💰';
      case FeedType.education:
        return '📚';
      case FeedType.entertainment:
        return '🎉';
      case FeedType.entrepreneurship:
        return '🚀';
      case FeedType.gardening:
        return '🪴';
      case FeedType.health:
        return '🩺';
      case FeedType.investing:
        return '📈';
      case FeedType.journalism:
        return '📝';
      case FeedType.kids:
        return '👶';
      case FeedType.literature:
        return '📚';
      case FeedType.urbanExploration:
        return '🏙️';
      case FeedType.virtualReality:
        return '🕶️';
      case FeedType.zoology:
        return '🦁';
      default:
        return '❓';
    }
  }

  static IconData toIcon(FeedType type) {
    switch (type) {
      case FeedType.activism:
        return SolarIconsBold.handHeart;
      case FeedType.activities:
        return SolarIconsBold.volleyball;
      case FeedType.adultContent:
        return SolarIconsBold.flame;
      case FeedType.art:
        return SolarIconsBold.palette2;
      case FeedType.beauty:
        return SolarIconsBold.cosmetic;
      case FeedType.celebrities:
        return SolarIconsBold.star;
      case FeedType.comedy:
        return SolarIconsBold.masks;
      case FeedType.design:
        return SolarIconsBold.palette;
      case FeedType.environment:
        return SolarIconsBold.leaf;
      case FeedType.family:
        return SolarIconsBold.heart;
      case FeedType.fitness:
        return SolarIconsBold.dumbbell;
      case FeedType.general:
        return SolarIconsBold.earth;
      case FeedType.gaming:
        return SolarIconsBold.gamepad;
      case FeedType.history:
        return SolarIconsBold.history;
      case FeedType.inspiration:
        return SolarIconsBold.lightbulb;
      case FeedType.jobs:
        return SolarIconsBold.laptop2;
      case FeedType.lgbtQ:
        return SolarIconsBold.starRainbow;
      case FeedType.marketing:
        return SolarIconsBold.presentationGraph;
      case FeedType.movies:
        return SolarIconsBold.clapperboardOpen;
      case FeedType.music:
        return SolarIconsBold.musicNote;
      case FeedType.nature:
        return SolarIconsBold.leaf;
      case FeedType.news:
        return SolarIconsBold.notebook;
      case FeedType.onlineCourses:
        return SolarIconsBold.diplomaVerified;
      case FeedType.outdoors:
        return SolarIconsBold.sun;
      case FeedType.parenting:
        return SolarIconsBold.userHandUp;
      case FeedType.pets:
        return SolarIconsBold.paw;
      case FeedType.photography:
        return SolarIconsBold.camera;
      case FeedType.quotes:
        return SolarIconsBold.pen;
      case FeedType.relationships:
        return SolarIconsBold.heartPulse;
      case FeedType.recipes:
        return SolarIconsBold.chefHat;
      case FeedType.religion:
        return SolarIconsBold.handStars;
      case FeedType.school:
        return SolarIconsBold.squareAcademicCap;
      case FeedType.science:
        return SolarIconsBold.testTube;
      case FeedType.selfImprovement:
        return SolarIconsBold.heartUnlock;
      case FeedType.series:
        return SolarIconsBold.tv;
      case FeedType.sports:
        return SolarIconsBold.basketball;
      case FeedType.technology:
        return SolarIconsBold.laptop3;
      case FeedType.travel:
        return SolarIconsBold.suitcase;
      case FeedType.tv:
        return SolarIconsBold.tv;
      case FeedType.university:
        return SolarIconsBold.squareAcademicCap2;
      case FeedType.vegetarian:
        return SolarIconsBold.leaf;
      case FeedType.wellness:
        return SolarIconsBold.heartAngle;
      case FeedType.writing:
        return SolarIconsBold.pen;
      case FeedType.yoga:
        return SolarIconsBold.heartShine;
      case FeedType.business:
        return SolarIconsBold.roundGraph;
      case FeedType.cooking:
        return SolarIconsBold.chefHat;
      case FeedType.diY:
        return SolarIconsBold.paletteRound;
      case FeedType.economics:
        return SolarIconsBold.moneyBag;
      case FeedType.education:
        return SolarIconsBold.squareAcademicCap;
      case FeedType.entertainment:
        return SolarIconsBold.clapperboardPlay;
      case FeedType.entrepreneurship:
        return SolarIconsBold.pieChart2;
      case FeedType.gardening:
        return SolarIconsBold.leaf;
      case FeedType.health:
        return SolarIconsBold.health;
      case FeedType.investing:
        return SolarIconsBold.chart_2;
      case FeedType.journalism:
        return SolarIconsBold.notebook;
      case FeedType.kids:
        return SolarIconsBold.userHandUp;
      case FeedType.literature:
        return SolarIconsBold.book;
      case FeedType.urbanExploration:
        return SolarIconsBold.routing3;
      case FeedType.virtualReality:
        return SolarIconsBold.smartphoneRotateAngle;
      case FeedType.zoology:
        return SolarIconsBold.leaf;
      default:
        return SolarIconsBold.planet;
    }
  }

  static FeedType fromString(String type) {
    switch (type) {
      case 'activism':
        return FeedType.activism;
      case 'activities':
        return FeedType.activities;
      case 'adultContent':
        return FeedType.adultContent;
      case 'art':
        return FeedType.art;
      case 'beauty':
        return FeedType.beauty;
      case 'celebrities':
        return FeedType.celebrities;
      case 'comedy':
        return FeedType.comedy;
      case 'design':
        return FeedType.design;
      case 'environment':
        return FeedType.environment;
      case 'family':
        return FeedType.family;
      case 'fitness':
        return FeedType.fitness;
      case 'general':
        return FeedType.general;
      case 'gaming':
        return FeedType.gaming;
      case 'history':
        return FeedType.history;
      case 'inspiration':
        return FeedType.inspiration;
      case 'jobs':
        return FeedType.jobs;
      case 'lgbtQ':
        return FeedType.lgbtQ;
      case 'marketing':
        return FeedType.marketing;
      case 'movies':
        return FeedType.movies;
      case 'music':
        return FeedType.music;
      case 'nature':
        return FeedType.nature;
      case 'news':
        return FeedType.news;
      case 'onlineCourses':
        return FeedType.onlineCourses;
      case 'outdoors':
        return FeedType.outdoors;
      case 'parenting':
        return FeedType.parenting;
      case 'pets':
        return FeedType.pets;
      case 'photography':
        return FeedType.photography;
      case 'quotes':
        return FeedType.quotes;
      case 'relationships':
        return FeedType.relationships;
      case 'recipes':
        return FeedType.recipes;
      case 'religion':
        return FeedType.religion;
      case 'school':
        return FeedType.school;
      case 'science':
        return FeedType.science;
      case 'selfImprovement':
        return FeedType.selfImprovement;
      case 'series':
        return FeedType.series;
      case 'sports':
        return FeedType.sports;
      case 'technology':
        return FeedType.technology;
      case 'travel':
        return FeedType.travel;
      case 'tv':
        return FeedType.tv;
      case 'university':
        return FeedType.university;
      case 'vegetarian':
        return FeedType.vegetarian;
      case 'wellness':
        return FeedType.wellness;
      case 'writing':
        return FeedType.writing;
      case 'yoga':
        return FeedType.yoga;
      case 'business':
        return FeedType.business;
      case 'cooking':
        return FeedType.cooking;
      case 'diY':
        return FeedType.diY;
      case 'economics':
        return FeedType.economics;
      case 'education':
        return FeedType.education;
      case 'entertainment':
        return FeedType.entertainment;
      case 'entrepreneurship':
        return FeedType.entrepreneurship;
      case 'gardening':
        return FeedType.gardening;
      case 'health':
        return FeedType.health;
      case 'investing':
        return FeedType.investing;
      case 'journalism':
        return FeedType.journalism;
      case 'kids':
        return FeedType.kids;
      case 'literature':
        return FeedType.literature;
      case 'urbanExploration':
        return FeedType.urbanExploration;
      case 'virtualReality':
        return FeedType.virtualReality;
      case 'zoology':
        return FeedType.zoology;
      default:
        return FeedType.other;
    }
  }
}
