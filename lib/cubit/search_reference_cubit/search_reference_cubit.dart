import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/cubit/search_reference_cubit/search_reference_state.dart';
import 'package:studioh_ceramic_cafe_client/model/orders.dart';
import 'package:studioh_ceramic_cafe_client/services/api_service.dart';

class SearchViaCubit extends Cubit<SearchState> {
  SearchViaCubit()
      : super(const SearchState(
          foundOrder: null,
          isLoading: false,
          step: 1,
          errorMessage: '',
        ));

  Future<void> searchOrderByRef(String refNumber) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));

    try {
      final ref = refNumber.trim();

      final response = await ApiService.searchOrderByRef(ref);
      final data = response.data;

      var orderData = data['data'] ?? data;
      if (orderData is Map && orderData.containsKey('data')) {
        orderData = orderData['data'];
      }
      if (orderData is Map && orderData.containsKey('order')) {
        orderData = orderData['order'];
      }

      OrderModel? order;

      if (orderData is List && orderData.isNotEmpty) {
        order = OrderModel.fromJson(Map<String, dynamic>.from(orderData.first as Map));
      } else if (orderData is Map) {
        order = OrderModel.fromJson(Map<String, dynamic>.from(orderData));
      }

      if (order != null) {
        print('Found Order: ${order.refNumber}');
        emit(state.copyWith(
          foundOrder: order,
          step: 2,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          foundOrder: null,
          errorMessage: 'No order found with reference: $ref',
          isLoading: false,
        ));
      }
    } catch (e) {
      print('Error searching order: $e');
      emit(state.copyWith(
        foundOrder: null,
        errorMessage: 'Error: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  void resetSearch() {
    emit(const SearchState(
      foundOrder: null,
      isLoading: false,
      step: 1,
      errorMessage: '',
    ));
  }

  void goBack() {
    emit(state.copyWith(step: 1, foundOrder: null));
  }
}