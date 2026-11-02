import 'package:flutter/material.dart';
import '../models/asset_model.dart';
import '../models/transation_model.dart';

class MarketsGridListScreen extends StatelessWidget {
  const MarketsGridListScreen({super.key});

  static const List<Asset> assets = [
    Asset(
      symbol: 'BTC',
      name: 'Bitcoin',
      price: 67420.00,
      change24h: 4.20,
      balance: 0.4,
    ),
    Asset(
      symbol: 'ETH',
      name: 'Ethereum',
      price: 3500,
      change24h: -1.80,
      balance: 4.20,
    ),
    Asset(
      symbol: 'Sol',
      name: 'Solana',
      price: 200.00,
      change24h: 0.5,
      balance: 85.00,
    ),
  ];

  static const List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx_1',
      title: 'Apple Store',
      category: 'Teknoloji',
      date: 'bugün 14.20',
      amount: 64500,
      isExpence: true,
      icon: Icons.laptop_mac,
    ),
    TransactionItem(
      id: 'tx_2',
      title: 'Kodusta Danışmanlık Hakediş',
      category: 'Teknoloji',
      date: 'bugün 14.20',
      amount: 64500,
      isExpence: false,
      icon: Icons.account_balance,
    ),
    TransactionItem(
      id: 'tx_3',
      title: 'Apple Store',
      category: 'Teknoloji',
      date: 'bugün 14.20',
      amount: 64500,
      isExpence: true,
      icon: Icons.laptop_mac,
    ),
    TransactionItem(
      id: 'tx_4',
      title: 'Apple Store',
      category: 'Teknoloji',
      date: 'bugün 14.20',
      amount: 64500,
      isExpence: true,
      icon: Icons.laptop_mac,
    ),
  ];

  // Ek paket gerektirmeden Türkçe sayı biçimi.
  static String _formatNumber(num value, {int decimals = 2}) {
    final parts = value.abs().toStringAsFixed(decimals).split('.');
    final integer = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    final fraction = decimals > 0 ? ',${parts[1]}' : '';
    final sign = value < 0 ? '-' : '';

    return '$sign$integer$fraction';
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
            'Piyasalar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Varlıklar ve son işlemler • Örnek veriler',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          _buildAssetsGrid(),
          const SizedBox(height: 28),
          const Text(
            'Son İşlemler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildAssetsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns;

        if (constraints.maxWidth >= 850) {
          columns = 3;
        } else if (constraints.maxWidth >= 550) {
          columns = 2;
        } else {
          columns = 1;
        }

        const spacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        // Kart yüksekliği metne göre büyüyebilir.
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: assets.map((asset) {
            return SizedBox(
              width: cardWidth,
              child: _buildAssetCard(asset),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildAssetCard(Asset asset) {
    final isPositive = asset.change24h >= 0;
    final changeColor = isPositive
        ? const Color(0xFF16A34A)
        : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  asset.symbol.substring(0, 1),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Fiyat (USD)',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${_formatNumber(asset.price)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 20,
                color: changeColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${isPositive ? '+' : ''}'
                  '${_formatNumber(asset.change24h)}% · 24 saat',
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Text(
            'Bakiye: ${_formatNumber(asset.balance)} ${asset.symbol}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        separatorBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          );
        },
        itemBuilder: (context, index) {
          return _buildTransactionItem(transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem transaction) {
    final color = transaction.isExpence
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);

    final backgroundColor = transaction.isExpence
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
      ],
    );

    final amount = Text(
      '${transaction.isExpence ? '-' : '+'}'
      '₺${_formatNumber(transaction.amount)}',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                transaction.icon,
                color: color,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        details,
                        const SizedBox(height: 8),
                        amount,
                      ],
                    )
                  : details,
            ),
            if (!isNarrow) ...[
              const SizedBox(width: 12),
              amount,
            ],
          ],
        );
      },
    );
  }
}