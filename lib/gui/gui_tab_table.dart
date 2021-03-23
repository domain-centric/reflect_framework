import 'package:flutter/material.dart';
import 'file:///C:/Users/nilsth/AndroidStudioProjects/reflect_framework/lib/gui/gui_tab.dart' as ReflectTab;

class TableExampleTab extends ReflectTab.Tab {
  final List<_Row> _rows = [
    for (int i=1;i<100;i++)
    _Row('Cell A$i', 'CellB$i', 'CellC$i', i),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      DataTable(
        //header: Text('Header Text'),
        //rowsPerPage: 4,
        columns: [
          DataColumn(label: Text('Header A')),
          DataColumn(label: Text('Header B')),
          DataColumn(label: Text('Header C')),
          DataColumn(label: Text('Header D')),
        ],
        rows: _rows.map((row) => DataRow(cells: [
              DataCell(Text(row.valueA)),
              DataCell(Text(row.valueB)),
              DataCell(Text(row.valueC)),
              DataCell(Text(row.valueD.toString()))
            ])).toList(),
      ),
    ]);
  }

  ///Table tabs can be closed directly because they do not have unsaved state
  ///(unlike an editable form)
  @override
  bool get canCloseDirectly => true;

  @override
  ReflectTab.TabCloseResult get close => throw UnimplementedError();

  @override
  IconData get iconData => Icons.table_chart_sharp;

  @override
  String get title => "Table";
}

class _Row {
  _Row(
    this.valueA,
    this.valueB,
    this.valueC,
    this.valueD,
  );

  final String valueA;
  final String valueB;
  final String valueC;
  final int valueD;

  bool selected = false;
}

class TableExampleTabFactory implements ReflectTab.TabFactory{
  @override
  ReflectTab.Tab create() {
    return TableExampleTab();
  }
}
// class _DataSource extends DataTableSource {
//   _DataSource(this.context) {
//     _rows = <_Row>[
//       _Row('Cell A1', 'CellB1', 'CellC1', 1),
//       _Row('Cell A2', 'CellB2', 'CellC2', 2),
//       _Row('Cell A3', 'CellB3', 'CellC3', 3),
//       _Row('Cell A4', 'CellB4', 'CellC4', 4),
//     ];
//   }
//
//   final BuildContext context;
//   List<_Row> _rows;
//
//   int _selectedCount = 0;
//
//   @override
//   DataRow getRow(int index) {
//     assert(index >= 0);
//     if (index >= _rows.length) return null;
//     final row = _rows[index];
//     return DataRow.byIndex(
//       index: index,
//       selected: row.selected,
//       onSelectChanged: (value) {
//         if (row.selected != value) {
//           _selectedCount += value ? 1 : -1;
//           assert(_selectedCount >= 0);
//           row.selected = value;
//           notifyListeners();
//         }
//       },
//       cells: [
//         DataCell(Text(row.valueA)),
//         DataCell(Text(row.valueB)),
//         DataCell(Text(row.valueC)),
//         DataCell(Text(row.valueD.toString())),
//       ],
//     );
//   }
//
//   @override
//   int get rowCount => _rows.length;
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get selectedRowCount => _selectedCount;
// }
