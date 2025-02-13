import 'package:expense_app/widgets/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../constants/icons.dart';
import './confirm_box.dart';

class ExpenseCard extends StatelessWidget {
  final Expense exp;
  final GlobalKey _key = GlobalKey();
  ExpenseCard(this.exp, {super.key});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(exp.id),
      confirmDismiss: (_) async {
        showDialog(
          context: context,
          builder: (_) => ConfirmBox(exp: exp),
        );
      },
      child: ListTile(
        key: _key,
        onTap: () {
          _showPopupMenu(context);
        },
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icons[exp.category]),
        ),
        title: Text(exp.title),
        subtitle: Text(DateFormat('MMMM dd, yyyy').format(exp.date)),
        trailing: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹')
            .format(exp.amount)),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) async {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + renderBox.size.width, // Left
        offset.dy, // Top
        offset.dx, // Right
        offset.dy + renderBox.size.height, // Bottom
      ),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem<String>(
          value: 'Delete',
          child: Text('Delete'),
        ),
      ],
    ).then((value) {
      if (value != null) {
        _handleMenuSelection(value, context);
      }
    });
  }

  void _handleMenuSelection(String value, BuildContext context) {
    if (value == 'Edit') {
      _editExpense(context);
    } else if (value == 'Delete') {
      _deleteExpense(context);
    }
  }

  void _editExpense(BuildContext context) {
    // Handle edit logic, navigate to edit page or show edit dialog
    print('Edit Expense: ${exp.title}');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ExpenseForm(
        oldExp: exp,
        isEdit: true,
      ),
    );
  }

  void _deleteExpense(BuildContext context) {
    // Handle delete logic, show a confirmation dialog or directly delete
    showDialog(
      context: context,
      builder: (_) => ConfirmBox(exp: exp),
    );
  }
}
