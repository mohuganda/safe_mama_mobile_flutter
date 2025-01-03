import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khub_mobile/ui/elements/empty_view_element.dart';
import 'package:khub_mobile/ui/elements/listItems/publication_item.dart';
import 'package:khub_mobile/models/publication_model.dart';
import 'package:khub_mobile/ui/elements/loading_view.dart';
import 'package:khub_mobile/ui/screens/home/recommended/recommended_publication_view_model.dart';
import 'package:khub_mobile/ui/screens/publication/detail/publication_detail_view_model.dart';
import 'package:khub_mobile/utils/l10n_extensions.dart';
import 'package:khub_mobile/utils/navigation/route_names.dart';
import 'package:provider/provider.dart';

class RecommendedPublications extends StatefulWidget {
  const RecommendedPublications({super.key});

  @override
  State<RecommendedPublications> createState() =>
      _RecommendedPublicationsState();
}

class _RecommendedPublicationsState extends State<RecommendedPublications> {
  late RecommendedPublicationViewModel viewModel;
  late Future? myFuture;
  List<PublicationModel> _recommended = [];

  @override
  void initState() {
    viewModel =
        Provider.of<RecommendedPublicationViewModel>(context, listen: false);
    myFuture = _fetchItems();
    super.initState();
  }

  _fetchItems() async {
    RecommendedPublicationState state =
        await viewModel.fetchPublications(isFeatured: true);
    if (state.isSuccess) {
      setState(() {
        _recommended = state.publications;
      });
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingView());
          } else if (snapshot.hasData) {
            return _recommended.isEmpty
                ? const EmptyViewElement()
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _recommended.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = _recommended[index];

                      return PublicationItem(
                        isVerticalItem: false,
                        model: item,
                        onClick: () {
                          Provider.of<PublicationDetailViewModel>(context,
                                  listen: false)
                              .setCurrentPublication(item);
                          context.pushNamed(publicationDetail, extra: item);
                        },
                      );
                    },
                  );
            // return const Text('Data has been got');
          } else if (snapshot.hasError) {
            return Text(context.localized.errorOccurred);
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
