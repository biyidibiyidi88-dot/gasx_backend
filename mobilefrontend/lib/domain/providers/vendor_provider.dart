import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_provider.dart';
import '../../data/repositories/vendor_repository.dart';
import '../../data/models/vendor_models.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return VendorRepository(dio);
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  return ref.watch(vendorRepositoryProvider).getVendors();
});

final selectedVendorProvider = StateProvider<Vendor?>((ref) => null);

