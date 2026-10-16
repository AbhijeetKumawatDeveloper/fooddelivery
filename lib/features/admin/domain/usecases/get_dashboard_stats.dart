import '../entities/admin_dashboard_stats.dart';
import '../repositories/admin_repository.dart';

class GetDashboardStats {
  final AdminRepository repository;

  GetDashboardStats(this.repository);

  Future<AdminDashboardStats> call() {
    return repository.getDashboardStats();
  }
}
