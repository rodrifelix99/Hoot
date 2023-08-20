import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:solar_icons/solar_icons.dart';

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
    if (this == FeedType.general) return 0;
    if (this == FeedType.other) return 1000;

    final firstLetter = toString().substring(0, 1).toLowerCase();
    return firstLetter.codeUnitAt(0);
  }

  static String toTranslatedString(BuildContext context, FeedType type) {
    switch (type) {
      case FeedType.activism:
        return AppLocalizations.of(context)!.activism;
      case FeedType.activities:
        return AppLocalizations.of(context)!.activities;
      case FeedType.adultContent:
        return AppLocalizations.of(context)!.adultContent;
      case FeedType.art:
        return AppLocalizations.of(context)!.art;
      case FeedType.beauty:
        return AppLocalizations.of(context)!.beauty;
      case FeedType.celebrities:
        return AppLocalizations.of(context)!.celebrities;
      case FeedType.comedy:
        return AppLocalizations.of(context)!.comedy;
      case FeedType.design:
        return AppLocalizations.of(context)!.design;
      case FeedType.environment:
        return AppLocalizations.of(context)!.environment;
      case FeedType.family:
        return AppLocalizations.of(context)!.family;
      case FeedType.fitness:
        return AppLocalizations.of(context)!.fitness;
      case FeedType.general:
        return AppLocalizations.of(context)!.general;
      case FeedType.gaming:
        return AppLocalizations.of(context)!.gaming;
      case FeedType.history:
        return AppLocalizations.of(context)!.history;
      case FeedType.inspiration:
        return AppLocalizations.of(context)!.inspiration;
      case FeedType.jobs:
        return AppLocalizations.of(context)!.jobs;
      case FeedType.lgbtQ:
        return AppLocalizations.of(context)!.lgbtQ;
      case FeedType.marketing:
        return AppLocalizations.of(context)!.marketing;
      case FeedType.movies:
        return AppLocalizations.of(context)!.movies;
      case FeedType.music:
        return AppLocalizations.of(context)!.music;
      case FeedType.nature:
        return AppLocalizations.of(context)!.nature;
      case FeedType.news:
        return AppLocalizations.of(context)!.news;
      case FeedType.onlineCourses:
        return AppLocalizations.of(context)!.onlineCourses;
      case FeedType.outdoors:
        return AppLocalizations.of(context)!.outdoors;
      case FeedType.parenting:
        return AppLocalizations.of(context)!.parenting;
      case FeedType.pets:
        return AppLocalizations.of(context)!.pets;
      case FeedType.photography:
        return AppLocalizations.of(context)!.photography;
      case FeedType.quotes:
        return AppLocalizations.of(context)!.quotes;
      case FeedType.relationships:
        return AppLocalizations.of(context)!.relationships;
      case FeedType.recipes:
        return AppLocalizations.of(context)!.recipes;
      case FeedType.religion:
        return AppLocalizations.of(context)!.religion;
      case FeedType.school:
        return AppLocalizations.of(context)!.school;
      case FeedType.science:
        return AppLocalizations.of(context)!.science;
      case FeedType.selfImprovement:
        return AppLocalizations.of(context)!.selfImprovement;
      case FeedType.series:
        return AppLocalizations.of(context)!.series;
      case FeedType.sports:
        return AppLocalizations.of(context)!.sports;
      case FeedType.technology:
        return AppLocalizations.of(context)!.technology;
      case FeedType.travel:
        return AppLocalizations.of(context)!.travel;
      case FeedType.tv:
        return AppLocalizations.of(context)!.tv;
      case FeedType.university:
        return AppLocalizations.of(context)!.university;
      case FeedType.vegetarian:
        return AppLocalizations.of(context)!.vegetarian;
      case FeedType.wellness:
        return AppLocalizations.of(context)!.wellness;
      case FeedType.writing:
        return AppLocalizations.of(context)!.writing;
      case FeedType.yoga:
        return AppLocalizations.of(context)!.yoga;
      case FeedType.business:
        return AppLocalizations.of(context)!.business;
      case FeedType.cooking:
        return AppLocalizations.of(context)!.cooking;
      case FeedType.diY:
        return AppLocalizations.of(context)!.diY;
      case FeedType.economics:
        return AppLocalizations.of(context)!.economics;
      case FeedType.education:
        return AppLocalizations.of(context)!.education;
      case FeedType.entertainment:
        return AppLocalizations.of(context)!.entertainment;
      case FeedType.entrepreneurship:
        return AppLocalizations.of(context)!.entrepreneurship;
      case FeedType.gardening:
        return AppLocalizations.of(context)!.gardening;
      case FeedType.health:
        return AppLocalizations.of(context)!.health;
      case FeedType.investing:
        return AppLocalizations.of(context)!.investing;
      case FeedType.journalism:
        return AppLocalizations.of(context)!.journalism;
      case FeedType.kids:
        return AppLocalizations.of(context)!.kids;
      case FeedType.literature:
        return AppLocalizations.of(context)!.literature;
      case FeedType.urbanExploration:
        return AppLocalizations.of(context)!.urbanExploration;
      case FeedType.virtualReality:
        return AppLocalizations.of(context)!.virtualReality;
      case FeedType.zoology:
        return AppLocalizations.of(context)!.zoology;
      default:
        return AppLocalizations.of(context)!.other;
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
