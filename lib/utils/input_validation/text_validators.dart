abstract class TextInputValidators {
  static String? firstNameValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 2 || trimmed.length > 20 || RegExp(r'\d').hasMatch(trimmed)) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }

  static String? lastNameValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 2 || trimmed.length > 20 || RegExp(r'\d').hasMatch(trimmed)) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }

  static String? emailValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 2 ||
        trimmed.length > 50 ||
        !RegExp(
          r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
        ).hasMatch(trimmed)) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }

  static String? passwordValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(trimmed) ||
        !RegExp(r'[0-9]').hasMatch(trimmed) ||
        !RegExp(r'[a-z]').hasMatch(trimmed)) {
      return 'Lozinka mora imati 8 znamenki, veliko i malo slovo, i broj';
    }
    return null;
  }

  static String? phoneNumberValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (!RegExp(
      r'((?:\+|00)[17](?: |\-)?|(?:\+|00)[1-9]\d{0,2}(?: |\-)?|(?:\+|00)1\-\d{3}(?: |\-)?)?(0\d|\([0-9]{3}\)|[1-9]{0,3})(?:((?: |\-)[0-9]{2}){4}|((?:[0-9]{2}){4})|((?: |\-)[0-9]{3}(?: |\-)[0-9]{4})|([0-9]{7}))',
    ).hasMatch(trimmed)) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }

  static String? streetValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 6) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }

  static String? houseNumberValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    return null;
  }

  static String? postCodeValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 5) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }

  static String? cityValidator(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'Molimo unesite vrijednost';
    if (trimmed.length < 2) {
      return 'Molimo provjerite upisanu vrijednost';
    }
    return null;
  }
}
