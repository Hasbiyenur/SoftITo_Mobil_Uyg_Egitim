import 'package:flutter/material.dart';
import '../models/transation_model.dart';

class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  double _balance = 148950.00;

  final List<TransactionItem> _history = [
    const TransactionItem(
      id: 'tx_init_1',
      title: 'Hasbiyenur Çoban',
      category: 'Hızlı Transfer',
      date: 'bugün 11.30',
      amount: 1500.00,
      isExpence: true,
      icon: Icons.send_rounded,
    ),
    const TransactionItem(
      id: 'tx_init_2',
      title: 'Elif Begüm ',
      category: 'Hızlı Transfer',
      date: 'dün 15.45',
      amount: 2400.00,
      isExpence: true,
      icon: Icons.send_rounded,
    ),
  ];

  String _formatMoney(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integer = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return '₺$integer,${parts[1]}';
  }

  Future<void> _openTransferModal() async {
    final result = await showModalBottomSheet<_TransferData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return _TransferFormSheet(balance: _balance);
      },
    );

    if (!mounted || result == null) return;

    // Para hesaplarında kuruş üzerinden yuvarlama yapıyoruz.
    final balanceInCents = (_balance * 100).round();
    final amountInCents = (result.amount * 100).round();

    if (amountInCents <= 0 || amountInCents > balanceInCents) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer tutarı geçersiz veya bakiye yetersiz.'),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    setState(() {
      _balance = (balanceInCents - amountInCents) / 100;

      _history.insert(
        0,
        TransactionItem(
          id: 'tx_${now.microsecondsSinceEpoch}',
          title: result.recipient,
          category: 'Hızlı Transfer',
          date: 'bugün $hour.$minute',
          amount: amountInCents / 100,
          isExpence: true,
          icon: Icons.send_rounded,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${result.recipient} için '
          '${_formatMoney(result.amount)} örnek transfer kaydedildi.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Para Transferi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Örnek transfer oluştur ve işlem geçmişini incele.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          _buildBalanceCard(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openTransferModal,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Yeni Transfer'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Transfer Geçmişi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _buildHistory(),
          const SizedBox(height: 16),
          const Text(
            'Bu ekran bir demodur. İşlemler yalnızca ekran açıkken '
            'saklanır; gerçek para transferi yapılmaz.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF4338CA),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kullanılabilir Bakiye',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatMoney(_balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    if (_history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text('Henüz transfer yapılmadı.'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          );
        },
        itemBuilder: (context, index) {
          final transaction = _history[index];
          final color = transaction.isExpence
              ? const Color(0xFFDC2626)
              : const Color(0xFF16A34A);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  transaction.icon,
                  color: const Color(0xFF6366F1),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.category} · ${transaction.date}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${transaction.isExpence ? '-' : '+'}'
                      '${_formatMoney(transaction.amount)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Formdan ana ekrana dönen bilgiler.
class _TransferData {
  final String recipient;
  final double amount;

  const _TransferData({
    required this.recipient,
    required this.amount,
  });
}

// Form, kendi alanlarını ve controller'larını yönetir.
class _TransferFormSheet extends StatefulWidget {
  final double balance;

  const _TransferFormSheet({required this.balance});

  @override
  State<_TransferFormSheet> createState() => _TransferFormSheetState();
}

class _TransferFormSheetState extends State<_TransferFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  bool _submitted = false;

  double? _parseAmount(String input) {
    final value = input.trim();

    // Örnek kabul edilen değerler: 1500, 1500,50 veya 1500.50
    if (!RegExp(r'^\d+([,.]\d{1,2})?$').hasMatch(value)) {
      return null;
    }

    final amount = double.tryParse(value.replaceAll(',', '.'));

    if (amount == null || !amount.isFinite) return null;

    return amount;
  }

  void _submit() {
    if (_submitted || !_formKey.currentState!.validate()) return;

    _submitted = true;

    Navigator.of(context).pop(
      _TransferData(
        recipient: _recipientController.text.trim(),
        amount: _parseAmount(_amountController.text)!,
      ),
    );
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Yeni Transfer',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kapat',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Alıcıyı ve göndermek istediğin örnek tutarı gir.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _recipientController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Alıcı adı soyadı',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alıcı adını gir.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Tutar',
                    prefixText: '₺ ',
                    helperText: 'Örnek: 1500,50 — binlik ayırıcı kullanma.',
                    helperMaxLines: 2,
                    errorMaxLines: 3,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    final amount = _parseAmount(value ?? '');

                    if (amount == null) {
                      return 'En fazla iki ondalık basamaklı bir tutar gir.';
                    }

                    if (amount <= 0) {
                      return 'Tutar sıfırdan büyük olmalı.';
                    }

                    if ((amount * 100).round() >
                        (widget.balance * 100).round()) {
                      return 'Bakiyen bu transfer için yetersiz.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Örnek Transferi Tamamla'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}