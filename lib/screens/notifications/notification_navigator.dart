import 'package:flutter/material.dart';
import 'package:studioh_ceramic_cafe_client/model/app_notification.dart';
import 'package:studioh_ceramic_cafe_client/model/orders.dart';
import 'package:studioh_ceramic_cafe_client/model/voucher.dart';
import 'package:studioh_ceramic_cafe_client/screens/order/order_details_page.dart';
import 'package:studioh_ceramic_cafe_client/screens/voucher/voucher_details.dart';
import 'package:studioh_ceramic_cafe_client/services/api_service.dart';
import 'package:studioh_ceramic_cafe_client/utils/constant/app_colors.dart';

/// Opens the page a notification refers to.
///
/// The detail screens take full models rather than ids, so the record is
/// fetched first. A blocking spinner is shown while that happens; anything that
/// fails surfaces as a snackbar rather than a dead tap.
class NotificationNavigator {
  static Future<void> open(
    BuildContext context,
    AppNotification notification,
  ) async {
    final type = notification.shortType;

    if (type.startsWith('Order')) {
      await _openOrder(context, notification);
    } else if (type.startsWith('Voucher')) {
      await _openVoucher(context, notification);
    } else if (type.startsWith('Message')) {
      _showMessage(context, notification);
    }
    // Anything else has no destination yet — tapping still marks it read.
  }

  static Future<void> _openOrder(
    BuildContext context,
    AppNotification notification,
  ) async {
    final ref = notification.refNumber;
    if (ref == null || ref.isEmpty) return;

    final order = await _withSpinner<OrderModel?>(context, () async {
      final response = await ApiService.showOrder(ref);
      final data = response.data['data']?['order'];
      if (data is! Map) return null;
      return OrderModel.fromJson(data.cast<String, dynamic>());
    });

    if (!context.mounted) return;

    if (order == null) {
      _toast(context, 'Could not open order $ref.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
    );
  }

  static Future<void> _openVoucher(
    BuildContext context,
    AppNotification notification,
  ) async {
    final code = notification.voucherCode;
    if (code == null || code.isEmpty) return;

    final voucher = await _withSpinner<Voucher?>(context, () async {
      final response = await ApiService.showVoucher(code);
      final data = response.data['data']?['voucher'];
      if (data is! Map) return null;
      return Voucher.fromJson(data.cast<String, dynamic>());
    });

    if (!context.mounted) return;

    if (voucher == null) {
      _toast(context, 'This voucher is no longer available.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VoucherDetailsScreen(voucher: voucher)),
    );
  }

  /// Messages have no detail screen yet, so show the full text and banner in a
  /// sheet rather than truncating them in the list.
  static void _showMessage(
    BuildContext context,
    AppNotification notification,
  ) {
    final imageUrl = notification.data['image_url']?.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // A broken banner should not blank the whole sheet.
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const SizedBox(
                              height: 140,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  notification.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.body,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Runs [action] behind a modal spinner, always dismissing it.
  static Future<T?> _withSpinner<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      return await action();
    } catch (_) {
      return null;
    } finally {
      if (context.mounted) Navigator.pop(context);
    }
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
