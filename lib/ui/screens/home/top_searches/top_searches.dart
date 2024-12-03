import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_mama/models/publication_model.dart';
import 'package:safe_mama/ui/elements/empty_view_element.dart';
import 'package:safe_mama/ui/elements/error_view_element.dart';
import 'package:safe_mama/ui/elements/listItems/publication_item.dart';
import 'package:safe_mama/ui/elements/loading_view.dart';
import 'package:safe_mama/ui/screens/home/top_searches/top_searches_view_model.dart';
import 'package:safe_mama/ui/screens/publication/detail/publication_detail_view_model.dart';
import 'package:safe_mama/utils/navigation/route_names.dart';
import 'package:provider/provider.dart';

class TopSearches extends StatefulWidget {
  const TopSearches({super.key});

  @override
  State<TopSearches> createState() => _TopSearchesState();
}

class _TopSearchesState extends State<TopSearches> {
  late TopSearchesViewModel viewModel;
  late Future? myFuture;
  List<PublicationModel> _searches = [];
  int errorType = 2;
  String errorMessage = '';

  @override
  void initState() {
    viewModel = Provider.of<TopSearchesViewModel>(context, listen: false);
    myFuture = _fetchItems();
    super.initState();
  }

  _fetchItems() async {
    TopPublicationState state = await viewModel.fetchTopPublications();
    if (state.isSuccess) {
      setState(() {
        _searches = state.publications;
      });
    } else {
      setState(() {
        errorType = state.errorType;
        errorMessage = state.errorMessage;
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
            return _searches.isEmpty
                ? Builder(builder: (context) {
                    return errorMessage.isNotEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ErrorViewElement(
                                  errorType: errorType,
                                  retry: () {
                                    setState(() {
                                      myFuture = _fetchItems();
                                    });
                                  }),
                            ],
                          )
                        : const EmptyViewElement();
                  })
                : ListView.builder(
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: _searches.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = _searches[index];

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
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ErrorViewElement(
                    errorType: errorType, retry: () => _fetchItems()),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
