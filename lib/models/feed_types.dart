import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        return Icons.public_rounded;
      case FeedType.activities:
        return Icons.local_activity_rounded;
      case FeedType.adultContent:
        return Icons.local_fire_department_rounded;
      case FeedType.art:
        return Icons.palette_rounded;
      case FeedType.beauty:
        return Icons.face_rounded;
      case FeedType.celebrities:
        return Icons.star_rounded;
      case FeedType.comedy:
        return Icons.emoji_emotions_rounded;
      case FeedType.design:
        return Icons.design_services_rounded;
      case FeedType.environment:
        return Icons.eco_rounded;
      case FeedType.family:
        return Icons.family_restroom_rounded;
      case FeedType.fitness:
        return Icons.fitness_center_rounded;
      case FeedType.general:
        return Icons.public_rounded;
      case FeedType.gaming:
        return Icons.sports_esports_rounded;
      case FeedType.history:
        return Icons.history_rounded;
      case FeedType.inspiration:
        return Icons.lightbulb_rounded;
      case FeedType.jobs:
        return Icons.work_rounded;
      case FeedType.lgbtQ:
        return Icons.interests_rounded;
      case FeedType.marketing:
        return Icons.mark_email_read_rounded;
      case FeedType.movies:
        return Icons.movie_rounded;
      case FeedType.music:
        return Icons.music_note_rounded;
      case FeedType.nature:
        return Icons.nature_rounded;
      case FeedType.news:
        return Icons.article_rounded;
      case FeedType.onlineCourses:
        return Icons.school_rounded;
      case FeedType.outdoors:
        return Icons.outdoor_grill_rounded;
      case FeedType.parenting:
        return Icons.child_care_rounded;
      case FeedType.pets:
        return Icons.pets_rounded;
      case FeedType.photography:
        return Icons.photo_camera_rounded;
      case FeedType.quotes:
        return Icons.format_quote_rounded;
      case FeedType.relationships:
        return Icons.favorite_rounded;
      case FeedType.recipes:
        return Icons.restaurant_rounded;
      case FeedType.religion:
        return Icons.handshake_rounded;
      case FeedType.school:
        return Icons.school_rounded;
      case FeedType.science:
        return Icons.science_rounded;
      case FeedType.selfImprovement:
        return Icons.self_improvement_rounded;
      case FeedType.series:
        return Icons.tv_rounded;
      case FeedType.sports:
        return Icons.sports_rounded;
      case FeedType.technology:
        return Icons.computer_rounded;
      case FeedType.travel:
        return Icons.airplanemode_active_rounded;
      case FeedType.tv:
        return Icons.tv_rounded;
      case FeedType.university:
        return Icons.school_rounded;
      case FeedType.vegetarian:
        return Icons.eco_rounded;
      case FeedType.wellness:
        return Icons.self_improvement_rounded;
      case FeedType.writing:
        return Icons.edit_rounded;
      case FeedType.yoga:
        return Icons.self_improvement_rounded;
      case FeedType.business:
        return Icons.business_rounded;
      case FeedType.cooking:
        return Icons.restaurant_rounded;
      case FeedType.diY:
        return Icons.build_rounded;
      case FeedType.economics:
        return Icons.monetization_on_rounded;
      case FeedType.education:
        return Icons.school_rounded;
      case FeedType.entertainment:
        return Icons.movie_rounded;
      case FeedType.entrepreneurship:
        return Icons.business_rounded;
      case FeedType.gardening:
        return Icons.eco_rounded;
      case FeedType.health:
        return Icons.self_improvement_rounded;
      case FeedType.investing:
        return Icons.monetization_on_rounded;
      case FeedType.journalism:
        return Icons.article_rounded;
      case FeedType.kids:
        return Icons.child_care_rounded;
      case FeedType.literature:
        return Icons.book_rounded;
      case FeedType.urbanExploration:
        return Icons.outdoor_grill_rounded;
      case FeedType.virtualReality:
        return Icons.vrpano_rounded;
      case FeedType.zoology:
        return Icons.eco_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
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
