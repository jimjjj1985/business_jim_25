import 'dart:async';

import 'package:flutter/material.dart';

typedef _OnSuccessFunction<T> = Widget? Function(BuildContext context, T? data);
typedef _OnErrorFunction = Widget Function(BuildContext context, Object? error);
typedef _OnWaitingFunction = Widget Function(BuildContext context);

class Observer<T> extends StatelessWidget {
  final Stream<T>? stream;

  final _OnSuccessFunction<T> onSuccess;
  final _OnWaitingFunction? onWaiting;
  final _OnErrorFunction? onError;

  const Observer({
    Key? key,
    required this.stream,
    required this.onSuccess,
    this.onWaiting,
    this.onError
  }) : super(key: key);

  Function get _defaultOnWaiting => (context) => const Center(child: CircularProgressIndicator());
  Function get _defaultOnError => (context, error) => Text(error);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<T> snapshot) {
        if (snapshot.hasError) {
          return (onError != null)
              ? onError!(context, snapshot.error)
              : _defaultOnError(context, snapshot.error);
        }

        if (snapshot.hasData) {
          T? data = snapshot.data;
          if (data == null) {
            return this._doOnWaiting(context)!;
          } else {
            return onSuccess(context, data)!;
          }
        } else {
          return this._doOnWaiting(context)!;
        }
      },
    );
  }

  Widget? _doOnWaiting(BuildContext context) => (onWaiting != null) ? onWaiting!(context) : _defaultOnWaiting(context);
}