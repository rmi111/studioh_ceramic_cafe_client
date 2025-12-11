part of 'order_cubit.dart';

class OrderState {
  final List<OrderModel> orders;
  final List<OrderModel> activeOrders;
  final List<OrderModel> preparedOrders;
  final List<OrderModel> unCollectedOrders;
  final List<OrderModel> collectedOrders;
  final List<File> capturedImages;
  final bool isLoading;
  final int selectedTab;

  const OrderState({
    this.orders = const [],
    this.activeOrders = const [],
    this.preparedOrders = const [],
    this.unCollectedOrders = const [],
    this.collectedOrders = const [],
    this.capturedImages = const [],
    this.isLoading = false,
    this.selectedTab = 0,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? activeOrders,
    List<OrderModel>? preparedOrders,
    List<OrderModel>? unCollectedOrders,
    List<OrderModel>? collectedOrders,
    List<File>? capturedImages,
    bool? isLoading,
    int? selectedTab,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      activeOrders: activeOrders ?? this.activeOrders,
      preparedOrders: preparedOrders ?? this.preparedOrders,
      unCollectedOrders: unCollectedOrders ?? this.unCollectedOrders,
      collectedOrders: collectedOrders ?? this.collectedOrders,
      capturedImages: capturedImages ?? this.capturedImages,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrderState &&
              runtimeType == other.runtimeType &&
              orders == other.orders &&
              activeOrders == other.activeOrders &&
              preparedOrders == other.preparedOrders &&
              unCollectedOrders == other.unCollectedOrders &&
              collectedOrders == other.collectedOrders &&
              capturedImages == other.capturedImages &&
              isLoading == other.isLoading &&
              selectedTab == other.selectedTab;

  @override
  int get hashCode =>
      orders.hashCode ^
      activeOrders.hashCode ^
      preparedOrders.hashCode ^
      unCollectedOrders.hashCode ^
      collectedOrders.hashCode ^
      capturedImages.hashCode ^
      isLoading.hashCode ^
      selectedTab.hashCode;
}