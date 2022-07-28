/*
 * Copyright (c) 2022. By Nils ten Hoeve. See LICENSE file in project.
 */

import 'package:flutter/material.dart';
import 'package:reflect_framework/gui/scroll_view_with_scroll_bar.dart';
import 'package:responsive_layout_grid/responsive_layout_grid.dart';

const maxNumberOfColumns = 8;

class FormExamplePage extends StatelessWidget {
  const FormExamplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ScrollViewWithScrollBar(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: const ResponsiveFormGrid(),
        ),
      );
}

class ResponsiveFormGrid extends StatelessWidget {
  const ResponsiveFormGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ResponsiveLayoutGrid(
        maxNumberOfColumns: maxNumberOfColumns,
        children: [
          _createGroupBar('Participant'),
          _createTextField(
            label: 'Given name',
            position: CellPosition.nextRow(),
          ),
          _createTextField(
            label: 'Family name',
            position: CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Date of birth',
            position: CellPosition.nextColumn(),
          ),
          _createTextField(
              label: 'Remarks (e.g. medicines and allergies)',
              position: CellPosition.nextRow(),
              columnSpan: const ColumnSpan.size(3),
              maxLines: 5),
          _createGroupBar('Home Address'),
          _createTextField(
              label: 'Street', position: CellPosition.nextRow(), maxLines: 2),
          _createTextField(
            label: 'City',
            position: CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Region',
            position: CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Postal code',
            position: CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Country',
            position: CellPosition.nextColumn(),
          ),
          _createGroupBar('Consent'),
          _createTextField(
            label: 'Given name of parent or guardian',
            position: CellPosition.nextRow(),
          ),
          _createTextField(
            label: 'Family name of parent or guardian',
            position: CellPosition.nextColumn(),
          ),
          _createTextField(
            label: 'Phone number of parent or guardian',
            position: CellPosition.nextRow(),
          ),
          _createTextField(
            label: 'Second phone number in case of emergency',
            position: CellPosition.nextColumn(),
          ),
          _createButtonBarGutter(),
          _createCancelButton(
              context, CellPosition.nextRow(rowAlignment: RowAlignment.right)),
          _createSubmitButton(context, CellPosition.nextColumn()),
        ],
      );

  ResponsiveLayoutCell _createGroupBar(String title) => ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        columnSpan: ColumnSpan.remainingWidth(),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey,
          child: Center(
            child: Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ),
      );

  ResponsiveLayoutCell _createTextField({
    required String label,
    required CellPosition position,
    ColumnSpan columnSpan = const ColumnSpan.size(2),
    int maxLines = 1,
  }) =>
      ResponsiveLayoutCell(
        position: position,
        columnSpan: columnSpan,
        child: Column(children: [
          Align(alignment: Alignment.topLeft, child: Text(label)),
          TextFormField(
            maxLines: maxLines,
            decoration: const InputDecoration(
              filled: true,
              isDense: true,
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent, width: 0)),
            ),
          ),
        ]),
      );

  ResponsiveLayoutCell _createSubmitButton(
      BuildContext context, CellPosition position) {
    return ResponsiveLayoutCell(
        position: position,
        child: ElevatedButton(
          onPressed: () {
            //TODO call Tab.close
          },
          child: const Center(
              child:
                  Padding(padding: EdgeInsets.all(16), child: Text('Submit'))),
        ));
  }

  ResponsiveLayoutCell _createCancelButton(
      BuildContext context, CellPosition position) {
    return ResponsiveLayoutCell(
        position: position,
        child: OutlinedButton(
          onPressed: () {
            //TODO call Tab.close
          },
          child: const Center(
              child:
                  Padding(padding: EdgeInsets.all(16), child: Text('Cancel'))),
        ));
  }

  _createButtonBarGutter() => ResponsiveLayoutCell(
        position: CellPosition.nextRow(),
        child: const SizedBox(height: 8),
      );
}
