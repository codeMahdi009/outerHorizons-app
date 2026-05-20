import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// Data sourced from NASA Solar System Exploration:
// https://solarsystem.nasa.gov/planets/overview/
const List<Map<String, dynamic>> _planets = [
  {
    'name': 'Mercury',
    'type': 'Terrestrial',
    'diameter': 4879,
    'moons': 0,
    'distance': 57.9,
    'note':
        'Closest planet to the Sun. No atmosphere means extreme temperature swings : from −180°C at night to 430°C by day.',
  },
  {
    'name': 'Venus',
    'type': 'Terrestrial',
    'diameter': 12104,
    'moons': 0,
    'distance': 108.2,
    'note':
        'Hottest planet (462°C average) due to a runaway greenhouse effect. Rotates backwards and extremely slowly.',
  },
  {
    'name': 'Earth',
    'type': 'Terrestrial',
    'diameter': 12756,
    'moons': 1,
    'distance': 149.6,
    'note':
        'Our home. The only known planet with liquid water on its surface and confirmed life. The Moon stabilises our axial tilt.',
  },
  {
    'name': 'Mars',
    'type': 'Terrestrial',
    'diameter': 6792,
    'moons': 2,
    'distance': 227.9,
    'note':
        'The Red Planet. Home to Olympus Mons, the tallest volcano in the Solar System (21 km). Currently hosting multiple NASA rovers.',
  },
  {
    'name': 'Jupiter',
    'type': 'Gas Giant',
    'diameter': 142984,
    'moons': 95,
    'distance': 778.6,
    'note':
        'Largest planet : over 1,300 Earths could fit inside it. The Great Red Spot is a storm that has raged for over 350 years.',
  },
  {
    'name': 'Saturn',
    'type': 'Gas Giant',
    'diameter': 120536,
    'moons': 146,
    'distance': 1433.5,
    'note':
        'Famous for its stunning ring system made of ice and rock. Less dense than water : it would float in a large enough ocean.',
  },
  {
    'name': 'Uranus',
    'type': 'Ice Giant',
    'diameter': 51118,
    'moons': 28,
    'distance': 2872.5,
    'note':
        'Rotates on its side (98° axial tilt), likely due to an ancient collision. Its rings were only discovered in 1977.',
  },
  {
    'name': 'Neptune',
    'type': 'Ice Giant',
    'diameter': 49528,
    'moons': 16,
    'distance': 4495.1,
    'note':
        'Farthest planet from the Sun. Winds reach 2,100 km/h : the fastest in the Solar System. Has never completed an orbit since its discovery in 1846.',
  },
];

class ExoplanetScreen extends StatefulWidget {
  const ExoplanetScreen({super.key});

  @override
  State<ExoplanetScreen> createState() => _ExoplanetScreenState();
}

class _ExoplanetScreenState extends State<ExoplanetScreen> {
  late List<Map<String, dynamic>> _rows;
  Map<String, dynamic>? _selected;

  int _sortColumnIndex = 3; // Distance
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _rows = List<Map<String, dynamic>>.from(_planets);
    _applySort();
  }

  void _sort(int col, bool asc) {
    setState(() {
      _sortColumnIndex = col;
      _sortAscending = asc;
      _applySort();
    });
  }

  void _applySort() {
    _rows.sort((a, b) {
      dynamic av, bv;
      switch (_sortColumnIndex) {
        case 0:
          av = a['name'] ?? '';
          bv = b['name'] ?? '';
        case 1:
          av = a['type'] ?? '';
          bv = b['type'] ?? '';
        case 2:
          av = (a['diameter'] as num?)?.toDouble() ?? 0.0;
          bv = (b['diameter'] as num?)?.toDouble() ?? 0.0;
        case 3:
          av = (a['distance'] as num?)?.toDouble() ?? 0.0;
          bv = (b['distance'] as num?)?.toDouble() ?? 0.0;
        case 4:
          av = (a['moons'] as num?)?.toInt() ?? 0;
          bv = (b['moons'] as num?)?.toInt() ?? 0;
        default:
          return 0;
      }
      final c = Comparable.compare(av as Comparable, bv as Comparable);
      return _sortAscending ? c : -c;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final textMain = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSub = isDark ? Colors.white70 : AppTheme.greyText;
    final cardBg = isDark ? AppTheme.cardDark : AppTheme.lightCard;
    final rowBg = isDark ? AppTheme.deepSpace : AppTheme.lightBg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SOLAR SYSTEM', overflow: TextOverflow.ellipsis),
        leading: _selected != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => _selected = null),
              )
            : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => _selected != null
            ? _buildDetail(isDark, primary, textMain, textSub, cardBg)
            : _buildTable(
                constraints, primary, textMain, textSub, cardBg, rowBg),
      ),
    );
  }

  // ── Detail panel ──────────────────────────────────────────────────────
  Widget _buildDetail(
      bool isDark, Color primary, Color textMain, Color textSub, Color cardBg) {
    final p = _selected!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Planet icon + name
        Center(
          child: Column(children: [
            const SizedBox(height: 10),
            Text(p['name'] as String,
                style: TextStyle(
                    color: textMain,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: primary.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(p['type'] as String,
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ]),
        ),
        const SizedBox(height: 28),

        // Stats grid
        Row(children: [
          Expanded(
              child: _statCard(
                  'Diameter',
                  '${(p['diameter'] as int).toString()} km',
                  Icons.radio_button_checked,
                  primary,
                  cardBg,
                  textMain,
                  textSub)),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard(
                  'Moons',
                  '${p['moons']}',
                  Icons.brightness_2_rounded,
                  primary,
                  cardBg,
                  textMain,
                  textSub)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _statCard('Distance from Sun', '${p['distance']} M km',
                  Icons.wb_sunny_rounded, primary, cardBg, textMain, textSub)),
          const SizedBox(width: 10),
          Expanded(
              child: _statCard('Day Length', '${p['day']} hrs',
                  Icons.schedule_rounded, primary, cardBg, textMain, textSub)),
        ]),
        const SizedBox(height: 10),
        _statCard('Orbital Period', '${p['year']} Earth days',
            Icons.loop_rounded, primary, cardBg, textMain, textSub),
        const SizedBox(height: 20),

        // About
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primary.withAlpha(15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withAlpha(60)),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('About ${p['name']}',
                style: TextStyle(
                    color: primary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text(p['note'] as String,
                style: TextStyle(color: textSub, fontSize: 14, height: 1.6)),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Data: NASA Solar System Exploration : solarsystem.nasa.gov',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSub.withAlpha(100), fontSize: 11)),
      ]),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color primary,
      Color cardBg, Color textMain, Color textSub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textSub, fontSize: 11)),
            Text(value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: textMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        )),
      ]),
    );
  }

  // ── Data table ────────────────────────────────────────────────────────
  Widget _buildTable(BoxConstraints constraints, Color primary, Color textMain,
      Color textSub, Color cardBg, Color rowBg) {
    return SizedBox(
      height: constraints.maxHeight,
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: cardBg,
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '8 planets • tap a row to explore • tap a header to sort',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: primary, fontSize: 12),
              ),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                headingRowColor: WidgetStateProperty.all(cardBg),
                dataRowColor: WidgetStateProperty.resolveWith((s) =>
                    s.contains(WidgetState.selected)
                        ? primary.withAlpha(40)
                        : rowBg),
                dividerThickness: 0.5,
                columnSpacing: 20,
                columns: [
                  DataColumn(label: _hdr('Planet', primary), onSort: _sort),
                  DataColumn(label: _hdr('Type', primary), onSort: _sort),
                  DataColumn(
                      label: _hdr('Diameter', primary),
                      onSort: _sort,
                      numeric: true),
                  DataColumn(
                      label: _hdr('Distance', primary),
                      onSort: _sort,
                      numeric: true),
                  DataColumn(
                      label: _hdr('Moons', primary),
                      onSort: _sort,
                      numeric: true),
                ],
                rows: _rows
                    .map((p) => DataRow(
                          onSelectChanged: (_) => setState(() => _selected = p),
                          cells: [
                            DataCell(Row(children: [
                              Icon(Icons.circle, color: primary, size: 16),
                              const SizedBox(width: 8),
                              Text(p['name'] as String,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: textMain,
                                      fontWeight: FontWeight.w600)),
                            ])),
                            DataCell(_typeBadge(p['type'] as String, primary)),
                            DataCell(Text('${p['diameter']}',
                                style: TextStyle(color: textSub))),
                            DataCell(Text('${p['distance']}',
                                style: TextStyle(color: textSub))),
                            DataCell(Text('${p['moons']}',
                                style: TextStyle(color: textSub))),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _hdr(String label, Color primary) => Text(label,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(color: primary, fontWeight: FontWeight.bold));

  Widget _typeBadge(String type, Color primary) {
    final color = switch (type) {
      'Terrestrial' => Colors.brown.shade400,
      'Gas Giant' => Colors.orange.shade400,
      'Ice Giant' => Colors.blue.shade400,
      _ => primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(120), width: 0.8),
      ),
      child: Text(type,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
