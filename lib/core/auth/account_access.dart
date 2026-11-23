class AccountAccess {
  final String accountType;
  final bool? isActive;
  final String? registrationStatus;
  const AccountAccess({
    required this.accountType,
    this.isActive,
    this.registrationStatus,
  });
  bool get isTechnical => accountType.trim().toLowerCase() == 'technical';
  bool get canUseTechnicalPages =>
      isTechnical &&
          isActive == true &&
          registrationStatus != 'pending_review' &&
          registrationStatus != 'rejected';
  bool get isPending => isTechnical && registrationStatus == 'pending_review';
}
