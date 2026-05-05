import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:studioh_ceramic_cafe_client/utils/widget/info_label.dart';
import 'package:studioh_ceramic_cafe_client/utils/widget/snacke_bar.dart';

import '../../cubit/order_cubit/order_cubit.dart';
import '../../cubit/search_reference_cubit/search_reference_cubit.dart';
import '../../cubit/search_reference_cubit/search_reference_state.dart';
import '../../model/orders.dart';
import '../../utils/widget/app_text_field.dart';
import '../../utils/widget/custom_appbar.dart';
import '../../utils/widget/custom_btn.dart';
import '../../utils/widget/custom_text.dart';
import 'order_details_page.dart';

class SearchViaReferenceId extends StatefulWidget {
  const SearchViaReferenceId({Key? key}) : super(key: key);

  @override
  State<SearchViaReferenceId> createState() => _SearchViaReferenceIdState();
}

class _SearchViaReferenceIdState extends State<SearchViaReferenceId> {
  late TextEditingController refController;

  @override
  void initState() {
    super.initState();
    refController = TextEditingController();
  }

  @override
  void dispose() {
    refController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchViaCubit(),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<SearchViaCubit, SearchState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: state.step == 1
                      ? _buildSearchStep(context)
                      : state.step == 2 && state.foundOrder != null
                      ? _buildResultStep(context, state)
                      : const SizedBox(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DefaultAppBar(title: 'Search via reference'),
        const SizedBox(height: 16),
        BlocBuilder<SearchViaCubit, SearchState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: AppTextField(
                        controller: refController,
                        keyboardType: TextInputType.text,
                        label: 'Reference Number',
                        isEnabled: !state.isLoading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                if (refController.text.isEmpty) {
                                  AppSnackbar.showError(context,
                                    'Empty Field \nPlease enter a reference number',
                                  );
                                  return;
                                }
                                context.read<SearchViaCubit>().searchOrderByRef(
                                  refController.text,
                                );
                              },
                        icon: state.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.search),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.errorMessage,
                      style: TextStyle(color: Colors.red[800], fontSize: 14),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultStep(BuildContext context, SearchState state) {
    final foundOrder = state.foundOrder!;

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                text: 'Order Info',
                fontWeight: FontWeight.bold,
                fontSizeFactor: 1.2,
              ),
              IconButton(
                onPressed: () {
                  context.read<SearchViaCubit>().goBack();
                  refController.clear();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.center,
            child:
                foundOrder.imgUrl.isNotEmpty &&
                    foundOrder.imgUrl[foundOrder.imgUrl.length - 1].isNotEmpty
                ? OrderImageSlider(
                    imgUrls: foundOrder.imgUrl,
                    initialIndex: foundOrder.imgUrl.length - 1,
                  )
                : Container(
                    margin: const EdgeInsets.all(5),
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey[200],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/no-image-icon-4.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          InfoLabel(label: 'Customer Name', value: foundOrder.users.isNotEmpty ? foundOrder.users[0].name : 'N/A'),
          const SizedBox(height: 12),
          InfoLabel(label: 'Email', value: foundOrder.users.isNotEmpty ? foundOrder.users[0].email : 'N/A'),
          const SizedBox(height: 12),
          InfoLabel(
            label: 'Phone',
            value: foundOrder.users.isNotEmpty && foundOrder.users[0].phoneNumber != null ? foundOrder.users[0].phoneNumber! : 'Not provided',
          ),
          const SizedBox(height: 12),
          InfoLabel(label: 'Description', value: foundOrder.description),
          const SizedBox(height: 12),
          InfoLabel(
            label: 'Status',
            value: foundOrder.status.toUpperCase() ?? foundOrder.status,
          ),
          const SizedBox(height: 24),
          BlocBuilder<SearchViaCubit, SearchState>(
            builder: (context, state) {
              return CustomButton(
                text: "Add to Profile",
                onPressed: state.isLoading
                    ? () {}
                    : () {
                        _showConfirmDialog(context, foundOrder);
                      },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add Order to Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to add this order to your profile?',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ref: ${order.refNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _addOrderToProfile(context, order);
                AppSnackbar.show(context, "Added Successfully");
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addOrderToProfile(
    BuildContext context,
    OrderModel order,
  ) async {
    try {
      await context.read<OrderCubit>().addOrUpdateUserToOrder(
        context: context,
        order: order,
        navigateToTracking: true,
      );
    } catch (e) {
     AppSnackbar.showError(context, 'Error: $e');
    }
  }
}
