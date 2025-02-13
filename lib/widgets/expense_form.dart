import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/database_provider.dart';
import '../constants/icons.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  ExpenseForm({super.key, this.oldExp, this.isEdit = false});
  final Expense? oldExp;
  final bool isEdit;
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _date;
  String _initialCategory = 'Other';

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.oldExp != null) {
      _titleController.text = widget.oldExp!.title;
      _amountController.text = widget.oldExp!.amount.toString();
      _date = widget.oldExp!.date;
      _initialCategory = widget.oldExp!.category;
    }
  }

  _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _date ?? DateTime.now(),
        firstDate: DateTime(2022),
        lastDate: DateTime.now());

    if (pickedDate != null) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // amount
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount of expense',
              ),
            ),
            const SizedBox(height: 20.0),
            // date picker
            Row(
              children: [
                Expanded(
                  child: Text(_date != null
                      ? DateFormat('MMMM dd, yyyy').format(_date!)
                      : 'Select Date'),
                ),
                IconButton(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // category
            Row(
              children: [
                const Expanded(child: Text('Category')),
                Expanded(
                  child: DropdownButton(
                    items: icons.keys
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    value: _initialCategory,
                    onChanged: (newValue) {
                      setState(() {
                        _initialCategory = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                if (_titleController.text != '' &&
                    _amountController.text != '') {
                  final newExpense = Expense(
                    id: widget.isEdit && widget.oldExp != null
                        ? widget.oldExp!.id
                        : 0,
                    title: _titleController.text,
                    amount: double.parse(_amountController.text),
                    date: _date ?? DateTime.now(),
                    category: _initialCategory,
                  );

                  if (widget.isEdit && widget.oldExp != null) {
                    // update the existing expense
                    provider.editExpense(newExpense);
                  } else {
                    // create a new expense
                    provider.addExpense(newExpense);
                  }

                  Navigator.of(context).pop(); // close the bottom sheet
                }
              },
              icon: Icon(widget.isEdit ? Icons.edit : Icons.add),
              label: Text(widget.isEdit ? 'Edit Expense' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
