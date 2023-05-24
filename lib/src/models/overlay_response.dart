class OverlayResponse<T> {
  /// Indicates if a show confirmation call has been confirmed or rejected.
  /// null will be returned when it's not a confirmation dialog.
  final bool confirmed;

  /// A place to put any response data from dialogs that may contain text fields
  /// or multi selection options
  final dynamic responseData;

  /// A place to put any response data from dialogs that may contain text fields
  /// or multi selection options
  final T? data;

  OverlayResponse({
    this.confirmed = false,
    @Deprecated('Prefer to use `data` and pass in a generic type.')
    this.responseData,
    this.data,
  });
}

/// The response returned from awaiting a call on the [DialogService]
class DialogResponse<T> extends OverlayResponse<T> {
  DialogResponse({
    bool confirmed = false,
    @Deprecated(
        'Prefer to use `data` and pass in a generic type. ResponseData has no effect anymore')
    dynamic responseData,
    T? data,
  }) : super(
          confirmed: confirmed,
          data: data,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DialogResponse<T> &&
          runtimeType == other.runtimeType &&
          confirmed == other.confirmed &&
          data == data;

  @override
  int get hashCode => Object.hash(confirmed, data);
}

/// The response returned from awaiting a call on the [BottomSheetService]
class SheetResponse<T> extends OverlayResponse<T> {
  SheetResponse({
    bool confirmed = false,
    @Deprecated(
        'Prefer to use `data` and pass in a generic type.  ResponseData has no effect anymore')
    dynamic responseData,
    T? data,
  }) : super(
          confirmed: confirmed,
          data: data,
        );
}
