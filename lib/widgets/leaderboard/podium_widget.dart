import 'package:flutter/material.dart';

class PodiumWidget extends StatelessWidget {
  final List<Map<String, dynamic>> memberSlots;

  const PodiumWidget({super.key, required this.memberSlots});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        memberSlots.length >= 2
            ? _buildPodiumItem(context, memberSlots[1], 2, 80)
            : _buildEmptyPodiumItem(2, 80),

        // 1st Place
        memberSlots.isNotEmpty
            ? _buildPodiumItem(context, memberSlots[0], 1, 110)
            : _buildEmptyPodiumItem(1, 110),

        // 3rd Place
        memberSlots.length >= 3
            ? _buildPodiumItem(context, memberSlots[2], 3, 70)
            : _buildEmptyPodiumItem(3, 70),
      ],
    );
  }

  Widget _buildPodiumItem(
    BuildContext context,
    Map<String, dynamic> member,
    int rank,
    double height,
  ) {
    final color = rank == 1
        ? const Color(0xFFFFD700)
        : (rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  member['avatar'] ?? '👤',
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            Positioned(
              top: -15,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          member['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${member['intake']}ml',
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPodiumItem(int rank, double height) {
    final color = rank == 1
        ? const Color(0xFFFFD700)
        : (rank == 2 ? const Color(0xFF9CA3AF) : const Color(0xFFCD7F32));
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.4), width: 3),
          ),
          child: Center(
            child: Icon(
              Icons.person_outline,
              color: color.withOpacity(0.4),
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Waiting...',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
        ),
      ],
    );
  }
}
