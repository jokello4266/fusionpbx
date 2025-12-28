import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class FindPlumberScreen extends ConsumerStatefulWidget {
  const FindPlumberScreen({super.key});

  @override
  ConsumerState<FindPlumberScreen> createState() => _FindPlumberScreenState();
}

class _FindPlumberScreenState extends ConsumerState<FindPlumberScreen> {
  List<Map<String, dynamic>> _plumbers = [];
  bool _isLoading = true;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _requestLocationAndLoadPlumbers();
  }

  Future<void> _requestLocationAndLoadPlumbers() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them.'),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _position = await Geolocator.getCurrentPosition();
      await _loadPlumbers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _loadPlumbers() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      List<Map<String, dynamic>> plumbers;

      if (_position != null) {
        plumbers = await apiService.findPlumbers(
          latitude: _position!.latitude,
          longitude: _position!.longitude,
        );
      } else {
        // Fallback to static list if location unavailable
        plumbers = _getStaticPlumbers();
      }

      setState(() {
        _plumbers = plumbers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _plumbers = _getStaticPlumbers();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getStaticPlumbers() {
    return [
      {
        'name': 'AquaFlow Plumbing',
        'rating': 4.8,
        'distance': 2.3,
        'phone': '+1234567890',
        'address': '123 Main St',
      },
      {
        'name': 'WaterWorks Solutions',
        'rating': 4.6,
        'distance': 3.1,
        'phone': '+1234567891',
        'address': '456 Oak Ave',
      },
      {
        'name': 'Precision Plumbing',
        'rating': 4.9,
        'distance': 4.5,
        'phone': '+1234567892',
        'address': '789 Elm St',
      },
    ];
  }

  Future<void> _callPlumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _getDirections(String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Plumber'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _plumbers.isEmpty
                ? const Center(child: Text('No plumbers found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _plumbers.length,
                    itemBuilder: (context, index) {
                      final plumber = _plumbers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plumber['name'] ?? 'Unknown',
                                          style: Theme.of(context).textTheme.displaySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${plumber['rating'] ?? 'N/A'}',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${plumber['distance'] ?? 'N/A'} mi',
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _callPlumber(plumber['phone'] ?? ''),
                                      icon: const Icon(Icons.phone),
                                      label: const Text('Call'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _getDirections(plumber['address'] ?? ''),
                                      icon: const Icon(Icons.directions),
                                      label: const Text('Directions'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}


