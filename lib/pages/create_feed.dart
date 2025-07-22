import 'package:hoot/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/models/feed_types.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/app/controllers/feed_controller.dart';

class CreateFeedPage extends StatefulWidget {
  final Feed? feed;
  const CreateFeedPage({super.key, this.feed});

  @override
  State<CreateFeedPage> createState() => _CreateFeedPageState();
}

class _CreateFeedPageState extends State<CreateFeedPage> {
  late FeedController _feedProvider;
  bool _editing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Color _color = Colors.blue;
  bool _private = false;
  bool _nsfw = false;
  bool _isLoading = false;
FeedType _feedType = FeedType.general;

  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    _titleController.text = widget.feed?.title ?? '';
    _descriptionController.text = widget.feed?.description ?? '';
    _color = widget.feed?.color ?? Colors.blue;
    _private = widget.feed?.private ?? false;
    _nsfw = widget.feed?.nsfw ?? false;
    _feedType = widget.feed?.type ?? FeedType.general;
    _editing = widget.feed != null;
    super.initState();
  }

  bool _isValid() => _titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty;

  Future _createFeed() async {
    if (!_isValid()) {
      ToastService.showToast(context, "Make sure you fill the title and description fields", true);
      return;
    }
    setState(() => _isLoading = true);
    String feedId = await _feedProvider.createFeed(
        context,
        title: _titleController.text,
        description: _descriptionController.text,
        icon: 'https://picsum.photos/seed/${_titleController.text}/200/300',
        color: _color,
        type: _feedType,
        private: _private,
        nsfw: _nsfw || _feedType == FeedType.adultContent,
    );
    if (feedId.isNotEmpty) {
      Get.back();
    } else {
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
      });
    }
  }

  Future _editFeed() async {
    if (!_isValid()) return;
    setState(() => _isLoading = true);
    widget.feed?.title = _titleController.text;
    widget.feed?.description = _descriptionController.text;
    widget.feed?.color = _color;
    widget.feed?.type = _feedType;
    widget.feed?.private = _private;
    widget.feed?.nsfw = _nsfw;
    bool res = await _feedProvider.editFeed(
        context,
        widget.feed!
    );
    if (res) {
      Get.back();
    } else {
      setState(() {
        _isLoading = false;
        ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
      });
    }
  }

  Future _deleteFeed() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteFeed),
        content: Text(AppLocalizations.of(context)!.deleteFeedConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.deleteFeed),
          ),
        ],
      ),
    );

    if(confirm) {
      setState(() => _isLoading = true);
      bool res = await _feedProvider.deleteFeed(
          context,
          widget.feed?.id ?? ''
      );
      if (res) {
        Get.back();
      } else {
        setState(() {
          _isLoading = false;
          ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(!_editing ? AppLocalizations.of(context)!.createFeed : AppLocalizations.of(context)!.editFeed),
        ),
        body: _isLoading ? const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                maxLength: 20,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLength: 280,
                maxLines: 5,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.description,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton(
                isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(10),
                  value: _feedType,
                  items: FeedType.values.map((FeedType feedType) {
                    return DropdownMenuItem(
                      value: feedType,
                      child: Row(
                        children: [
                          if (feedType == FeedType.general) ...[
                            const LineIcon(LineIcons.globe),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.general),
                          ] else if (feedType == FeedType.activism) ...[
                            const LineIcon(LineIcons.helpingHands),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.activism),
                          ] else if (feedType == FeedType.activities) ...[
                            const LineIcon(LineIcons.walking),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.activities),
                          ] else if (feedType == FeedType.adultContent) ...[
                            const LineIcon(LineIcons.exclamationTriangle),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.adultContent),
                          ] else if (feedType == FeedType.art) ...[
                            const LineIcon(LineIcons.paintBrush),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.art),
                          ] else if (feedType == FeedType.beauty) ...[
                            const LineIcon(LineIcons.female),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.beauty),
                          ] else if (feedType == FeedType.celebrities) ...[
                            const LineIcon(LineIcons.star),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.celebrities),
                          ] else if (feedType == FeedType.comedy) ...[
                            const LineIcon(LineIcons.laughFaceWithBeamingEyes),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.comedy),
                          ] else if (feedType == FeedType.design) ...[
                            const LineIcon(LineIcons.paintRoller),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.design),
                          ] else if (feedType == FeedType.environment) ...[
                            const LineIcon(LineIcons.leaf),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.environment),
                          ] else if (feedType == FeedType.family) ...[
                            const LineIcon(LineIcons.home),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.family),
                          ] else if (feedType == FeedType.fitness) ...[
                            const LineIcon(LineIcons.dumbbell),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.fitness),
                          ] else if (feedType == FeedType.gaming) ...[
                            const LineIcon(LineIcons.gamepad),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.gaming),
                          ] else if (feedType == FeedType.history) ...[
                            const LineIcon(LineIcons.landmark),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.history),
                          ] else if (feedType == FeedType.inspiration) ...[
                            const LineIcon(LineIcons.feather),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.inspiration),
                          ] else if (feedType == FeedType.jobs) ...[
                            const LineIcon(LineIcons.briefcase),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.jobs),
                          ] else if (feedType == FeedType.lgbtQ) ...[
                            const LineIcon(LineIcons.venusMars),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.lgbtQ),
                          ] else if (feedType == FeedType.marketing) ...[
                            const LineIcon(LineIcons.bullhorn),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.marketing),
                          ] else if (feedType == FeedType.movies) ...[
                            const LineIcon(LineIcons.film),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.movies),
                          ] else if (feedType == FeedType.music) ...[
                            const LineIcon(LineIcons.music),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.music),
                          ] else if (feedType == FeedType.nature) ...[
                            const LineIcon(LineIcons.leaf),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.nature),
                          ] else if (feedType == FeedType.news) ...[
                            const LineIcon(LineIcons.newspaper),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.news),
                          ] else if (feedType == FeedType.onlineCourses) ...[
                            const LineIcon(LineIcons.graduationCap),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.onlineCourses),
                          ] else if (feedType == FeedType.outdoors) ...[
                            const LineIcon(LineIcons.tree),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.outdoors),
                          ] else if (feedType == FeedType.parenting) ...[
                            const LineIcon(LineIcons.baby),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.parenting),
                          ] else if (feedType == FeedType.pets) ...[
                            const LineIcon(LineIcons.dog),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.pets),
                          ] else if (feedType == FeedType.photography) ...[
                            const LineIcon(LineIcons.camera),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.photography),
                          ] else if (feedType == FeedType.quotes) ...[
                            const LineIcon(LineIcons.quoteLeft),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.quotes),
                          ] else if (feedType == FeedType.relationships) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.relationships),
                          ] else if (feedType == FeedType.recipes) ...[
                            const LineIcon(LineIcons.utensils),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.recipes),
                          ] else if (feedType == FeedType.religion) ...[
                            const LineIcon(LineIcons.pray),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.religion),
                          ] else if (feedType == FeedType.school) ...[
                            const LineIcon(LineIcons.school),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.school),
                          ] else if (feedType == FeedType.science) ...[
                            const LineIcon(LineIcons.microscope),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.science),
                          ] else if (feedType == FeedType.selfImprovement) ...[
                            const LineIcon(LineIcons.lightbulb),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.selfImprovement),
                          ] else if (feedType == FeedType.series) ...[
                            const LineIcon(LineIcons.television),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.series),
                          ] else if (feedType == FeedType.sports) ...[
                            const LineIcon(LineIcons.footballBall),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.sports),
                          ] else if (feedType == FeedType.technology) ...[
                            const LineIcon(LineIcons.mobilePhone),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.technology),
                          ] else if (feedType == FeedType.travel) ...[
                            const LineIcon(LineIcons.plane),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.travel),
                          ] else if (feedType == FeedType.tv) ...[
                            const LineIcon(LineIcons.television),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.tv),
                          ] else if (feedType == FeedType.university) ...[
                            const LineIcon(LineIcons.graduationCap),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.university),
                          ] else if (feedType == FeedType.vegetarian) ...[
                            const LineIcon(LineIcons.leaf),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.vegetarian),
                          ] else if (feedType == FeedType.wellness) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.wellness),
                          ] else if (feedType == FeedType.writing) ...[
                            const LineIcon(LineIcons.pen),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.writing),
                          ] else if (feedType == FeedType.yoga) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.yoga),
                          ] else if (feedType == FeedType.business) ...[
                            const LineIcon(LineIcons.briefcase),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.business),
                          ] else if (feedType == FeedType.cooking) ...[
                            const LineIcon(LineIcons.pizzaSlice),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.cooking),
                          ] else if (feedType == FeedType.diY) ...[
                            const LineIcon(LineIcons.toolbox),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.diY),
                          ] else if (feedType == FeedType.economics) ...[
                            const LineIcon(LineIcons.lineChart),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.economics),
                          ] else if (feedType == FeedType.education) ...[
                            const LineIcon(LineIcons.graduationCap),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.education),
                          ] else if (feedType == FeedType.entertainment) ...[
                            const LineIcon(LineIcons.star),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.entertainment),
                          ] else if (feedType == FeedType.entrepreneurship) ...[
                            const LineIcon(LineIcons.barChartAlt),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.entrepreneurship),
                          ] else if (feedType == FeedType.gardening) ...[
                            const LineIcon(LineIcons.tree),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.gardening),
                          ] else if (feedType == FeedType.health) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.health),
                          ] else if (feedType == FeedType.investing) ...[
                            const LineIcon(LineIcons.pieChart),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.investing),
                          ] else if (feedType == FeedType.journalism) ...[
                            const LineIcon(LineIcons.newspaper),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.journalism),
                          ] else if (feedType == FeedType.kids) ...[
                            const LineIcon(LineIcons.child),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.kids),
                          ] else if (feedType == FeedType.literature) ...[
                            const LineIcon(LineIcons.book),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.literature),
                          ] else if (feedType == FeedType.urbanExploration) ...[
                            const LineIcon(LineIcons.city),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.urbanExploration),
                          ] else if (feedType == FeedType.virtualReality) ...[
                            const LineIcon(LineIcons.cardboardVr),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.virtualReality),
                          ] else if (feedType == FeedType.zoology) ...[
                            const LineIcon(LineIcons.paw),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.zoology),
                          ] else if (feedType == FeedType.other) ...[
                            const LineIcon(LineIcons.questionCircle),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.other),
                          ] else ...[
                            const LineIcon(LineIcons.questionCircle),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.general),
                          ]
                        ],
                      ),
                    );

                  }).toList(),
                  onChanged: (value) => setState(() => _feedType = value as FeedType),
              ),
              ColorPicker(
                  onColorChanged: (Color color) => setState(() => this._color = color),
                  enableShadesSelection: false,
                  enableTonalPalette: false,
                  pickersEnabled: const <ColorPickerType, bool>{
                    ColorPickerType.primary: false,
                    ColorPickerType.accent: false,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                  color: _color
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 50,
                  width: 100,
                  child: Container(
                    color: _color,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Checkbox(
                    value: _private,
                    onChanged: (value) => setState(() => _private = value!),
                  ),
                  Text(AppLocalizations.of(context)!.privateFeed),
                  const SizedBox(width: 8),
                  _private ? const LineIcon(LineIcons.lock) : const LineIcon(LineIcons.lockOpen),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _nsfw || _feedType == FeedType.adultContent,
                    onChanged: (value) => setState(() => _nsfw = value!),
                  ),
                  Text(AppLocalizations.of(context)!.nsfwFeed),
                  const SizedBox(width: 8),
                  _nsfw || _feedType == FeedType.adultContent ? const LineIcon(LineIcons.exclamationTriangle) : const LineIcon(LineIcons.sun),
                ],
              ),
              const SizedBox(height: 26),
              !_editing ? ElevatedButton(
                onPressed: _isValid() ? _createFeed : null,
                child: Text(AppLocalizations.of(context)!.createFeed),
              ) : ElevatedButton(
                onPressed: _isValid() ? _editFeed : null,
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondary),
                ),
                child: Text(AppLocalizations.of(context)!.editFeed),
              ),
              _editing ? Column(
                children: [
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _deleteFeed,
                    style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    child: Text(AppLocalizations.of(context)!.deleteFeed),
                  )
                ],
              ) : const SizedBox(),
              const SizedBox(height: 26),
            ],
          ),
        )
    );
  }
}
