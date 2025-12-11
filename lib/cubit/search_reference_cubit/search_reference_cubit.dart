import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studioh_ceramic_cafe_client/cubit/search_reference_cubit/search_reference_state.dart';

import 'package:studioh_ceramic_cafe_client/model/orders.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/firebase_collection_name.dart';

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
      final fullRef = 'cc$ref'; // Assuming prefix is 'cc'

      final snapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.ORDERS)
          .where('refNumber', isEqualTo: fullRef)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final order = OrderModel.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );

        print('Found Order: ${order.refNumber}');
        print('Customer: ${order.users[0].email}');

        emit(state.copyWith(
          foundOrder: order,
          step: 2,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          foundOrder: null,
          errorMessage:
          'No order found with this reference number: $fullRef',
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