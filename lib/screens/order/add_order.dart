import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../cubit/order_cubit/order_cubit.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({Key? key}) : super(key: key);

  @override
  State<AddOrderPage> createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State<AddOrderPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Order')),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          final orderCubit = context.read<OrderCubit>();

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Customer Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () async {
                      final refNumber =
                      await orderCubit.generateOrderRefNumber();
                      await orderCubit.addOrder(
                        refNumber: refNumber,
                        email: emailController.text,
                        phone: phoneController.text,
                        name: nameController.text,
                        description: descriptionController.text,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    child: state.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Add Order'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}