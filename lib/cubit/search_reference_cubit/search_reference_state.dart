import 'package:studioh_ceramic_cafe_client/model/orders.dart';

class SearchState {
  final OrderModel? foundOrder;
  final bool isLoading;
  final int step; // 1: search, 2: result
  final String errorMessage;

  const SearchState({
    this.foundOrder,
    this.isLoading = false,
    this.step = 1,
    this.errorMessage = '',
  });

  SearchState copyWith({
    OrderModel? foundOrder,
    bool? isLoading,
    int? step,
    String? errorMessage,
  }) {
    return SearchState(
      foundOrder: foundOrder ?? this.foundOrder,
      isLoading: isLoading ?? this.isLoading,
      step: step ?? this.step,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SearchState &&
              runtimeType == other.runtimeType &&
              foundOrder == other.foundOrder &&
              isLoading == other.isLoading &&
              step == other.step &&
              errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      foundOrder.hashCode ^
      isLoading.hashCode ^
      step.hashCode ^
      errorMessage.hashCode;
}
