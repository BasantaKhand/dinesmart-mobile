import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/no_internet_banner.dart';
import '../state/waiter_dashboard_state.dart';
import '../view_model/waiter_dashboard_view_model.dart';
import '../widgets/table_grid.dart';
import '../widgets/category_bar.dart';
import '../widgets/menu_item_grid.dart';
import '../widgets/bill_summary_sheet.dart';
import '../../../auth/presentation/widgets/user_profile_drop_down.dart';
import '../../domain/entities/menu_item_entity.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import 'package:shake/shake.dart';
import '../../../auth/presentation/view_model/auth_viewmodel.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import 'package:dinesmart_app/app/routes/app_routes.dart';

enum PriceSort { lowToHigh, highToLow }

final priceSortProvider = StateProvider<PriceSort?>((ref) => null);

class WaiterDashboardPage extends ConsumerStatefulWidget {
  const WaiterDashboardPage({super.key});

  @override
  ConsumerState<WaiterDashboardPage> createState() => _WaiterDashboardPageState();
}

class _WaiterDashboardPageState extends ConsumerState<WaiterDashboardPage> {
  WaiterDashboardStatus? _previousStatus;
  String? _previousErrorMessage;
  ShakeDetector? _shakeDetector;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (event) {
        _showLogoutDialog();
      },
      shakeThresholdGravity: 1.5,
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  Map<String, int> _categoryCountsById(List<MenuItemEntity> items) {
    final Map<String, int> counts = {};
    for (final i in items) {
      final String catId = i.categoryId;
      counts[catId] = (counts[catId] ?? 0) + 1;
    }
    return counts;
  }

  double _priceOf(MenuItemEntity item) {
    final p = item.price;
    if (p is int) return p.toDouble();
    return p;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(waiterDashboardViewModelProvider);

    // Show snackbar for errors that occur during operations
    if (state.status == WaiterDashboardStatus.error &&
        state.errorMessage != null &&
        (_previousStatus != WaiterDashboardStatus.error ||
            _previousErrorMessage != state.errorMessage)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackbarUtils.showError(context, state.errorMessage!);
      });
    }
    _previousStatus = state.status;
    _previousErrorMessage = state.errorMessage;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/logos/logo.png',
              height: 32,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.restaurant, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            const Text(
              'DineSmart',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          const NotificationBadge(),
          const UserProfileDropDown(),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WaiterDashboardState state,
  ) {
    if (state.status == WaiterDashboardStatus.loading && state.tables.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == WaiterDashboardStatus.error && state.tables.isEmpty) {
      return RefreshIndicator(
        color: Colors.orange,
        onRefresh: () async {
          await ref
              .read(waiterDashboardViewModelProvider.notifier)
              .initialize();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.errorMessage ?? "Failed to load dashboard"}',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(waiterDashboardViewModelProvider.notifier)
                          .initialize(),
                      child: const Text('Retry'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pull down to refresh',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.tables.isEmpty) {
      return RefreshIndicator(
        color: Colors.orange,
        onRefresh: () async {
          await ref
              .read(waiterDashboardViewModelProvider.notifier)
              .initialize();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.table_restaurant_outlined,
                      color: Colors.grey,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text('No tables found for your restaurant.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref
                          .read(waiterDashboardViewModelProvider.notifier)
                          .initialize(),
                      child: const Text('Refresh'),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pull down to refresh',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sortMode = ref.watch(priceSortProvider);

    final List<MenuItemEntity> visibleItems = state.menuItems
        .where(
          (i) =>
              state.selectedCategory == null ||
              i.categoryId == state.selectedCategory!.id,
        )
        .toList();

    if (sortMode == PriceSort.lowToHigh) {
      visibleItems.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
    } else if (sortMode == PriceSort.highToLow) {
      visibleItems.sort((a, b) => _priceOf(b).compareTo(_priceOf(a)));
    }

    final filterActive = sortMode != null;

    return Column(
      children: [
        NoInternetBanner(
          onRetry: () => ref.read(waiterDashboardViewModelProvider.notifier).initialize(),
        ),
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                color: Colors.orange,
                onRefresh: () async {
                  await ref
                      .read(waiterDashboardViewModelProvider.notifier)
                      .initialize();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Total Tables',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TableGrid(
                        tables: state.tables,
                        selectedTable: state.selectedTable,
                        onTableSelected: (table) => ref
                            .read(waiterDashboardViewModelProvider.notifier)
                            .selectTable(table),
                      ),
                      const SizedBox(height: 20),
                      CategoryBar(
                        categories: state.categories,
                        selectedCategory: state.selectedCategory,
                        onCategorySelected: (cat) => ref
                            .read(waiterDashboardViewModelProvider.notifier)
                            .selectCategory(cat),
                        allCount: state.menuItems.length,
                  categoryCountsById: _categoryCountsById(state.menuItems),
                  filterActive: filterActive,
                  onFilterTap: () => _showSortSheet(context),
                ),
                MenuItemGrid(
                  items: visibleItems,
                  onItemAdded: (item) {
                    if (state.selectedTable == null) {
                      SnackbarUtils.showWarning(
                        context,
                        'Please select a table before adding items to the order',
                      );
                      return;
                    }
                    ref
                        .read(waiterDashboardViewModelProvider.notifier)
                        .addToCart(item);
                  },
                ),
              ],
            ),
          ),
        ),
        if (state.selectedTable != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BillSummarySheet(
              state: state,
              onCreateOrder: () => ref
                  .read(waiterDashboardViewModelProvider.notifier)
                  .createOrder(),
            ),
          ),
      ],
    ),
        ),
      ],
    );
  }

  void _showSortSheet(BuildContext context) {
    final savedSort = ref.read(priceSortProvider);
    PriceSort localSort = savedSort ?? PriceSort.lowToHigh;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    12 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            _MinimalOption(
                              title: 'Price: Low to High',
                              selected: localSort == PriceSort.lowToHigh,
                              onTap: () => setState(() {
                                localSort = PriceSort.lowToHigh;
                              }),
                            ),
                            _MinimalOption(
                              title: 'Price: High to Low',
                              selected: localSort == PriceSort.highToLow,
                              onTap: () => setState(() {
                                localSort = PriceSort.highToLow;
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref.read(priceSortProvider.notifier).state =
                                    null;
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ref.read(priceSortProvider.notifier).state =
                                    localSort;
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    if (_isDialogShowing) return;
    
    setState(() => _isDialogShowing = true);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Logout Confirmation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to log out of your session?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(authViewModelProvider.notifier).logout();
                          if (mounted) {
                            AppRoutes.pushReplacement(context, const OnboardingPage());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() => _isDialogShowing = false);
      }
    });
  }

}

class _MinimalOption extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MinimalOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : Colors.black87;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: fg,
                    fontSize: 15,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}