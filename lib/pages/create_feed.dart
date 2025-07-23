import 'package:hoot/app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
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
        ToastService.showToast(context, 'somethingWentWrong'.tr, true);
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
        ToastService.showToast(context, 'somethingWentWrong'.tr, true);
      });
    }
  }

  Future _deleteFeed() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteFeed'.tr),
        content: Text('deleteFeedConfirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('deleteFeed'.tr),
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
          ToastService.showToast(context, 'somethingWentWrong'.tr, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(!_editing ? 'createFeed'.tr : 'editFeed'.tr),
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
                  labelText: 'title'.tr,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLength: 280,
                maxLines: 5,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'description'.tr,
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
                            Text('general'.tr),
                          ] else if (feedType == FeedType.activism) ...[
                            const LineIcon(LineIcons.helpingHands),
                            const SizedBox(width: 8),
                            Text('activism'.tr),
                          ] else if (feedType == FeedType.activities) ...[
                            const LineIcon(LineIcons.walking),
                            const SizedBox(width: 8),
                            Text('activities'.tr),
                          ] else if (feedType == FeedType.adultContent) ...[
                            const LineIcon(LineIcons.exclamationTriangle),
                            const SizedBox(width: 8),
                            Text('adultContent'.tr),
                          ] else if (feedType == FeedType.art) ...[
                            const LineIcon(LineIcons.paintBrush),
                            const SizedBox(width: 8),
                            Text('art'.tr),
                          ] else if (feedType == FeedType.beauty) ...[
                            const LineIcon(LineIcons.female),
                            const SizedBox(width: 8),
                            Text('beauty'.tr),
                          ] else if (feedType == FeedType.celebrities) ...[
                            const LineIcon(LineIcons.star),
                            const SizedBox(width: 8),
                            Text('celebrities'.tr),
                          ] else if (feedType == FeedType.comedy) ...[
                            const LineIcon(LineIcons.laughFaceWithBeamingEyes),
                            const SizedBox(width: 8),
                            Text('comedy'.tr),
                          ] else if (feedType == FeedType.design) ...[
                            const LineIcon(LineIcons.paintRoller),
                            const SizedBox(width: 8),
                            Text('design'.tr),
                          ] else if (feedType == FeedType.environment) ...[
                            const LineIcon(LineIcons.leaf),
                            const SizedBox(width: 8),
                            Text('environment'.tr),
                          ] else if (feedType == FeedType.family) ...[
                            const LineIcon(LineIcons.home),
                            const SizedBox(width: 8),
                            Text('family'.tr),
                          ] else if (feedType == FeedType.fitness) ...[
                            const LineIcon(LineIcons.dumbbell),
                            const SizedBox(width: 8),
                            Text('fitness'.tr),
                          ] else if (feedType == FeedType.gaming) ...[
                            const LineIcon(LineIcons.gamepad),
                            const SizedBox(width: 8),
                            Text('gaming'.tr),
                          ] else if (feedType == FeedType.history) ...[
                            const LineIcon(LineIcons.landmark),
                            const SizedBox(width: 8),
                            Text('history'.tr),
                          ] else if (feedType == FeedType.inspiration) ...[
                            const LineIcon(LineIcons.feather),
                            const SizedBox(width: 8),
                            Text('inspiration'.tr),
                          ] else if (feedType == FeedType.jobs) ...[
                            const LineIcon(LineIcons.briefcase),
                            const SizedBox(width: 8),
                            Text('jobs'.tr),
                          ] else if (feedType == FeedType.lgbtQ) ...[
                            const LineIcon(LineIcons.venusMars),
                            const SizedBox(width: 8),
                            Text('lgbtQ'.tr),
                          ] else if (feedType == FeedType.marketing) ...[
                            const LineIcon(LineIcons.bullhorn),
                            const SizedBox(width: 8),
                            Text('marketing'.tr),
                          ] else if (feedType == FeedType.movies) ...[
                            const LineIcon(LineIcons.film),
                            const SizedBox(width: 8),
                            Text('movies'.tr),
                          ] else if (feedType == FeedType.music) ...[
                            const LineIcon(LineIcons.music),
                            const SizedBox(width: 8),
                            Text('music'.tr),
                          ] else if (feedType == FeedType.nature) ...[
                            const LineIcon(LineIcons.leaf),
                            const SizedBox(width: 8),
                            Text('nature'.tr),
                          ] else if (feedType == FeedType.news) ...[
                            const LineIcon(LineIcons.newspaper),
                            const SizedBox(width: 8),
                            Text('news'.tr),
                          ] else if (feedType == FeedType.onlineCourses) ...[
                            const LineIcon(LineIcons.graduationCap),
                            const SizedBox(width: 8),
                            Text('onlineCourses'.tr),
                          ] else if (feedType == FeedType.outdoors) ...[
                            const LineIcon(LineIcons.tree),
                            const SizedBox(width: 8),
                            Text('outdoors'.tr),
                          ] else if (feedType == FeedType.parenting) ...[
                            const LineIcon(LineIcons.baby),
                            const SizedBox(width: 8),
                            Text('parenting'.tr),
                          ] else if (feedType == FeedType.pets) ...[
                            const LineIcon(LineIcons.dog),
                            const SizedBox(width: 8),
                            Text('pets'.tr),
                          ] else if (feedType == FeedType.photography) ...[
                            const LineIcon(LineIcons.camera),
                            const SizedBox(width: 8),
                            Text('photography'.tr),
                          ] else if (feedType == FeedType.quotes) ...[
                            const LineIcon(LineIcons.quoteLeft),
                            const SizedBox(width: 8),
                            Text('quotes'.tr),
                          ] else if (feedType == FeedType.relationships) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text('relationships'.tr),
                          ] else if (feedType == FeedType.recipes) ...[
                            const LineIcon(LineIcons.utensils),
                            const SizedBox(width: 8),
                            Text('recipes'.tr),
                          ] else if (feedType == FeedType.religion) ...[
                            const LineIcon(LineIcons.pray),
                            const SizedBox(width: 8),
                            Text('religion'.tr),
                          ] else if (feedType == FeedType.school) ...[
                            const LineIcon(LineIcons.school),
                            const SizedBox(width: 8),
                            Text('school'.tr),
                          ] else if (feedType == FeedType.science) ...[
                            const LineIcon(LineIcons.microscope),
                            const SizedBox(width: 8),
                            Text('science'.tr),
                          ] else if (feedType == FeedType.selfImprovement) ...[
                            const LineIcon(LineIcons.lightbulb),
                            const SizedBox(width: 8),
                            Text('selfImprovement'.tr),
                          ] else if (feedType == FeedType.series) ...[
                            const LineIcon(LineIcons.television),
                            const SizedBox(width: 8),
                            Text('series'.tr),
                          ] else if (feedType == FeedType.sports) ...[
                            const LineIcon(LineIcons.footballBall),
                            const SizedBox(width: 8),
                            Text('sports'.tr),
                          ] else if (feedType == FeedType.technology) ...[
                            const LineIcon(LineIcons.mobilePhone),
                            const SizedBox(width: 8),
                            Text('technology'.tr),
                          ] else if (feedType == FeedType.travel) ...[
                            const LineIcon(LineIcons.plane),
                            const SizedBox(width: 8),
                            Text('travel'.tr),
                          ] else if (feedType == FeedType.tv) ...[
                            const LineIcon(LineIcons.television),
                            const SizedBox(width: 8),
                            Text('tv'.tr),
                          ] else if (feedType == FeedType.university) ...[
                            const LineIcon(LineIcons.graduationCap),
                            const SizedBox(width: 8),
                            Text('university'.tr),
                          ] else if (feedType == FeedType.vegetarian) ...[
                            const LineIcon(LineIcons.leaf),
                            const SizedBox(width: 8),
                            Text('vegetarian'.tr),
                          ] else if (feedType == FeedType.wellness) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text('wellness'.tr),
                          ] else if (feedType == FeedType.writing) ...[
                            const LineIcon(LineIcons.pen),
                            const SizedBox(width: 8),
                            Text('writing'.tr),
                          ] else if (feedType == FeedType.yoga) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text('yoga'.tr),
                          ] else if (feedType == FeedType.business) ...[
                            const LineIcon(LineIcons.briefcase),
                            const SizedBox(width: 8),
                            Text('business'.tr),
                          ] else if (feedType == FeedType.cooking) ...[
                            const LineIcon(LineIcons.pizzaSlice),
                            const SizedBox(width: 8),
                            Text('cooking'.tr),
                          ] else if (feedType == FeedType.diY) ...[
                            const LineIcon(LineIcons.toolbox),
                            const SizedBox(width: 8),
                            Text('diY'.tr),
                          ] else if (feedType == FeedType.economics) ...[
                            const LineIcon(LineIcons.lineChart),
                            const SizedBox(width: 8),
                            Text('economics'.tr),
                          ] else if (feedType == FeedType.education) ...[
                            const LineIcon(LineIcons.graduationCap),
                            const SizedBox(width: 8),
                            Text('education'.tr),
                          ] else if (feedType == FeedType.entertainment) ...[
                            const LineIcon(LineIcons.star),
                            const SizedBox(width: 8),
                            Text('entertainment'.tr),
                          ] else if (feedType == FeedType.entrepreneurship) ...[
                            const LineIcon(LineIcons.barChartAlt),
                            const SizedBox(width: 8),
                            Text('entrepreneurship'.tr),
                          ] else if (feedType == FeedType.gardening) ...[
                            const LineIcon(LineIcons.tree),
                            const SizedBox(width: 8),
                            Text('gardening'.tr),
                          ] else if (feedType == FeedType.health) ...[
                            const LineIcon(LineIcons.heart),
                            const SizedBox(width: 8),
                            Text('health'.tr),
                          ] else if (feedType == FeedType.investing) ...[
                            const LineIcon(LineIcons.pieChart),
                            const SizedBox(width: 8),
                            Text('investing'.tr),
                          ] else if (feedType == FeedType.journalism) ...[
                            const LineIcon(LineIcons.newspaper),
                            const SizedBox(width: 8),
                            Text('journalism'.tr),
                          ] else if (feedType == FeedType.kids) ...[
                            const LineIcon(LineIcons.child),
                            const SizedBox(width: 8),
                            Text('kids'.tr),
                          ] else if (feedType == FeedType.literature) ...[
                            const LineIcon(LineIcons.book),
                            const SizedBox(width: 8),
                            Text('literature'.tr),
                          ] else if (feedType == FeedType.urbanExploration) ...[
                            const LineIcon(LineIcons.city),
                            const SizedBox(width: 8),
                            Text('urbanExploration'.tr),
                          ] else if (feedType == FeedType.virtualReality) ...[
                            const LineIcon(LineIcons.cardboardVr),
                            const SizedBox(width: 8),
                            Text('virtualReality'.tr),
                          ] else if (feedType == FeedType.zoology) ...[
                            const LineIcon(LineIcons.paw),
                            const SizedBox(width: 8),
                            Text('zoology'.tr),
                          ] else if (feedType == FeedType.other) ...[
                            const LineIcon(LineIcons.questionCircle),
                            const SizedBox(width: 8),
                            Text('other'.tr),
                          ] else ...[
                            const LineIcon(LineIcons.questionCircle),
                            const SizedBox(width: 8),
                            Text('general'.tr),
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
                  Text('privateFeed'.tr),
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
                  Text('nsfwFeed'.tr),
                  const SizedBox(width: 8),
                  _nsfw || _feedType == FeedType.adultContent ? const LineIcon(LineIcons.exclamationTriangle) : const LineIcon(LineIcons.sun),
                ],
              ),
              const SizedBox(height: 26),
              !_editing ? ElevatedButton(
                onPressed: _isValid() ? _createFeed : null,
                child: Text('createFeed'.tr),
              ) : ElevatedButton(
                onPressed: _isValid() ? _editFeed : null,
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                  backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondary),
                  foregroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onSecondary),
                ),
                child: Text('editFeed'.tr),
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
                    child: Text('deleteFeed'.tr),
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
