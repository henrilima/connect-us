import 'dart:async';
import 'package:connect/components/header.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RPSScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;

  const RPSScreen(this.setPage, {super.key, required this.userData});

  @override
  State<RPSScreen> createState() => _RPSScreenState();
}

class _RPSScreenState extends State<RPSScreen> {
  String? _selectedOption;
  bool _isConfirmed = false;
  Map<String, dynamic> _gameState = {};
  StreamSubscription? _gameSubscription;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _gameSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    final relationshipId = widget.userData['relationshipId'];
    _gameSubscription = DatabaseService().getRPSStream(relationshipId).listen((
      data,
    ) {
      if (mounted) {
        setState(() {
          _gameState = data;

          final myId = widget.userData['userId'];
          final myData = _gameState[myId];

          if (myData != null && _selectedOption == null) {
            if (myData['selection'] != null && myData['selection'] != '') {
              _selectedOption = myData['selection'];
            }
            if (myData['confirmed'] == true) {
              _isConfirmed = true;
            }
          }

          _checkGameStatus();
        });
      }
    });
  }

  void _checkGameStatus() {
    final myId = widget.userData['userId'];
    final partnerId = widget.userData['partnerId'];

    final myData = _gameState[myId];
    final partnerData = _gameState[partnerId];

    if (myData != null &&
        myData['selection'] == '' &&
        _selectedOption != null) {
      setState(() {
        _selectedOption = null;
        _isConfirmed = false;
        _resultMessage = null;
      });
      return;
    }

    if (myData != null &&
        myData['confirmed'] == true &&
        partnerData != null &&
        partnerData['confirmed'] == true) {
      final myChoice = myData['selection'];
      final partnerChoice = partnerData['selection'];

      if (myChoice != null && partnerChoice != null && _resultMessage == null) {
        _calculateWinner(myChoice, partnerChoice);
      }
    }
  }

  void _calculateWinner(String myChoice, String partnerChoice) {
    String result;
    if (myChoice == partnerChoice) {
      result = "Empate!";
    } else if ((myChoice == 'rock' && partnerChoice == 'scissors') ||
        (myChoice == 'paper' && partnerChoice == 'rock') ||
        (myChoice == 'scissors' && partnerChoice == 'paper')) {
      result = "Você venceu!";
      DatabaseService().updateRPSScores(
        widget.userData['relationshipId'],
        widget.userData['userId'],
        partnerId: widget.userData['partnerId'],
      );
    } else {
      result = "Você perdeu!";
    }

    setState(() {
      _resultMessage = result;
    });
  }

  Future<void> _selectOption(String option) async {
    if (_isConfirmed) return;
    setState(() {
      _selectedOption = option;
    });
    await DatabaseService().updateRPSSelection(
      widget.userData['relationshipId'],
      widget.userData['userId'],
      option,
    );
  }

  Future<void> _confirmSelection() async {
    if (_selectedOption == null) return;
    setState(() {
      _isConfirmed = true;
    });
    await DatabaseService().confirmRPSSelection(
      widget.userData['relationshipId'],
      widget.userData['userId'],
    );
  }

  Future<void> _cancelConfirmation() async {
    setState(() {
      _isConfirmed = false;
    });
    if (_selectedOption != null) {
      await DatabaseService().updateRPSSelection(
        widget.userData['relationshipId'],
        widget.userData['userId'],
        _selectedOption!,
      );
    }
  }

  Future<void> _resetRound() async {
    await DatabaseService().resetRPSRound(widget.userData['relationshipId']);
    setState(() {
      _selectedOption = null;
      _isConfirmed = false;
      _resultMessage = null;
    });
  }

  Future<void> _resetScores() async {
    await DatabaseService().resetRPSScores(widget.userData['relationshipId']);
  }

  Widget _buildOptionButton(String option, IconData icon) {
    final isSelected = _selectedOption == option;
    return GestureDetector(
      onTap: () => _selectOption(option),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColorHover
              : AppColors.drawerBackgroundColor,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Icon(
          icon,
          size: 40,
          color: isSelected ? Colors.white : AppColors.textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final partnerId = widget.userData['partnerId'];
    final partnerData = _gameState[partnerId];
    final partnerConfirmed =
        partnerData != null && partnerData['confirmed'] == true;

    final scores = _gameState['scores'] ?? {};
    final myScore = scores[widget.userData['userId']] ?? 0;
    final partnerScore = scores[partnerId] ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: 'Pedra, Papel e Tesoura'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreCard("Você", myScore),
                        const Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColorSecondary,
                          ),
                        ),
                        _buildScoreCard("Parceiro", partnerScore),
                      ],
                    ),
                    const Spacer(),

                    if (_resultMessage != null) ...[
                      Text(
                        _resultMessage!,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColorHover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Parceiro escolheu: ${_getIconName(partnerData?['selection'])}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.textColorSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _resetRound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text("Jogar Novamente"),
                      ),
                    ] else ...[
                      if (partnerConfirmed)
                        const Text(
                          "Parceiro está pronto!",
                          style: TextStyle(
                            color: AppColors.successColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      else
                        const Text(
                          "Aguardando parceiro...",
                          style: TextStyle(
                            color: AppColors.textColorSecondary,
                            fontSize: 16,
                          ),
                        ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildOptionButton(
                            'rock',
                            FontAwesomeIcons.handBackFist,
                          ),
                          _buildOptionButton('paper', FontAwesomeIcons.hand),
                          _buildOptionButton(
                            'scissors',
                            FontAwesomeIcons.handScissors,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      if (_selectedOption != null && !_isConfirmed)
                        ElevatedButton(
                          onPressed: _confirmSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                          ),
                          child: const Text("Confirmar"),
                        )
                      else if (_isConfirmed)
                        if (!partnerConfirmed)
                          Column(
                            children: [
                              const Text(
                                "Aguardando parceiro...",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: _cancelConfirmation,
                                child: const Text(
                                  "Cancelar",
                                  style: TextStyle(color: AppColors.errorColor),
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            "Aguardando resultado...",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    ],

                    const Spacer(),
                    const Spacer(),
                    Builder(
                      builder: (context) {
                        final myId = widget.userData['userId'];
                        final myData = _gameState[myId];
                        final myConfirmed =
                            myData != null && myData['confirmed'] == true;
                        final canReset = !myConfirmed && !partnerConfirmed;

                        return TextButton(
                          onPressed: canReset ? _resetScores : null,
                          child: Text(
                            "Zerar Placar",
                            style: TextStyle(
                              color: canReset
                                  ? AppColors.errorColorHover
                                  : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textColorSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          score.toString(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
      ],
    );
  }

  String _getIconName(String? selection) {
    switch (selection) {
      case 'rock':
        return 'Pedra';
      case 'paper':
        return 'Papel';
      case 'scissors':
        return 'Tesoura';
      default:
        return '...';
    }
  }
}
