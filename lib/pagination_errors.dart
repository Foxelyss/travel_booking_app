import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomFirstPageError extends StatelessWidget {
  const CustomFirstPageError({
    super.key,
    required this.pagingController,
  });

  final PagingController<Object, Object> pagingController;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Что-то пошло не так',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state.error != null) ...[
              const SizedBox(
                height: 16,
              ),
              Text(
                state.error.toString().substring(11),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(
              height: 48,
            ),
            SizedBox(
              width: 250,
              child: ElevatedButton.icon(
                onPressed: pagingController.refresh,
                icon: const Icon(CupertinoIcons.refresh),
                label: const Text(
                  'Попробовать ещё',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNewPageError extends StatelessWidget {
  const CustomNewPageError({
    super.key,
    required this.pagingController,
  });

  final PagingController<Object, Object> pagingController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: pagingController.fetchNextPage,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Повторить попытку загрузки страницы?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Icon(
              Icons.refresh,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
