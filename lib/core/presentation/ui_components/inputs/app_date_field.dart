import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../presentation.dart';
import '../others/app_datepicker.dart';

class AppDateField extends StatefulWidget {
  const AppDateField({
    super.key,
    this.controller,
    this.validator,
    this.isRequired = false,
    this.displayFormat,
    this.label,
    this.hint,
    this.onChanged,
  });

  final bool isRequired;
  final DateFieldController? controller;
  final DateFormat? displayFormat;
  final String? label;
  final String? hint;
  final ValueChanged<DateTime?>? onChanged;
  final String? Function(DateTime?)? validator;

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  late DateFieldController controller;

  @override
  void initState() {
    super.initState();

    if (widget.displayFormat != null) controller._changeFormat(widget.displayFormat!);
    controller._addOnChanged(widget.onChanged);
  }

  @override
  void didUpdateWidget(covariant AppDateField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      if (widget.controller != null) {
        controller._removeOnChanged(widget.onChanged);
        controller.dispose();
      }
      controller = widget.controller ?? controller;

      if (widget.controller != null) {
        if (widget.displayFormat != null) controller._changeFormat(widget.displayFormat!);
        controller._addOnChanged(widget.onChanged);
      }
    }
  }

  @override
  void dispose() {
    controller._removeOnChanged(widget.onChanged);
    if (widget.controller == null) controller.dispose();
    super.dispose();
  }

  String? Function(String)? _makeValidator() {
    if (widget.validator != null) {
      return (_) => widget.validator!(controller.selectedDate);
    } else if (widget.isRequired) {
      return (_) {
        if (controller.selectedDate == null) {
          return 'This field is required';
        } else {
          return null;
        }
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      onTap: () => controller.select(title: widget.label),
      onFocusChange: (inFocus) async {
        if (inFocus && !controller._pickerIsOpen) {
          await controller.select(title: widget.label);
        }
      },
      keyboardType: TextInputType.none,
      label: widget.label,
      hint: widget.hint,
      isRequired: widget.isRequired,
      validator: _makeValidator(),
      suffix: AppIconButton(
        label: '${widget.label} DateField',
        view: context.immediateAncestor,
        circled: false,
        child: Icon(Icons.calendar_today_rounded, color: AppColors.of(context).textColor, size: 16),
      ),
    );
  }
}

class DateFieldController extends TextEditingController {
  final DateTime earliestDateAllowed;
  final DateTime latestDateAllowed;
  final DateTime? initialDate;
  DateFormat _format;
  DateTime? _date;
  ValueChanged<DateTime?>? _onChanged;

  bool _pickerIsOpen = false;

  DateFieldController({
    required this.earliestDateAllowed,
    required this.latestDateAllowed,
    this.initialDate,
    DateFormat? format,
  }) : _format = format ?? DateFormat('dd MMM, yyyy');

  DateTime? get selectedDate => _date;

  set selectedDate(DateTime? date) {
    _date = date;
    _displayDateInFormat();
  }

  Future<void> select({String? title}) async {
    _pickerIsOpen = true;
    final picker = AppDatePicker(
      title: title,
      initialSelection: _date ?? initialDate,
      firstDate: earliestDateAllowed,
      lastDate: latestDateAllowed,
    );
    FocusManager.instance.primaryFocus?.unfocus();
    final selection = await picker.show();
    if (selection != null) {
      selectedDate = selection;
      if (_onChanged != null) _onChanged!(selectedDate);
    }
    Future.delayed(Duration.zero, () => _pickerIsOpen = false);
  }

  void _changeFormat(DateFormat dateFormat) {
    _format = dateFormat;
    _displayDateInFormat();
  }

  void _addOnChanged(ValueChanged<DateTime?>? onChanged) {
    _onChanged = onChanged;
  }

  void _removeOnChanged(ValueChanged<DateTime?>? onChanged) {
    if (_onChanged == onChanged) {
      _onChanged = null;
    }
  }

  void _displayDateInFormat() {
    if (_date != null) {
      text = _format.format(_date!);
    }
  }
}
