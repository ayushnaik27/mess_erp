import 'package:flutter/material.dart';

class ChangePasswordDialog extends StatelessWidget {
  final String? rollNumber;
  final Function(String) changePassword;
  const ChangePasswordDialog(
      {Key? key, this.rollNumber, required this.changePassword})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextField(
            controller: confirmNewPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (newPasswordController.text !=
                confirmNewPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passwords do not match'),
                ),
              );
              return;
            }
            changePassword(newPasswordController.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          child: const Text('Change'),
        ),
      ],
    );
  }
}
