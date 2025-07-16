import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/services.dart';
import 'package:teddy/glass/glassCard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool _codeSent = false;
  String _verificationId = '';
  bool _loading = false;

  // 국가 코드 관련
  String _countryCode = '+82'; // 기본: 대한민국
  String _countryIso = 'KR';   // 기본: 대한민국

  // 국가 코드 리스트 (필수 주요국가만)
  final List<Map<String, String>> _countryCodes = [
    {
      'code': '+1',
      'lang': 'en',
      'iso': 'US',
      'flag': '🇺🇸',
      'name_en': 'United States',
      'name_ko': '미국',
      'name_ja': 'アメリカ'
    },
    {
      'code': '+82',
      'lang': 'ko',
      'iso': 'KR',
      'flag': '🇰🇷',
      'name_en': 'South Korea',
      'name_ko': '대한민국',
      'name_ja': '韓国'
    },
    {
      'code': '+81',
      'lang': 'ja',
      'iso': 'JP',
      'flag': '🇯🇵',
      'name_en': 'Japan',
      'name_ko': '일본',
      'name_ja': '日本'
    },
    // 필요시 더 추가
  ];

  Future<void> _sendCode() async {
    setState(() => _loading = true);
    final String phoneNumber =
        '$_countryCode${_phoneController.text.replaceAll(' ', '').replaceAll('-', '')}';
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        setState(() => _loading = false);
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('phone_verify_failed'.tr())),
        );
      },
      codeSent: (verificationId, _) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
          _loading = false;
        });
      },
      codeAutoRetrievalTimeout: (_) {
        setState(() => _loading = false);
      },
    );
  }

  Future<void> _verifyCode() async {
    setState(() => _loading = true);
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: _codeController.text.trim(),
    );
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('code_verify_failed'.tr())),
      );
    }
    setState(() => _loading = false);
  }

  /// 국가별 전화번호 자동 포맷 (간단 구현: 숫자만 추출, 3-4-4로 구분)
  String _formatPhoneNumber(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (_countryCode == '+1') {
      if (cleanedValue.length <= 3) return cleanedValue;
      if (cleanedValue.length <= 6) return '${cleanedValue.substring(0, 3)} ${cleanedValue.substring(3)}';
      return '${cleanedValue.substring(0, 3)} ${cleanedValue.substring(3, 6)} ${cleanedValue.substring(6, cleanedValue.length.clamp(0, 10))}';
    } else if (_countryCode == '+81') {
      if (cleanedValue.length <= 3) return cleanedValue;
      if (cleanedValue.length <= 7) return '${cleanedValue.substring(0, 3)} ${cleanedValue.substring(3)}';
      return '${cleanedValue.substring(0, 3)} ${cleanedValue.substring(3, 7)} ${cleanedValue.substring(7, cleanedValue.length.clamp(0, 11))}';
    } else {
      if (cleanedValue.length <= 3) return cleanedValue;
      if (cleanedValue.length <= 7) return '${cleanedValue.substring(0, 3)} ${cleanedValue.substring(3)}';
      return '${cleanedValue.substring(0, 3)} ${cleanedValue.substring(3, 7)} ${cleanedValue.substring(7, cleanedValue.length.clamp(0, 11))}';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // 현재 로케일에 해당하는 국가 정보 가져오기 (lang == locale.languageCode)
  Map<String, String> _getCountryByLocale(Locale locale) {
    return _countryCodes.firstWhere(
          (c) => c['lang'] == locale.languageCode,
      orElse: () => _countryCodes[1],
    );
  }

  // 현재 선택된 국가 정보
  Map<String, String> _getSelectedCountry() {
    return _countryCodes.firstWhere(
          (c) => c['code'] == _countryCode,
      orElse: () => _countryCodes[1],
    );
  }

  // 현재 로케일에 맞는 국가명 반환
  String _getCountryNameByLocale(Map<String, String> country, Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        return country['name_ko'] ?? country['name_en']!;
      case 'ja':
        return country['name_ja'] ?? country['name_en']!;
      default:
        return country['name_en']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = context.locale;
    final countryByLocale = _getCountryByLocale(locale);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Center(
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\u{1F9F8}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC19A6B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    !_codeSent ? _buildPhoneInput(isDark) : _buildCodeInput(isDark),
                    if(!_loading && (_codeController.text.isNotEmpty || _phoneController.text.isNotEmpty)) const SizedBox(height: 16),
                    _loading || (_codeController.text.isEmpty && _phoneController.text.isEmpty)
                        ? SizedBox()
                        : !_codeSent
                        ? _glassButton('send_code'.tr(), _sendCode, isDark)
                        : _glassButton('verify'.tr(), _verifyCode, isDark),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(
                child: CupertinoButton(
                  onPressed: _showLanguageSheet,
                  child: Text(
                    // 국기 + 현 로케일에 해당하는 국가명
                    countryByLocale['flag']! + ' ' + _getCountryNameByLocale(countryByLocale, locale),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF181A1B) : const Color(0xFFF2F6FB),
    );
  }

  /// 텍스트필드 수직 정렬 이슈 해결: isDense, alignLabelWithHint, contentPadding 추가, label은 사용 X
  Widget _buildPhoneInput(bool isDark) {
    final selectedCountry = _getSelectedCountry();
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cycleCountryCode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.5),
              ),
              child: Text(
                selectedCountry['flag']! + ' ' + selectedCountry['code']!,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white.withOpacity(0.5) : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
          SizedBox(width: 4,),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: 'phone_hint'.tr(),
                border: InputBorder.none,
                isDense: true,
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: TextStyle(
                  color: isDark ? Colors.white.withOpacity(0.5) : CupertinoColors.systemGrey
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: (value) {
                setState(() {
                  _phoneController.text;
                });
                final formattedValue = _formatPhoneNumber(value);
                _phoneController.value = TextEditingValue(
                  text: formattedValue.length <= 13 ? formattedValue : formattedValue.substring(0, 13),
                  selection: TextSelection.collapsed(offset: formattedValue.length <= 13 ? formattedValue.length : 13),
                );
              },
              readOnly: false,
            ),
          ),
          if(_loading) const CupertinoActivityIndicator(),
        ],
      ),
    );
  }

  void _cycleCountryCode() {
    final int idx = _countryCodes.indexWhere((c) => c['code'] == _countryCode);
    final int nextIdx = (idx + 1) % _countryCodes.length;
    setState(() {
      _countryCode = _countryCodes[nextIdx]['code']!;
      _countryIso = _countryCodes[nextIdx]['iso']!;
    });
  }

  Widget _buildCodeInput(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'sms_hint'.tr(),
                border: InputBorder.none,
                prefixIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPasswordValidation,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                isDense: true,
                alignLabelWithHint: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value){
                setState(() {
                  _codeController.text;
                });
              },
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, letterSpacing: _codeController.text.isNotEmpty?8:0,),
            ),
          ),
          if(_loading) const CupertinoActivityIndicator(),
        ],
      )
    );
  }

  Widget _glassButton(String text, VoidCallback onPressed, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      minWidthMax: true,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        onPressed: onPressed,
        color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.5),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 언어선택 바텀시트 수정: 드래그핸들 추가, "언어 선택" 텍스트 삭제
  void _showLanguageSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // 완전투명
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8), // 가에 패딩
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(12.5),
                      ),
                    ),
                  ),
                  _langSheetItem('🇺🇸 English', const Locale('en'), isDark),
                  _langSheetItem('🇰🇷 한국어', const Locale('ko'), isDark),
                  _langSheetItem('🇯🇵 日本語', const Locale('ja'), isDark),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 언어 선택 아이템
  Widget _langSheetItem(String label, Locale locale, bool isDark) {
    final isSelected = context.locale == locale;
    return ListTile(
      leading: Text(label.split(' ')[0], style: const TextStyle(fontSize: 22)),
      title: Text(
        label.split(' ')[1],
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? (isDark ? Colors.white : Colors.black87)
              : Colors.grey,
        ),
      ),
      onTap: () {
        context.setLocale(locale);
        Navigator.of(context).pop();
      },
      selected: isSelected,
      tileColor: Colors.transparent,
    );
  }
}