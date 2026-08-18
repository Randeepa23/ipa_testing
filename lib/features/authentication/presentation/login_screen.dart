import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/company_brand.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_routes.dart';
import 'login_controller.dart';
import 'login_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _entranceController;
  late final Animation<double> _topOpacity;
  late final Animation<Offset> _topPosition;
  late final Animation<double> _cardOpacity;
  late final Animation<Offset> _cardPosition;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _topOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.62, curve: Curves.easeOutCubic),
    );
    _topPosition =
        Tween<Offset>(begin: const Offset(0, -0.045), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0, 0.68, curve: Curves.easeOutCubic),
          ),
        );
    _cardOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.24, 1, curve: Curves.easeOutCubic),
    );
    _cardPosition =
        Tween<Offset>(begin: const Offset(0, 0.045), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
          ),
        );
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final controller = ref.read(loginControllerProvider.notifier);
    final brand = companyBrandForUsername(state.email);

    ref.listen(loginControllerProvider, (previous, next) {
      if (next.isAuthenticated) context.go(AppRoutes.inbox);
    });

    return Theme(
      // The reference uses a clean modern sans-serif face. Keep this local to
      // sign-in so the rest of the application retains its existing typeface.
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Roboto'),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _LoginBackground(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x22000000),
                    Color(0x08000000),
                    Color(0x55000000),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Keep the complete sign-in experience within a phone
                    // viewport. The previous fixed 490px minimum pushed the
                    // card below the fold on compact devices.
                    final heroHeight = (constraints.maxHeight * 0.44)
                        .clamp(330.0, 390.0)
                        .toDouble();
                    final horizontalPadding = (constraints.maxWidth * 0.08)
                        .clamp(24.0, 68.0)
                        .toDouble();
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        bottom: 28 + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FadeTransition(
                                opacity: _topOpacity,
                                child: SlideTransition(
                                  position: _topPosition,
                                  child: _LoginHero(
                                    brand: brand,
                                    height: heroHeight,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, -52),
                                child: FadeTransition(
                                  opacity: _cardOpacity,
                                  child: SlideTransition(
                                    position: _cardPosition,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: horizontalPadding,
                                          ),
                                          child: _LoginCard(
                                            state: state,
                                            controller: controller,
                                            onSubmit: _submit,
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        const _LoginFooter(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _submit(LoginController controller) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) controller.signIn();
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.brand, required this.height});

  final CompanyBrand brand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.sizeOf(context).height / 850)
        .clamp(0.78, 1.12)
        .toDouble();
    final logoSize = 96.0 * scale;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 16 * scale, 24, 16 * scale),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: SizedBox(
                    key: ValueKey(brand.logoAsset),
                    height: logoSize,
                    width: logoSize,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 18,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8 * scale),
                        child: ClipOval(
                          child: Image.asset(
                            brand.logoAsset,
                            fit: BoxFit.contain,
                            // The logo is displayed at roughly 100 logical
                            // pixels; avoid decoding the 1254px source.
                            cacheWidth: 300,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 22 * scale),
                Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF3A9DFF),
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Customer\nOperations Portal',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 29 * scale,
                    letterSpacing: -0.5,
                    height: 1.12,
                    shadows: const [
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.state,
    required this.controller,
    required this.onSubmit,
  });

  final LoginState state;
  final LoginController controller;
  final void Function(LoginController controller) onSubmit;

  @override
  Widget build(BuildContext context) {
    final scale = (MediaQuery.sizeOf(context).height / 850)
        .clamp(0.78, 1.12)
        .toDouble();
    return Container(
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        42 * scale,
        24 * scale,
        24 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xA6122948),
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(color: const Color(0x557CA2CD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Transform.translate(
            offset: Offset(0, -42 * scale),
            child: Center(
              child: Container(
              width: 62 * scale,
              height: 62 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF1C3559),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x557CA2CD)),
              ),
              child: Icon(
                Icons.shield_outlined,
                color: const Color(0xFF3A9DFF),
                size: 29 * scale,
              ),
              ),
            ),
          ),
          SizedBox(height: 0 * scale),
          TextFormField(
            key: const Key('login_email'),
            initialValue: state.email,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: _fieldDecoration(
              hint: 'Username',
              prefixIcon: Icons.person_outline_rounded,
            ),
            validator: controller.validateEmail,
            onChanged: controller.updateEmail,
          ),
          SizedBox(height: 9 * scale),
          TextFormField(
            key: const Key('login_password'),
            initialValue: state.password,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            obscureText: state.obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            decoration: _fieldDecoration(
              hint: 'Password',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: state.obscurePassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: controller.toggleObscurePassword,
                icon: Icon(
                  state.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFFDCE8F7),
                ),
              ),
            ),
            validator: controller.validatePassword,
            onChanged: controller.updatePassword,
            onFieldSubmitted: (_) => onSubmit(controller),
          ),
          SizedBox(height: 3 * scale),
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: Checkbox(
                  value: state.rememberMe,
                  activeColor: const Color(0xFF2D7DFF),
                  checkColor: AppColors.white,
                  onChanged: (value) =>
                      controller.toggleRememberMe(value ?? false),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Remember me',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3A9DFF),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(
                  'Forgot password?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
 
 
            ],
          ),
          if (state.connectionMessage != null)
            _StatusMessage(
              message: state.connectionMessage!,
              color: AppColors.warningAmber,
            ),
          if (state.disabledMessage != null)
            _StatusMessage(
              message: state.disabledMessage!,
              color: AppColors.primaryRed,
            ),
          if (state.errorMessage != null)
            _StatusMessage(
              message: state.errorMessage!,
              color: AppColors.primaryRed,
            ),
          SizedBox(height: 8 * scale),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A9DFF), Color(0xFF2461D8)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x803A9DFF),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox(
              height: 48 * scale,
              child: FilledButton(
                key: const Key('login_submit'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: state.isSubmitting
                    ? null
                    : () => onSubmit(controller),
                child: state.isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sign in'),
                          SizedBox(width: 14),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 16 * scale),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0x668CA9CC))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Color(0xFFB5C5DA),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0x668CA9CC))),
            ],
          ),
          SizedBox(height: 16 * scale),
          SizedBox(
            height: 48 * scale,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Biometric sign-in will be available soon.'),
                  ),
                );
              },
              icon: const Icon(Icons.fingerprint_rounded),
              label: const Text('Sign in with biometric'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF3A9DFF),
                side: const BorderSide(
                  color: Color(0xFF2D7DFF),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    const borderColor = Color(0x667CA2CD);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: borderColor),
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0x33152D4C),
      hintStyle: const TextStyle(
        color: Color(0xFFB5C5DA),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFFDCE8F7), size: 22),
      suffixIcon: suffixIcon,
      enabledBorder: border,
      border: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF3A9DFF),
          width: 1.7,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/login_background.jpg',
      fit: BoxFit.cover,
      // The source is taller than most phone screens. Bottom alignment trims
      // a little sky instead of hiding the car at the top of the artwork.
      alignment: Alignment.bottomCenter,
      // Medium filtering is visually indistinguishable for this full-screen
      // background but is less demanding on an emulator GPU.
      filterQuality: FilterQuality.medium,
    );
  }
}

class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 17,
          color: AppColors.white,
        ),
        const SizedBox(width: 7),
        Text(
          'Authorized representatives only',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white,
            shadows: const [
              Shadow(color: Color(0x99000000), blurRadius: 6),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.color});
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
